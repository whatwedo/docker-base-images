#!/bin/sh

# Exit on error
set -e

# Configuration
DIR="$(dirname "$SCRIPT")"
BUILD_ORDER_FILE=$DIR/build_order
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD | sed  's/\//-/g'`
DATE=`date +%Y%m%d`
export DOCKER_BUILDKIT=1

# Build single image
build_image() {
    # Configuration
    IMAGE_NAME=$1
    IMAGE_DIR=$DIR/images/$IMAGE_NAME
    FULL_IMAGE_NAME=whatwedo/$IMAGE_NAME:$GIT_BRANCH

    # Build image
    echo Building image $FULL_IMAGE_NAME
    rm -rf $IMAGE_DIR/shared
    cp -R $DIR/shared $IMAGE_DIR
    docker build --network host -t $FULL_IMAGE_NAME --build-arg VERSION=$GIT_BRANCH $IMAGE_DIR

    # Test image
    echo Testing image $IMAGE_NAME
    CID=`docker run -d --rm $FULL_IMAGE_NAME`
    docker exec $CID goss validate --retry-timeout 30s --sleep 1s
    docker kill $CID
}

# Push single image
push_image() {
    # Configuration
    IMAGE_NAME=$1
    FULL_IMAGE_NAME=whatwedo/$IMAGE_NAME:$GIT_BRANCH
    FULL_IMAGE_NAME_DATE=$FULL_IMAGE_NAME-$DATE
    FULL_IMAGE_NAME_MIRROR=registry.whatwedo.ch/whatwedo/docker-base-images/$IMAGE_NAME:$GIT_BRANCH

    # Tag
    docker tag $FULL_IMAGE_NAME $FULL_IMAGE_NAME_DATE
    docker tag $FULL_IMAGE_NAME $FULL_IMAGE_NAME_MIRROR

    # Push image
    echo Pushing image $FULL_IMAGE_NAME
    docker push $FULL_IMAGE_NAME
    docker push $FULL_IMAGE_NAME_DATE
    docker push $FULL_IMAGE_NAME_MIRROR
}

# Push single image
mirror_image() {
    # Configuration
    IMAGE_NAME=$1
    FULL_IMAGE_NAME=whatwedo/$IMAGE_NAME:$GIT_BRANCH
    FULL_IMAGE_NAME_MIRROR=registry.whatwedo.ch/whatwedo/docker-base-images/$IMAGE_NAME:$GIT_BRANCH

    # Tag
    docker tag $FULL_IMAGE_NAME $FULL_IMAGE_NAME_MIRROR

    # Push image
    echo Pushing image $FULL_IMAGE_NAME
    docker push $FULL_IMAGE_NAME_MIRROR
}

# Building all images
build_all() {
    echo Building all images
    while read IMAGE_NAME; do
        build_image $IMAGE_NAME
    done < $BUILD_ORDER_FILE
}

# Pushing all images
push_all() {
    echo Pushing all images
    while read IMAGE_NAME; do
        push_image $IMAGE_NAME
    done < $BUILD_ORDER_FILE
}

# Mirror all images
mirror_all() {
    echo Mirror all images
    while read IMAGE_NAME; do
        mirror_image $IMAGE_NAME
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
  ./build.sh --mirror                            - Mirror all images to registry.whatwedo.ch
  ./build.sh --help                              - Display this message
  "
}

if [[ "$@" == "--help" ]]; then
    help
elif [[ $# -eq 1 ]] && [[ "$1" != "--mirror" ]]; then
    mirror_all
elif [[ $# -eq 1 ]] && [[ "$1" != "--push" ]]; then
    build_image $1
elif [[ $# -eq 2 ]] && [[ "$2" == "--push" ]]; then
    build_image $1
    push_image $1
elif [[ $# -eq 0 ]]; then
    build_all
elif [[ $# -eq 1 ]] && [[ "$1" == "--push" ]]; then
    build_all
    push_all
else
	help
fi
