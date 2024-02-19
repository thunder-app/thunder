#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
D=$(date +'%Y%m%d.%H%M%S%3N')

set -e

cd "${SCRIPT_DIR}/.."
# Create the builder image
docker build \
    -t thunder-builder \
    -f ./docker/Dockerfile \
    --build-arg="DEV_UID=$(id -u)" \
    .

# Check docker build folder
mkdir -p ./build/docker/flutter/gradle/build
mkdir -p ./build/docker/flutter/gradle/.gradle

# Create keystore
if [ ! -f ./android/app/keystore.jks ]; then
    docker run --rm -ti --user "$(id -u)" -e "HOME=/home/builder" --name thunder-builder -v "${PWD}:${PWD}" -v "${PWD}/build/docker:/home/builder" -v "${PWD}/build/docker/flutter/gradle/build:/opt/flutter/packages/flutter_tools/gradle/build"  -v "${PWD}/build/docker/flutter/gradle/.gradle:/opt/flutter/packages/flutter_tools/gradle/.gradle" -w "${PWD}" thunder-builder keytool -genkey -v -keystore ./android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias thunderdev -keypass password -storepass password -srcstorepass password -noprompt -dname "cn=First Last, ou=Java, o=Oracle, c=US"
fi

# Make key properties
if [ ! -f ./android/key.properties ]; then
    echo '
storePassword=password
keyPassword=password
keyAlias=thunderdev
storeFile=keystore.jks
' > ./android/key.properties
fi


# Build the APK
if [ ! -d ./build/docker/.pub-cache ]; then
    docker run --rm -ti --user "$(id -u)" -e "HOME=/home/builder" --name thunder-builder -v "${PWD}:${PWD}" -v "${PWD}/build/docker:/home/builder" -v "${PWD}/build/docker/flutter/gradle/build:/opt/flutter/packages/flutter_tools/gradle/build"  -v "${PWD}/build/docker/flutter/gradle/.gradle:/opt/flutter/packages/flutter_tools/gradle/.gradle" -w "${PWD}" thunder-builder bash -ic 'flutter pub get'
    docker run --rm -ti --user "$(id -u)" -e "HOME=/home/builder" --name thunder-builder -v "${PWD}:${PWD}" -v "${PWD}/build/docker:/home/builder" -v "${PWD}/build/docker/flutter/gradle/build:/opt/flutter/packages/flutter_tools/gradle/build"  -v "${PWD}/build/docker/flutter/gradle/.gradle:/opt/flutter/packages/flutter_tools/gradle/.gradle" -w "${PWD}" thunder-builder bash -ic 'flutter --disable-analytics'
    docker run --rm -ti --user "$(id -u)" -e "HOME=/home/builder" --name thunder-builder -v "${PWD}:${PWD}" -v "${PWD}/build/docker:/home/builder" -v "${PWD}/build/docker/flutter/gradle/build:/opt/flutter/packages/flutter_tools/gradle/build"  -v "${PWD}/build/docker/flutter/gradle/.gradle:/opt/flutter/packages/flutter_tools/gradle/.gradle" -w "${PWD}" thunder-builder bash -ic 'dart --disable-analytics'
fi

# Create env
if [ ! -f ./.env ]; then
    echo "# comment" > ./.env
fi

# Make path in container
if [ ! -f ./build/docker/.bashrc ]; then
    echo '
export PATH="${PATH}:${HOME}/.pub-cache/bin"
export GRADLE_USER_HOME=${HOME}
' > ./build/docker/.bashrc
fi

# Build the APK
docker run --privileged --rm -ti --user "$(id -u)" -e "HOME=/home/builder" --name thunder-builder -v "${PWD}:${PWD}" -v "${PWD}/build/docker:/home/builder" -v "${PWD}/build/docker/flutter/gradle/build:/opt/flutter/packages/flutter_tools/gradle/build"  -v "${PWD}/build/docker/flutter/gradle/.gradle:/opt/flutter/packages/flutter_tools/gradle/.gradle" -w "${PWD}" thunder-builder bash -ic 'dart scripts/build-android.dart'
