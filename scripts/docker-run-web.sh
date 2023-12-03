#!/usr/bin/env bash

# This script runs thunder-web docker image after it is built using the docker-build-web.sh script.

# Go to http://localhost:8080/ to view the app.

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}/.."
docker run -d -p 8080:80 \
    --name thunder-web thunder-web
