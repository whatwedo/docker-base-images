#!/bin/bash

# Exit on errors, unset variables and failed pipeline commands
set -euo pipefail

# Configuration
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_FILE="${IMAGES_FILE:-$DIR/images.conf}"
# ghcr.io attaches a package to its repository through this source reference
SOURCE_REPO=https://github.com/whatwedo/docker-base-images
# A pull request checkout is a merge commit without a usable branch name, so CI passes
# the version in and only a local run falls back to the branch
VERSION="${VERSION:-$(git rev-parse --abbrev-ref HEAD | sed 's/\//-/g')}"
# Architecture tags and the manifest list live here, the mirrors receive a copy
REGISTRY_BUILD="${REGISTRY_BUILD:-ghcr.io/whatwedo}"
REGISTRY_MIRRORS="${REGISTRY_MIRRORS:-registry.whatwedo.ch/whatwedo/docker-base-images whatwedo}"
REGCTL_VERSION=v0.11.5
export DOCKER_BUILDKIT=1


manifest_rows() {
    sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$IMAGES_FILE"
}


image_names() {
    manifest_rows | awk '{print $1}'
}


# A parent listed below its child would make the build order a lie
validate_manifest() {
    local seen=" " image parent
    while read -r image parent _; do
        if [ "$parent" != "-" ] && [[ "$seen" != *" $parent "* ]]; then
            echo "[ERROR] $image is listed before its parent $parent" >&2
            exit 1
        fi
        seen+="$image "
    done < <(manifest_rows)
}


manifest_field() {
    local requested="$1" field="$2" row
    row="$(manifest_rows | awk -v name="$requested" '$1 == name' | tr -s ' ')"
    if [ -z "$row" ]; then
        echo "[ERROR] Unknown image: $requested" >&2
        exit 1
    fi
    case "$field" in
        parent) cut -d' ' -f2 <<< "$row" ;;
        health) cut -d' ' -f3 <<< "$row" ;;
        tests)  cut -d' ' -f4- <<< "$row" ;;
    esac
}


list() {
    validate_manifest
    image_names
}


info() {
    local requested="$1"
    # Outside a command substitution, so an unknown image can still abort
    manifest_field "$requested" parent >/dev/null
    echo "parent: $(manifest_field "$requested" parent)"
    echo "health: $(manifest_field "$requested" health)"
    echo "tests: $(manifest_field "$requested" tests)"
}


config() {
    # Configuration
    local requested_image="$1"
    validate_manifest
    manifest_field "$requested_image" parent >/dev/null

    IMAGE_NAME="$requested_image"
    IMAGE_DIR="$DIR/images/$IMAGE_NAME"
    FULL_IMAGE_NAME=$IMAGE_NAME:$VERSION
    FULL_IMAGE_NAME_DOCKER=whatwedo/$FULL_IMAGE_NAME
}


check_image_dir_exists() {
    if [ ! -d "$IMAGE_DIR" ]; then
        echo "[ERROR] Image directory does not exist: $IMAGE_DIR" >&2
        exit 1
    fi
}


prepare_shared() {
    check_image_dir_exists
    rm -rf -- "$IMAGE_DIR/shared"
    cp -R "$DIR/shared" "$IMAGE_DIR"
}


build_image() {
    prepare_shared

    local build_date
    build_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    echo "[INFO] Building image: $FULL_IMAGE_NAME_DOCKER"
    # Attestations would turn a single-platform build into an index, which the later
    # imagetools merge cannot use as a source
    docker build --no-cache --provenance=false \
        -t "$FULL_IMAGE_NAME_DOCKER" \
        --build-arg "VERSION=$VERSION" \
        --build-arg "BUILD_DATE=$build_date" \
        --label "org.opencontainers.image.source=$SOURCE_REPO" \
        "$IMAGE_DIR"
}


test_image() {
    echo "[INFO] Testing image: $FULL_IMAGE_NAME_DOCKER"

    local healthcheck has_healthcheck=true
    healthcheck="$(docker image inspect \
        --format '{{if .Config.Healthcheck}}{{index .Config.Healthcheck.Test 0}}{{end}}' \
        "$FULL_IMAGE_NAME_DOCKER")"
    case "$healthcheck" in
        ''|NONE) has_healthcheck=false ;;
    esac

    local wants_healthcheck
    wants_healthcheck="$(manifest_field "$IMAGE_NAME" health)"
    if [ "$wants_healthcheck" = yes ] && [ "$has_healthcheck" != true ]; then
        echo "[ERROR] $IMAGE_NAME must define a service health check" >&2
        return 1
    fi
    if [ "$wants_healthcheck" = no ] && [ "$has_healthcheck" = true ]; then
        echo "[ERROR] $IMAGE_NAME must not inherit a supervisor-specific health check" >&2
        return 1
    fi

    local suite
    for suite in $(manifest_field "$IMAGE_NAME" tests); do
        run_suite "$suite"
    done
}


run_suite() {
    case "$1" in
        goss)
            local cid
            cid="$(docker run -d --rm "$FULL_IMAGE_NAME_DOCKER")"
            if ! docker exec "$cid" goss validate --retry-timeout 30s --sleep 1s; then
                docker logs "$cid" || true
                docker stop --time 10 "$cid" >/dev/null || true
                return 1
            fi
            docker stop --time 10 "$cid" >/dev/null
            ;;
        imagick-pdf)
            "$DIR/tests/php-imagick-pdf.sh" "$FULL_IMAGE_NAME_DOCKER"
            ;;
        http-security)
            # symfony serves from a public/ subdirectory and has to deny two more paths
            case "$IMAGE_NAME" in
                nginx)
                    "$DIR/tests/php-http-security.sh" --no-php "$FULL_IMAGE_NAME_DOCKER" /var/www
                    ;;
                symfony)
                    "$DIR/tests/php-http-security.sh" "$FULL_IMAGE_NAME_DOCKER" /var/www/public \
                        secret.php secret.php/path-info
                    ;;
                *)
                    "$DIR/tests/php-http-security.sh" "$FULL_IMAGE_NAME_DOCKER" /var/www
                    ;;
            esac
            ;;
        runtime)
            "$DIR/tests/symfony-runtime.sh" "$FULL_IMAGE_NAME_DOCKER"
            ;;
        *)
            echo "[ERROR] Unknown test suite: $1" >&2
            return 1
            ;;
    esac
}


check_image() {
    build_image
    test_image
}


arch_tag() {
    local arch="${ARCH:-$(docker version --format '{{.Server.Arch}}')}"
    echo "$REGISTRY_BUILD/$IMAGE_NAME:$VERSION-$arch"
}


# imagetools cannot copy blobs across registries
ensure_regctl() {
    REGCTL="$DIR/.tools/regctl"
    [ -x "$REGCTL" ] && return

    local os=linux arch=amd64
    [ "$(uname -s)" = Darwin ] && os=darwin
    case "$(uname -m)" in
        aarch64|arm64) arch=arm64 ;;
    esac

    echo "[INFO] Downloading regctl $REGCTL_VERSION"
    mkdir -p "$DIR/.tools"
    curl -fsSL -o "$REGCTL" \
        "https://github.com/regclient/regclient/releases/download/$REGCTL_VERSION/regctl-$os-$arch"
    chmod +x "$REGCTL"
}


push_image() {
    local target
    target="$(arch_tag)"
    echo "[INFO] Pushing $target"
    docker tag "$FULL_IMAGE_NAME_DOCKER" "$target"
    docker push "$target"
}


merge_image() {
    echo "[INFO] Merging architectures into $REGISTRY_BUILD/$FULL_IMAGE_NAME"
    docker buildx imagetools create \
        -t "$REGISTRY_BUILD/$FULL_IMAGE_NAME" \
        "$REGISTRY_BUILD/$IMAGE_NAME:$VERSION-amd64" \
        "$REGISTRY_BUILD/$IMAGE_NAME:$VERSION-arm64"
}


mirror_image() {
    ensure_regctl
    local mirror
    for mirror in $REGISTRY_MIRRORS; do
        echo "[INFO] Mirroring to $mirror/$FULL_IMAGE_NAME"
        "$REGCTL" image copy "$REGISTRY_BUILD/$FULL_IMAGE_NAME" "$mirror/$FULL_IMAGE_NAME"
    done
}


# Removes the tag without touching the manifest the merged index points at
cleanup_image() {
    ensure_regctl
    if [[ "$REGISTRY_BUILD" == ghcr.io/* ]]; then
        python3 "$DIR/scripts/cleanup-ghcr.py" "$REGCTL" "$REGISTRY_BUILD/$IMAGE_NAME" "$VERSION"
        return
    fi
    local arch
    for arch in amd64 arm64; do
        echo "[INFO] Removing $REGISTRY_BUILD/$IMAGE_NAME:$VERSION-$arch"
        "$REGCTL" tag delete "$REGISTRY_BUILD/$IMAGE_NAME:$VERSION-$arch"
    done
}


run_all() {
    local command="$1" image_name
    validate_manifest
    while IFS= read -r image_name; do
        config "$image_name"
        "$command"
    done < <(image_names)
}




# Display help
help() {
    echo "
  build.sh builds, tests and publishes the docker images in this repository.
  images.conf lists every image with its parent, health check contract and test suites.
  Without an image name a command runs over all images, in build order.

  USAGE:
  ./build.sh list                  - Print the build order
  ./build.sh info <image-name>     - Print what the manifest says about an image
  ./build.sh build [image-name]    - Build an image for the local architecture
  ./build.sh test [image-name]     - Test an image that has already been built
  ./build.sh check [image-name]    - Build and test in one go
  ./build.sh --help                - Display this message

  The following commands need registry access, see build.md:
  ./build.sh push [image-name]     - Push a tested image under its architecture tag
  ./build.sh merge [image-name]    - Combine both architecture tags into one manifest list
  ./build.sh mirror [image-name]   - Copy the merged image to the mirror registries
  ./build.sh cleanup [image-name]  - Remove the architecture tags again
  "
}




case "${1:-help}" in
    list)  list ;;
    info)  info "${2:?Usage: build.sh info IMAGE}" ;;
    build) if [ $# -eq 2 ]; then config "$2"; build_image; else run_all build_image; fi ;;
    test)  if [ $# -eq 2 ]; then config "$2"; test_image;  else run_all test_image;  fi ;;
    check) if [ $# -eq 2 ]; then config "$2"; check_image; else run_all check_image; fi ;;
    push)    if [ $# -eq 2 ]; then config "$2"; push_image;    else run_all push_image;    fi ;;
    merge)   if [ $# -eq 2 ]; then config "$2"; merge_image;   else run_all merge_image;   fi ;;
    mirror)  if [ $# -eq 2 ]; then config "$2"; mirror_image;  else run_all mirror_image;  fi ;;
    cleanup) if [ $# -eq 2 ]; then config "$2"; cleanup_image; else run_all cleanup_image; fi ;;
    *)     help ;;
esac
