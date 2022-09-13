#!/bin/sh

# Exit on error
set -e

# Configuration
DIR="$(dirname "$SCRIPT")"
BUILD_ORDER_FILE=$DIR/build_order
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD | sed  's/\//-/g'`
DATE=`date +%Y%m%d`
export DOCKER_BUILDKIT=1




config() {
    # Configuration
    IMAGE_NAME=$1
    IMAGE_DIR=$DIR/images/$IMAGE_NAME
    FULL_IMAGE_NAME=$IMAGE_NAME:$GIT_BRANCH
    FULL_IMAGE_NAME_DOCKER=whatwedo/$FULL_IMAGE_NAME
    FULL_IMAGE_NAME_WWD=registry.whatwedo.ch/whatwedo/docker-base-images/$FULL_IMAGE_NAME
    PLATFORMS="linux/amd64"
}

check_image_dir_exists() {
    if [ ! -d "$IMAGE_DIR" ]; then
        tput setaf 1
        echo "[ERROR] Image does not exist!"
        tput sgr0
        exit 1
    fi
}


# The build_multiarch function will generate images for the needed architectures. It uses `docker buildx build` and will automatically PUSH THE IMAGE!
build_multiarch() {
    echo "[INFO] Selecting build-container"
    if ! grep whatwedo-builder <(docker buildx inspect --bootstrap); then docker buildx create --name whatwedo-builder; fi
    docker buildx use whatwedo-builder

    check_image_dir_exists

    echo "[INFO] Building and pushing image: $FULL_IMAGE_NAME"
    rm -rf $IMAGE_DIR/shared
    cp -R $DIR/shared $IMAGE_DIR

    # Build and push image to whatwedo
    echo "Currently building: $FULL_IMAGE_NAME_WWD"
    docker buildx build --no-cache \
        -t $FULL_IMAGE_NAME_WWD \
        --platform $PLATFORMS \
        --build-arg VERSION=$GIT_BRANCH \
        --push \
        $IMAGE_DIR

    # Build and push image to docker.io
    echo "Currently building: $FULL_IMAGE_NAME_DOCKER"
    docker buildx build --no-cache \
        -t $FULL_IMAGE_NAME_DOCKER \
        --platform $PLATFORMS \
        --build-arg VERSION=$GIT_BRANCH \
        --push \
        $IMAGE_DIR
}

# To test the image it will use the normal way of building docker images via `docker build`
test() {
    echo "[INFO] Locally building and testing image: $FULL_IMAGE_NAME"

    check_image_dir_exists

    rm -rf $IMAGE_DIR/shared
    cp -R $DIR/shared $IMAGE_DIR

    # Build image
    docker build --no-cache \
        -t $FULL_IMAGE_NAME_DOCKER \
        --build-arg VERSION=$GIT_BRANCH \
        $IMAGE_DIR

    # Test image
    echo "[INFO] Testing image: $FULL_IMAGE_NAME_DOCKER"
    CID=`docker run -d --rm $FULL_IMAGE_NAME_DOCKER`
    docker exec $CID goss validate --retry-timeout 30s --sleep 1s
    docker kill $CID
}


test_all() {
    echo "[INFO] Testing all images locally"
    while read IMAGE_NAME; do
        config $IMAGE_NAME
        test
    done < $BUILD_ORDER_FILE
}

build_all() {
    echo "[INFO] Building and pushing all images"
    while read IMAGE_NAME; do
        config $IMAGE_NAME
        build_multiarch
    done < $BUILD_ORDER_FILE
}




# Display help
help() {
    echo "
  build.sh is a script for building docker images in this repository.

  In order to use the build command you will need to create a builder.
  Check the README for more info on how to create and configure said builder!

  USAGE:
  ./build.sh test                                - Build and test all images locally
  ./build.sh test [image-name]                   - Build and test the image locally
  ./build.sh build                               - Build all images for multiple architectures and push them directly
  ./build.sh build [image-name]                  - Build the image for multiple architectures and push it directly
  ./build.sh --help                              - Display this message
  "
}




# ./build.sh --help
if [[ "$@" == "--help" ]]; then
    help

# ./build.sh test [image-name]
elif [[ $# -eq 2 ]] && [[ "$1" == "test" ]]; then
    config $2
    test

# ./build.sh build [image-name]
elif [[ $# -eq 2 ]] && [[ "$1" == "build" ]]; then
    config $2
    build_multiarch

# ./build.sh test
elif [[ $# -eq 1 ]] && [[ "$1" == "test" ]]; then
    test_all

# ./build.sh build
elif [[ $# -eq 1 ]] && [[ "$1" == "build" ]]; then
    build_all

# ./build.sh
else
	help
fi
