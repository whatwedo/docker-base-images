#!/usr/bin/env bash

# Exit on error
set -e

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_ORDER_FILE=$DIR/build_order
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
export DOCKER_BUILDKIT=1

# Build single image
build-image() {
    # Configuration
    IMAGE_NAME=$1
    IMAGE_DIR=$DIR/images/$IMAGE_NAME
    FULL_IMAGE_NAME=whatwedo/$IMAGE_NAME:$GIT_BRANCH

    # Build image
    echo Building image $FULL_IMAGE_NAME
    rm -rf $IMAGE_DIR/shared
    cp -R $DIR/shared $IMAGE_DIR
    docker build -t $FULL_IMAGE_NAME --build-arg BASE_IMAGE_TAG=$GIT_BRANCH $IMAGE_DIR

    # Test image
    echo Testing image $IMAGE_NAME
    CID=`docker run -d --rm $FULL_IMAGE_NAME`
    docker exec $CID goss validate --retry-timeout 30s --sleep 1s
    docker kill $CID
}

# Push single image
push-image() {
    # Configuration
    IMAGE_NAME=$1
    FULL_IMAGE_NAME=whatwedo/$IMAGE_NAME:$GIT_BRANCH

    # Push image
    echo Pushing image $FULL_IMAGE_NAME
    docker push $FULL_IMAGE_NAME
}

# Building all images
build-all() {
    echo Building all images
    while read IMAGE_NAME; do
        build-image $IMAGE_NAME
    done < $BUILD_ORDER_FILE
}

# Pushing all images
push-all() {
    echo Pushing all images
    while read IMAGE_NAME; do
        push-image $IMAGE_NAME
    done < $BUILD_ORDER_FILE
}

# Display help
help() {
    echo "
  build.sh is a script for building docker images in this repository.

  USAGE:
  ./build.sh [image-name]                        - Build given image
  ./build.sh [image-name] --push                 - Build and push given image
  ./build.sh                                     - Build all images
  ./build.sh --push                              - Build and push all images
  ./build.sh --help                              - Display this message
  "
}

if [[ "$@" == "--help" ]]; then
    help
elif [[ $# -eq 1 ]] && [[ "$1" != "--push" ]]; then
    build-image $1
elif [[ $# -eq 2 ]] && [[ "$2" == "--push" ]]; then
    build-image $1
    push-image $1
elif [[ $# -eq 0 ]]; then
    build-all
elif [[ $# -eq 1 ]] && [[ "$1" == "--push" ]]; then
    build-all
    push-all
else
	help
fi
