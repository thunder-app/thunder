#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker run --rm -ti --net host --name thunder-dev thunder-builder bash -c 'flutter devices && flutter run'
