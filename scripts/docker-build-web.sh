#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
D=$(date +'%Y%m%d.%H%M%S%3N')

cd "${SCRIPT_DIR}/.."
# Build the apk inside the image
docker build \
    -t thunder-builder \
    -f ./docker/DockerfileWeb .
