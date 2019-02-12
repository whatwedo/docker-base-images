#!/bin/sh

# Exit on error
set -e

# Configuration
[ -z "$DOCKERHUB_USERNAME" ] && echo "Need to set DOCKERHUB_USERNAME" && exit 1
[ -z "$DOCKERHUB_PASSWORD" ] && echo "Need to set DOCKERHUB_PASSWORD" && exit 1
DIR="$(dirname "$SCRIPT")"

# Update all README's
# for IMAGE_DIR in $(find $DIR/images/* -maxdepth 1 -type f -name README.md -exec dirname {} \;); do
#     IMAGE_NAME=${IMAGE_DIR##*/}
#     echo Upating README of $IMAGE_NAME
#     # echo docker run --rm -v $IMAGE_DIR/README.md:/data/README.md -e DOCKERHUB_USERNAME=$DOCKERHUB_USERNAME -e DOCKERHUB_PASSWORD=$DOCKERHUB_PASSWORD -e DOCKERHUB_REPO_PREFIX=whatwedo -e DOCKERHUB_REPO_NAME=$IMAGE_NAME sheogorath/readme-to-dockerhub
# done

# Update given README's
for IMAGE in "nginx-php" "php" "yarn"; do
    echo Upating README of $IMAGE
    echo docker run --rm -v `pwd`/images/$IMAGE/README.md:/data/README.md -e DOCKERHUB_USERNAME=$DOCKERHUB_USERNAME -e DOCKERHUB_PASSWORD=$DOCKERHUB_PASSWORD -e DOCKERHUB_REPO_PREFIX=whatwedo -e DOCKERHUB_REPO_NAME=$IMAGE sheogorath/readme-to-dockerhub
done

# if [[ "$IMAGE_NAME" =~ ^(base|symfony2|symfony3|symfony4|nginx)$ ]]; then
