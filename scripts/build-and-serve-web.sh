#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PORT="${1:-8080}"

cd "${SCRIPT_DIR}/.."

./flutter/bin/flutter pub get
./flutter/bin/flutter gen-l10n
./flutter/bin/flutter build web --wasm
python3 "${SCRIPT_DIR}/serve-web.py" --port "${PORT}"
