#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
FLUTTER_VERSION=3.47.2
FLUTTER_REVISION=d3b14c876900e553bc736ca19295fc09e3853e8e
DART_VERSION=3.13.2
LINUX_ARCHIVE_SHA256=447878859d01ca9bfdb99a85f245af07ed8a15fedcd9d189c4749e8e92d1f185

check_contains() {
    local path=$1
    local expected=$2

    if ! grep -Fq -- "$expected" "$REPOSITORY_ROOT/$path"; then
        echo "$path does not contain expected Flutter version data: $expected" >&2
        return 1
    fi
}

actual_revision=$(git -C "$REPOSITORY_ROOT/flutter" rev-parse HEAD)
actual_version=$(git -C "$REPOSITORY_ROOT/flutter" describe --tags --exact-match)
actual_dart_version=$("$REPOSITORY_ROOT/flutter/bin/dart" --version 2>&1)

if [[ "$actual_revision" != "$FLUTTER_REVISION" ]]; then
    echo "flutter submodule revision is $actual_revision, expected $FLUTTER_REVISION" >&2
    exit 1
fi

if [[ "$actual_version" != "$FLUTTER_VERSION" ]]; then
    echo "flutter submodule version is $actual_version, expected $FLUTTER_VERSION" >&2
    exit 1
fi

if [[ "$actual_dart_version" != "Dart SDK version: $DART_VERSION "* ]]; then
    echo "flutter submodule reports $actual_dart_version, expected Dart $DART_VERSION" >&2
    exit 1
fi

check_contains .metadata "revision: \"$FLUTTER_REVISION\""
check_contains pubspec.yaml "sdk: ^$DART_VERSION"
check_contains pubspec.yaml "flutter: \">=$FLUTTER_VERSION <4.0.0\""
check_contains pubspec.lock "dart: \">=$DART_VERSION <4.0.0\""
check_contains pubspec.lock "flutter: \">=$FLUTTER_VERSION <4.0.0\""
check_contains .fvmrc "\"flutter\": \"$FLUTTER_VERSION\""
check_contains .vscode/settings.json "\"dart.flutterSdkPath\": \"flutter\""
check_contains docker/Dockerfile "ARG FLUTTER_VERSION=$FLUTTER_VERSION"
check_contains docker/Dockerfile 'ARG FLUTTER_BUILD_PLATFORM=linux/amd64'
check_contains docker/Dockerfile 'flutter_linux_${FLUTTER_VERSION}-stable.tar.xz'
check_contains docker/Dockerfile "$LINUX_ARCHIVE_SHA256"
check_contains docker/Dockerfile 'sdkmanager --install "platforms;android-36"'
check_contains docker/Dockerfile 'sdkmanager --install "ndk;28.2.13676358"'
check_contains docker/DockerfileWeb "ARG FLUTTER_VERSION=$FLUTTER_VERSION"
check_contains docker/DockerfileWeb 'ARG FLUTTER_BUILD_PLATFORM=linux/amd64'
check_contains docker/DockerfileWeb 'flutter_linux_${FLUTTER_VERSION}-stable.tar.xz'
check_contains docker/DockerfileWeb "$LINUX_ARCHIVE_SHA256"
check_contains docker/DockerfileWeb 'safe.directory /usr/local/flutter'
check_contains .dockerignore 'flutter'
check_contains README.md './flutter/bin/flutter pub get'
check_contains scripts/build.dart "Platform.environment['FLUTTER_EXECUTABLE'] ?? 'flutter/bin/flutter'"
check_contains scripts/build-android.dart "Platform.environment['FLUTTER_EXECUTABLE'] ?? 'flutter/bin/flutter'"
check_contains scripts/build-and-serve-web.sh './flutter/bin/flutter build web --wasm'
check_contains scripts/docker-build-android.sh 'FLUTTER_EXECUTABLE=/opt/flutter/bin/flutter'
check_contains .github/workflows/ci.yml './scripts/check-flutter-version.sh'
check_contains .github/workflows/release.yml './scripts/check-flutter-version.sh'

echo "Flutter version sources are aligned on $FLUTTER_VERSION."
