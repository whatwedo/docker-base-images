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
IMAGE_REPO=whatwedo/$IMAGE_NAME

# Build
docker build -t $IMAGE_REPO:$TAG --build-arg BASE_IMAGE_TAG=$TAG --no-cache $IMAGE_DIR
