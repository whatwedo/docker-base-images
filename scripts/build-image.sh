#!/usr/bin/env bash

# Exit on error
set -e

# Preparation
if [[ $# -lt 2 ]]; then
    echo 'Usage ./build-image.sh [image-name] [tag] [--push]'
    exit 1
fi

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGE_NAME=$1
TAG=$2
IMAGE_DIR=$DIR/../images/$IMAGE_NAME
FULL_IMAGE_NAME=whatwedo/$IMAGE_NAME:$TAG

# Build
rm -rf $IMAGE_DIR/shared
cp -R $DIR/../shared $IMAGE_DIR
docker build -t $FULL_IMAGE_NAME --build-arg BASE_IMAGE_TAG=$TAG --no-cache $IMAGE_DIR
rm -rf $IMAGE_DIR/shared

# Test
CID=`docker run -d --rm $FULL_IMAGE_NAME sh -c "[[ -e /sbin/upstart ]] && /sbin/upstart || while true; do echo Waiting...; sleep 2; done"`
docker exec $CID goss validate --retry-timeout 30s --sleep 1s
docker kill $CID

# Push
if [ "$3" = "--push" ]; then
    docker push $FULL_IMAGE_NAME
fi
