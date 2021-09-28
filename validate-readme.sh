#!/bin/sh

# Exit on error
set -e

# Validating main README
echo Validating main README
docker run -v ${PWD}:/data:ro --rm -i ghcr.io/tcort/markdown-link-check:stable /data/README.md
