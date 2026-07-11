#!/bin/bash

set -euo pipefail

IMAGE=go60-zmk-config
FIRMWARE_REF=db2ba9fcd3dec4c7afcf171f123585a9f8292595

docker build -t "$IMAGE" .
docker run --rm -v "$PWD:/config" -e UID="$(id -u)" -e GID="$(id -g)" -e FIRMWARE_REF="$FIRMWARE_REF" "$IMAGE"
./render-layers
