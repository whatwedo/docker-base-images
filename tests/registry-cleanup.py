#!/usr/bin/env python3
"""Exercise GHCR's destructive version API against an in-memory registry."""
import contextlib
import copy
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch


sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("cleanup", Path(__file__).resolve().parents[1] / "scripts/cleanup-ghcr.py")
cleanup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cleanup)
REPO = "ghcr.io/whatwedo/base"


class Registry:
    def __init__(self):
        self.tags = {"v3.0": "index", "v3.0-amd64": "amd64", "v3.0-arm64": "arm64"}
        self.manifests = {
            "index": {"manifests": [
                {"digest": arch, "platform": {"os": "linux", "architecture": arch}}
                for arch in ("amd64", "arm64")
            ]},
            "amd64": {"layers": [{"digest": "amd64-layer"}]},
            "arm64": {"layers": [{"digest": "arm64-layer"}]},
        }
        self.deleted = []
        self.created = []
        self.deny_read = self.deny_delete = self.add_other_tag = self.race_release = False

    def resolve(self, reference):
        return reference.split("@", 1)[1] if "@" in reference else self.tags[reference.rsplit(":", 1)[1]]

    def command(self, *args):
        if args[0] == "gh":
            if args[2].startswith("users/"):
                return "Organization"
            if "DELETE" in args:
                if self.deny_delete:
                    raise subprocess.CalledProcessError(1, args, stderr="HTTP 403")
                target = list(self.manifests)[int(args[-1].rsplit("/", 1)[1])]
                self.deleted.append(target)
                del self.manifests[target]
                self.tags = {tag: value for tag, value in self.tags.items() if value != target}
                return ""
            if self.deny_read:
                raise subprocess.CalledProcessError(1, args, stderr="HTTP 403")
            values = [{"id": i, "name": value, "metadata": {"container": {
                "tags": [tag for tag, digest in self.tags.items() if digest == value]
            }}} for i, value in enumerate(self.manifests)]
            # More than one API page must be handled.
            return json.dumps([values[:2], values[2:]])
        if args[1:3] == ("manifest", "head"):
            value = self.resolve(args[3])
            assert value in self.manifests, f"Missing manifest {value}"
            return value
        if args[1:3] == ("manifest", "get"):
            return json.dumps(self.manifests[self.resolve(args[3])])
        if args[1:3] == ("tag", "ls"):
            return "\n".join(self.tags)
        if args[1:3] == ("image", "create"):
            value = f"temporary-{len(self.created)}"
            annotations = dict(args[i + 1].split("=", 1) for i, arg in enumerate(args) if arg == "--annotation")
            # regctl serializes a scratch image's absent layers as JSON null.
            self.manifests[value] = {"layers": None, "annotations": annotations}
            self.tags[args[3].rsplit(":", 1)[1]] = value
            self.created.append(value)
            if self.add_other_tag:
                self.tags["unrelated"] = value
            if self.race_release:
                self.manifests["new-release"] = copy.deepcopy(self.manifests["index"])
                self.tags["v3.0"] = "new-release"
            return ""
        if args[1:3] == ("image", "copy"):
            self.tags[args[4].rsplit(":", 1)[1]] = self.resolve(args[3])
            return ""
        raise AssertionError(args)


class CleanupTest(unittest.TestCase):
    def setUp(self):
        self.registry = Registry()

    def run_cleanup(self):
        with patch.object(cleanup, "command", self.registry.command), contextlib.redirect_stdout(io.StringIO()):
            cleanup.cleanup("regctl", REPO, "v3.0")

    def assert_images_retained(self):
        self.assertTrue({"index", "amd64", "arm64"} <= self.registry.manifests.keys())
        self.assertTrue(all(value.startswith("temporary-") for value in self.registry.deleted))

    def test_removes_only_placeholders_and_keeps_both_published_images(self):
        self.run_cleanup()
        self.assertEqual(self.registry.tags, {"v3.0": "index"})
        self.assertEqual(len(self.registry.deleted), 2)
        self.assert_images_retained()

    def test_checks_api_access_before_changing_tags(self):
        self.registry.deny_read = True
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_cleanup()
        self.assertEqual(self.registry.created, [])
        self.assert_images_retained()

    def test_delete_failure_restores_the_architecture_tag(self):
        self.registry.deny_delete = True
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_cleanup()
        self.assertEqual(self.registry.tags["v3.0-amd64"], "amd64")
        self.assert_images_retained()

    def test_mismatching_architecture_tag_is_not_modified(self):
        self.registry.manifests["different"] = {"layers": []}
        self.registry.tags["v3.0-amd64"] = "different"
        with self.assertRaisesRegex(ValueError, "differs from the published"):
            self.run_cleanup()
        self.assertEqual(self.registry.created, [])
        self.assertEqual(self.registry.tags["v3.0-amd64"], "different")

    def test_refuses_cleanup_without_a_complete_published_index(self):
        self.registry.manifests["index"]["manifests"].pop()
        with self.assertRaisesRegex(ValueError, "published index"):
            self.run_cleanup()
        self.assertEqual(self.registry.created, [])

    def test_never_deletes_a_placeholder_with_an_unrelated_tag(self):
        self.registry.add_other_tag = True
        with self.assertRaisesRegex(ValueError, "ownership changed"):
            self.run_cleanup()
        self.assertEqual(self.registry.deleted, [])
        self.assertEqual(self.registry.tags["v3.0-amd64"], "amd64")
        self.assertIn("unrelated", self.registry.tags)

    def test_retry_skips_tags_already_removed(self):
        del self.registry.tags["v3.0-amd64"]
        self.run_cleanup()
        self.run_cleanup()
        self.assertEqual(len(self.registry.deleted), 1)
        self.assert_images_retained()

    def test_resumes_after_an_interrupted_placeholder_push(self):
        self.registry.command("regctl", "image", "create", REPO + ":v3.0-amd64",
                              "--annotation", cleanup.MARKER + "=" + REPO + ":v3.0-amd64")
        self.run_cleanup()
        self.assertEqual(len(self.registry.created), 2)
        self.assertEqual(len(self.registry.deleted), 2)
        self.assert_images_retained()

    def test_a_concurrent_release_is_not_modified(self):
        self.registry.race_release = True
        with self.assertRaisesRegex(ValueError, "tags changed"):
            self.run_cleanup()
        self.assertEqual(self.registry.tags["v3.0"], "new-release")
        self.assertEqual(self.registry.deleted, [])
        self.assert_images_retained()

    def test_marker_alone_does_not_allow_deleting_an_image_with_layers(self):
        self.registry.command("regctl", "image", "create", REPO + ":v3.0-amd64",
                              "--annotation", cleanup.MARKER + "=" + REPO + ":v3.0-amd64")
        self.registry.manifests["temporary-0"]["layers"] = [{"digest": "important-layer"}]
        with self.assertRaisesRegex(ValueError, "not our empty placeholder"):
            self.run_cleanup()
        self.assertEqual(self.registry.deleted, [])
        self.assert_images_retained()


if __name__ == "__main__":
    unittest.main()
