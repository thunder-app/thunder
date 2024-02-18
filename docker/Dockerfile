FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV PATH "${PATH}:/opt/flutter/bin:/root/.pub-cache/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:/opt/android-sdk-linux/platform-tools"

ENV HOME=/root

RUN \
    # Prereqs
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        file \
        git 2.x \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        libxi-dev \
        libxmu-dev \
        libglu1-mesa-dev \
        git-lfs \
        openssl \
        wget

RUN \
    # Android SDK
    apt-get install -y --no-install-recommends \
        git \
        git-lfs \
        openssl \
        wget \
        unzip &&\
    wget --quiet  https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O /tmp/tools.zip && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    unzip -q /tmp/tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm -v /tmp/tools.zip && \
    mkdir -p /root/.android/ && touch /root/.android/repositories.cfg &&\
    apt-get install -y --no-install-recommends openjdk-18-jdk openjdk-18-jre &&\
    yes | sdkmanager --licenses &&\
    sdkmanager --update &&\
    sdkmanager --install "platforms;android-28" &&\
    sdkmanager --install "platforms;android-29" &&\
    sdkmanager --install "platforms;android-30" &&\
    sdkmanager --install "platforms;android-31" &&\
    sdkmanager --install "platforms;android-32" &&\
    sdkmanager --install "platforms;android-33" &&\
    sdkmanager --install "platforms;android-34" &&\
    sdkmanager --install "build-tools;30.0.3" &&\
    sdkmanager --install "ndk;23.1.7779620" &&\
    sdkmanager --install "cmake;3.22.1" &&\
    sdkmanager --install platform-tools &&\
    sdkmanager --install emulator &&\
    sdkmanager --install tools


ARG DEV_UID=0
RUN \
    # Flutter
    wget --quiet https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz -O /tmp/flutter.tar.xz &&\
    mkdir -p /opt &&\
    cd /opt &&\
    tar xf /tmp/flutter.tar.xz &&\
    rm /tmp/flutter.tar.xz &&\
    git config --global --add safe.directory /opt/flutter &&\
    dart pub global activate cider &&\
    chown -R ${DEV_UID} /opt/flutter

# Optional add eo language pack
# RUN apt install -y locales language-selector-common
# RUN apt install -y $(check-language-support -l eo)

# Optional cleanup if above is combined for push
# RUN apt-get autoremove && apt-get autoclean
