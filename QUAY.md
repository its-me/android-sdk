Base images for Flutter CI builds, providing the Android SDK layer on top of Debian. Three images are layered and released independently.\
Source: https://github.com/its-me/image.android-sdk

## Images

### tools

Base image. Installs OpenJDK 21, the Android CLI (android, replacing the deprecated sdkmanager) plus adb and other platform tools, and the system packages typically needed for Flutter CI (build-essential, curl, git, and others). Includes the android-wait-for-emulator helper script.

| Tag | Example | Meaning |
|-----|---------|---------|
| `tools-<version>` | `tools-1.0.16261425` | Exact Android CLI version |
| `tools` | `tools` | Latest released Android CLI |

### build-tools

Adds Android build tools (aapt, d8, zipalign, etc.) via the Android CLI.

| Tag | Example | Meaning |
|-----|---------|---------|
| `build-tools-<version>` | `build-tools-37.0.0` | Exact build-tools version |
| `build-tools-<version>-rc<n>` | `build-tools-37.0.0-rc1` | Release candidate |
| `build-tools-<major-version>` | `build-tools-37` | Latest version of major release |
| `build-tools` | `build-tools` | Latest release of build-tools |

### platform

Adds the Android platform SDK for a specific API level via the Android CLI.

| Tag | Example | Meaning |
|-----|---------|---------|
| `<version>` | `37.0` | Exact platform version |
| `<version>-ext<n>` | `35-ext14` | Extension release (version tag only) |
| `<major-version>` | `37` | Latest version of major release |
| `latest` | `latest` | Latest release of platform |

Platform versions follow the upstream scheme: plain integers or decimals (35, 36.1, 37.0) for standard releases, and <version>-ext<n> for extension releases.

## Usage

Use as a base image and layer Flutter on top:

```dockerfile
FROM quay.io/itsme/android-sdk:latest
RUN wget -qO /tmp/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_<version>-stable.tar.xz \
&& tar xf /tmp/flutter.tar.xz -C /opt \
&& rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:$PATH"
```

Or reference the image directly in a GitHub CI job:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container: quay.io/itsme/android-sdk:latest
```

Pin to a specific platform version for reproducible builds:

```yaml
container: quay.io/itsme/android-sdk:37.0
```
