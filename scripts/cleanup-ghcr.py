#!/usr/bin/env python3
"""Remove temporary GHCR tags while retaining the published index and its images."""
import json
import subprocess
import sys
import time
from urllib.parse import quote
from uuid import uuid4


MARKER = "ch.whatwedo.cleanup.tag"


def command(*args):
    result = subprocess.run(args, capture_output=True, text=True, check=True, timeout=120)
    return result.stdout.strip()


def cleanup(regctl, repository, version):
    if not repository.startswith("ghcr.io/"):
        raise ValueError("Expected a ghcr.io repository")
    owner, package = repository.removeprefix("ghcr.io/").split("/", 1)
    owner_type = command("gh", "api", f"users/{quote(owner, safe='')}", "--jq", ".type")
    scope = "orgs" if owner_type == "Organization" else "users"
    endpoint = f"{scope}/{quote(owner, safe='')}/packages/container/{quote(package, safe='')}/versions"

    def versions():
        pages = json.loads(command("gh", "api", "--paginate", "--slurp", f"{endpoint}?per_page=100"))
        return [item for page in pages for item in page]

    def digest(reference):
        return command(regctl, "manifest", "head", reference)

    def manifest(reference):
        return json.loads(command(regctl, "manifest", "get", reference, "--format", "raw-body"))

    def tags():
        return set(command(regctl, "tag", "ls", repository).splitlines())

    release = f"{repository}:{version}"
    release_digest = digest(release)
    index = manifest(f"{repository}@{release_digest}")
    children = index.get("manifests", [])
    platforms = {(m.get("platform", {}).get("os"), m.get("platform", {}).get("architecture")) for m in children}
    if len(children) != 2 or platforms != {("linux", "amd64"), ("linux", "arm64")}:
        raise ValueError("Cleanup requires a published index with amd64 and arm64 images")
    protected = {release_digest, *(m["digest"] for m in children)}
    # Check API access before changing any tags.
    versions()

    for child in children:
        arch = child["platform"]["architecture"]
        tag = f"{version}-{arch}"
        reference = f"{repository}:{tag}"
        if tag not in tags():
            continue
        original = digest(reference)
        current = manifest(f"{repository}@{original}")
        placeholder = current.get("annotations", {}).get(MARKER) == reference
        if original != child["digest"] and not placeholder:
            raise ValueError(f"{reference} differs from the published image; refusing cleanup")
        if digest(release) != release_digest:
            raise ValueError("Release tag changed during cleanup")
        identity = current.get("annotations", {}).get("ch.whatwedo.cleanup.id") if placeholder else str(uuid4())

        try:
            if not placeholder:
                # A unique scratch manifest detaches the tag from the real image.
                # GHCR rejects Registry DELETE, so delete this version via GitHub.
                command(regctl, "image", "create", reference,
                        "--platform", f"linux/{arch}",
                        "--annotation", f"{MARKER}={reference}",
                        "--annotation", f"ch.whatwedo.cleanup.id={identity}")
            temporary = digest(reference)
            scratch = manifest(f"{repository}@{temporary}")
            if (temporary in protected or scratch.get("layers") not in (None, [])
                    or scratch.get("annotations", {}).get(MARKER) != reference
                    or scratch.get("annotations", {}).get("ch.whatwedo.cleanup.id") != identity):
                raise ValueError("Refusing to delete a manifest that is not our empty placeholder")

            match = None
            for attempt in range(10):
                matches = [item for item in versions() if item["name"] == temporary]
                if len(matches) == 1:
                    match = matches[0]
                    break
                if matches:
                    raise ValueError("Ambiguous placeholder package version")
                time.sleep(1)
            if match is None:
                raise ValueError("GitHub did not expose the placeholder package version")
            if match.get("metadata", {}).get("container", {}).get("tags") != [tag]:
                raise ValueError("Placeholder tag ownership changed; refusing deletion")
            if digest(release) != release_digest or digest(reference) != temporary:
                raise ValueError("Registry tags changed during cleanup")
            command("gh", "api", "--method", "DELETE", f"{endpoint}/{int(match['id'])}")
            if tag in tags():
                raise ValueError(f"GitHub did not remove {reference}")
            print(f"Removed {reference}; published image retained", flush=True)
        except Exception:
            # Keep a failed cleanup retryable and never leave a scratch image
            # under a tag consumers might pull. Do not overwrite someone else's tag.
            if tag in tags():
                now = manifest(reference).get("annotations", {})
                if now.get(MARKER) == reference and now.get("ch.whatwedo.cleanup.id") == identity:
                    command(regctl, "image", "copy", f"{repository}@{child['digest']}", reference)
            raise

    if digest(release) != release_digest:
        raise ValueError("Published index changed during cleanup")
    for child in children:
        if digest(f"{repository}@{child['digest']}") != child["digest"]:
            raise ValueError("A published architecture manifest is missing")


if __name__ == "__main__":
    try:
        cleanup(*sys.argv[1:])
    except subprocess.CalledProcessError as error:
        sys.exit(f"GHCR cleanup failed: {error.stderr.strip()}")
    except (ValueError, TypeError) as error:
        sys.exit(f"GHCR cleanup failed: {error}")
