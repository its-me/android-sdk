ARG BASE_IMAGE=ghcr.io/its-me/android-sdk:build-tools
FROM ${BASE_IMAGE}

# https://developer.android.com/studio/releases/platforms
ARG ANDROID_PLATFORM_VERSION=37.2

ENV ANDROID_PLATFORM_VERSION=${ANDROID_PLATFORM_VERSION}

RUN android sdk install "platforms/android-${ANDROID_PLATFORM_VERSION}"
