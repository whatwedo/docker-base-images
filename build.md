# Build Images

`images.conf` lists every image with the parent it derives from, whether it has to carry a service health check, and the test suites that have to pass for it. `build.sh` reads that file — there is no separate build order to keep in sync.

```bash
./build.sh list                  # print the build order
./build.sh info symfony          # print what the manifest says about one image
```

## Building and testing

Each command takes one image, or every image in build order when the name is left out. A child image finds its parent in the local image store, so the chain has to be built in order — which is what an argument-less call does.

```bash
./build.sh check                 # build and test everything, in order
./build.sh check symfony         # build and test one image
./build.sh build symfony         # build only
./build.sh test symfony          # test an image that has already been built
```

When migrating existing automation, use `check` where the old `test` command was expected to build and test. `build` only builds locally for the Docker daemon's architecture; publishing is a separate step.

Builds always run with `--no-cache`, so a rebuild really picks up new apt packages instead of a cached layer. They also run with `--provenance=false`: an attestation would turn a single-platform build into an index, which the publishing step cannot use as a source.

Every Sunday at 05:17 Europe/Zurich, the `Images` workflow on `main` dispatches this branch's full `Images` workflow for `v3.0`. Both architectures are rebuilt and tested before publishing to the three registries. The small dispatcher lives on `main` because GitHub only runs scheduled workflows from the default branch.

These rebuilds pick up APT updates within the selected Debian/PHP/Node.js versions. Explicit version pins for npm, Goss and regctl still require manual updates. There is no dependency-update bot. GitHub can disable scheduled workflows in public repositories after 60 days without repository activity; re-enable the workflow if that happens.

Testing requires Docker, Bash and curl. `goss validate` runs inside the image; the suites under `tests/` check HTTP behavior, graceful shutdown and PHP Imagick PDF rendering.

### Test host

`build.sh test` starts containers and talks to them over a published port. When the Docker daemon runs on another host, point the tests at it:

| Variable | Purpose |
|---|---|
| `TEST_PUBLISH_ADDRESS` | Address the daemon publishes the test port on (defaults to `127.0.0.1`) |
| `TEST_HOST` | Host the requests connect to (defaults to `TEST_PUBLISH_ADDRESS`) |

The HTTP suites bind-mount temporary fixtures, so their paths must also be available on the Docker daemon host. GitHub Actions runs the scripts and daemon on the same runner.

## Publishing

Pushes to `v3.0-gh-actions`, pull requests and manual runs on feature branches build and test without publishing. Only branch names matching `v<major>.<minor>` (for example `v3.0`) enable publishing; a tag with the same name does not.

Publishing is the job of the `Images` workflow in GitHub Actions and normally needs no manual step. The workflow builds the chain on a native runner per architecture, tests every image, and only then pushes it — nothing reaches a registry before its tests are green.

Per image and architecture:

```bash
./build.sh push symfony          # push the tested image as :<version>-<arch>
./build.sh merge symfony         # combine both architecture tags into one manifest list
./build.sh mirror symfony        # copy the merged image to the mirror registries
./build.sh cleanup symfony       # remove the architecture tags again
```

What remains in the registry afterwards is what any ordinary multi-architecture push leaves behind: one tag, and below it an index over two untagged architecture manifests.

`merge` and `cleanup` exist because a single `docker push` cannot express a manifest list, and `push-by-digest` is not implemented for the default `docker` build driver — that driver is what lets a child image build against the parent in the local store. So each architecture is pushed under its own tag, merged, and the intermediate tags are removed.

| Variable | Purpose |
|---|---|
| `VERSION` | Tag of the published manifest list; defaults to the current branch name |
| `ARCH` | Architecture suffix of the intermediate tags; defaults to the Docker server architecture |
| `REGISTRY_BUILD` | Where architecture tags and the manifest list live; defaults to `ghcr.io/whatwedo` |
| `REGISTRY_MIRRORS` | Space-separated copy targets; defaults to the whatwedo registry and Docker Hub |
| `IMAGES_FILE` | Manifest to read; defaults to `images.conf` |

## Registries

ghcr.io is the build registry: the architecture tags and the merged manifest list are created there, and the finished image is copied to the other two. Copying preserves the index, so the digests are identical in all three registries.

| Registry | Role | Credentials in Actions |
|---|---|---|
| `ghcr.io/whatwedo` | Architecture tags and manifest list | `GITHUB_TOKEN`, no secret needed |
| `registry.whatwedo.ch/whatwedo/docker-base-images` | Copy of the finished image | `WWD_REGISTRY_USER` / `WWD_REGISTRY_TOKEN` |
| `whatwedo` (Docker Hub) | Copy of the finished image | `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` |

`update-readme.sh` updates and verifies the Docker Hub description for every image in `images.conf`. It requires Python 3. The Docker Hub user needs repository admin access for this metadata operation; personal access tokens need Read, Write & Delete scope. Image pushes alone require Read & Write. The workflow passes `DOCKERHUB_TOKEN` as `DOCKERHUB_PASSWORD` to the script.

The workflow uses `GITHUB_TOKEN` for ghcr.io. Existing packages must grant this repository **Admin** under **Package settings → Manage Actions access**, or inherit equivalent access from the linked repository. Linking the source repository alone does not guarantee Actions access. Admin access is required to remove the temporary package versions during cleanup.

`mirror` uses [regctl](https://github.com/regclient/regclient), because `imagetools` cannot copy blobs across registries. The binary is downloaded to `.tools/` on first use; its version is pinned in `build.sh` and updated manually.

GHCR does not implement the Registry API's manifest deletion. Its cleanup helper first moves each architecture tag to a unique empty placeholder, then deletes only that placeholder through the GitHub Packages API. It verifies that the published index and both architecture manifests remain available. Other registries use `regctl tag delete`. GHCR cleanup requires Python 3, `gh` and a token in `GH_TOKEN` (set automatically by the workflow). Cleanup runs in a separate job after all images have been mirrored, and can be retried independently.

To try a single-architecture push against a throwaway local registry, first install the regctl release pinned by `REGCTL_VERSION` in `build.sh` for your OS and architecture as the executable `.tools/regctl`. The `mirror` and `cleanup` commands download it on first use, but `push` does not install it. This example calls it directly to configure plain HTTP before pushing:

```bash
./build.sh check base
docker run -d -p 5001:5000 --name local-registry registry:3
.tools/regctl registry set --tls disabled localhost:5001
REGISTRY_BUILD=localhost:5001 ./build.sh push base
```
