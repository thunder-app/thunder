#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}/.."
docker build \
    -t thunder-web \
    -f ./docker/DockerfileWeb .
