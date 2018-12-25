#!/usr/bin/env bash

# Exit on error
set -e

# Preparation
if [[ $# -lt 1 ]]; then
    echo 'Usage ./build-all.sh [tag] [--push]'
    exit 1
fi

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TAG=$1
BUILD_ORDER_FILE=$DIR/../build_order

# Build
while read image; do
    echo Building $image image
    $DIR/build-image.sh $image $TAG $2
done < $BUILD_ORDER_FILE
