#!/bin/bash
set -euo pipefail

IMAGE=${1:?Usage: tests/php-imagick-pdf.sh IMAGE}

# Feed the fixture through stdin so this also works with a remote Docker daemon.
docker run --rm -i --network none \
    --cap-drop=ALL --security-opt=no-new-privileges \
    "$IMAGE" php <<'PHP'
<?php
// Build a one-page PDF without relying on another PDF library or installed fonts.
$content = "0 0 1 rg\n10 10 80 80 re f\n";
$objects = [
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 100 100] /Resources << >> /Contents 4 0 R >>',
    '<< /Length ' . strlen($content) . ">>\nstream\n" . $content . 'endstream',
];
$pdf = "%PDF-1.4\n";
$offsets = [];
foreach ($objects as $index => $object) {
    $offsets[] = strlen($pdf);
    $pdf .= ($index + 1) . " 0 obj\n" . $object . "\nendobj\n";
}
$xref = strlen($pdf);
$pdf .= "xref\n0 5\n0000000000 65535 f \n";
foreach ($offsets as $offset) {
    $pdf .= sprintf("%010d 00000 n \n", $offset);
}
$pdf .= "trailer\n<< /Size 5 /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n";

$image = new Imagick();
$image->setResolution(72, 72);
$image->readImageBlob($pdf);
if ($image->getNumberImages() !== 1 || $image->getImageWidth() !== 100 || $image->getImageHeight() !== 100) {
    throw new RuntimeException('Expected one rendered PDF page of 100 x 100 pixels.');
}
$pixel = $image->getImagePixelColor(50, 50)->getColor();
if ($pixel['r'] !== 0 || $pixel['g'] !== 0 || $pixel['b'] !== 255) {
    throw new RuntimeException('Expected a blue pixel in the rendered PDF rectangle.');
}
$image->setImageFormat('png');
if (!str_starts_with($image->getImageBlob(), "\x89PNG\r\n\x1a\n")) {
    throw new RuntimeException('Expected a PNG thumbnail of the rendered PDF.');
}
echo "Imagick PDF rendering passed.\n";
PHP
