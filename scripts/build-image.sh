#!/usr/bin/env bash

# Exit on error
set -e

# Preparation
if [[ $# -ne 2 ]]; then
    echo 'Usage ./build-image.sh [image-name] [tag]'
    exit 1
fi

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGE_NAME=$1
TAG=$2
IMAGE_DIR=$DIR/../images/$IMAGE_NAME

# Build
rm -rf $IMAGE_DIR/shared
cp -R $DIR/../shared $IMAGE_DIR
docker build -t whatwedo/$IMAGE_NAME:$TAG --build-arg BASE_IMAGE_TAG=$TAG --no-cache $IMAGE_DIR
rm -rf $IMAGE_DIR/shared
