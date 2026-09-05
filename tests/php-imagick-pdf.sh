#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE=${1:?Usage: tests/php-imagick-pdf.sh IMAGE}

# Feed the fixture through stdin so this also works with a remote Docker daemon.
docker run --rm -i --network none \
    --cap-drop=ALL --security-opt=no-new-privileges \
    "$IMAGE" php < "$DIR/fixtures/imagick-pdf.php"
