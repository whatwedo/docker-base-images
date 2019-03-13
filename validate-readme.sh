#!/bin/sh

# Exit on error
set -e

# Validating main README
echo Validating main README
docker run --rm -i paasmule/markdown-link-check < README.md

# Validating all README's
for IMAGE_DIR in $(find ./images/* -maxdepth 1 -type f -name README.md -exec dirname {} \;); do
    IMAGE_NAME=${IMAGE_DIR##*/}
    echo Validating README of $IMAGE_NAME
    docker run --rm -i paasmule/markdown-link-check < images/$IMAGE_NAME/README.md
done
