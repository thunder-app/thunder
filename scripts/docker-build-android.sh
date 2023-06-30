#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
D=$(date +'%Y%m%d.%H%M%S%3N')

cd "${SCRIPT_DIR}/.."
# Build the apk inside the image
docker build \
    -t thunder-builder \
    -f ./docker/Dockerfile \
    . &&\
# Copy the APK out of the image
mkdir -p ./build/app/outputs/apk/release &&\
docker cp $(docker create --name tb thunder-builder):/build/build/app/outputs/apk/release/app-release.apk ./build/app/outputs/apk/release/app-release.${D}.apk && docker rm tb >/dev/null
