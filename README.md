# Android SDK container images

Docker base images for Flutter CI pipelines, providing the Android SDK layer that Flutter builds require. Three-layered images are built and tagged independently; each layer adds one SDK component on top of the previous one. Images are published to GHCR, Docker Hub, and Quay.io.

## Images and tags

### `tools`: Android command-line tools

**Dockerfile:** `Dockerfile.tools`  
**Base:** `debian:stable-slim`

Installs OpenJDK 21, the [Android CLI](https://developer.android.com/tools/agents/android-cli) (`android`, replacing the deprecated `sdkmanager`) plus `adb` and other platform tools, and supporting system packages (Ruby, `build-essential`, `curl`, `git`, etc.). Provides the `android-wait-for-emulator` helper script. All subsequent images build on top of this one.

| Tag | Example | Meaning |
|-----|---------|---------|
| `tools-<version>` | `tools-1.0.16261425` | Exact Android CLI version |
| `tools` | `tools` | Latest release of Android CLI |

---

### `build-tools`: Android build tools

**Dockerfile:** `Dockerfile.build-tools`  
**Base:** `tools`

Adds the Android build tools package (`aapt`, `d8`, `zipalign`, etc.) via `android sdk install`.

| Tag | Example | Meaning |
|-----|---------|---------|
| `build-tools-<version>` | `build-tools-37.0.0` | Exact build-tools version |
| `build-tools-<version>-rc<n>` | `build-tools-37.0.0-rc1` | Release candidate |
| `build-tools-<major-version>` | `build-tools-37` | Latest version of major release |
| `build-tools` | `build-tools` | Latest release of build-tools |

---

### `<version>`: Android platform SDK

**Dockerfile:** `Dockerfile`  
**Base:** `build-tools`

Adds the Android platform SDK for a specific API level via `android sdk install`.

| Tag | Example | Meaning |
|-----|---------|---------|
| `<version>` | `37.0` | Exact platform version |
| `<version>-ext<n>` | `35-ext14` | Extension release (version tag only) |
| `<major-version>` | `37` | Latest version of major release |
| `latest` | `latest` | Latest release of platform |

Platform versions use either plain integers (`35`) or decimals (`36.1`, `37.0`). Decimal versions also receive a major tag (e.g. `37.0` → `37`). Extension releases only receive the version tag.

---

## Usage

These images provide the Android SDK layer required by Flutter. Use them as a base image and add Flutter on top:

```dockerfile
FROM ghcr.io/its-me/android-sdk:latest
RUN wget -qO /tmp/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_<version>-stable.tar.xz \
    && tar xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:$PATH"
```

Or reference the image directly in CI when Flutter is already installed in the runner:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/its-me/android-sdk:latest
```

Pin to a specific platform version for reproducible builds:

```yaml
container: ghcr.io/its-me/android-sdk:37.0
```

If you only need build-tools without platform SDK, use `build-tools` image; for just the Android CLI and platform tools, use `tools`.

---

## Registries

Images are mirrored to three registries under the same tag names:

- [ghcr.io/its-me/android-sdk](https://ghcr.io/its-me/android-sdk)
- [itsme/android-sdk](https://hub.docker.com/r/itsme/android-sdk)
- [quay.io/itsme/android-sdk](https://quay.io/repository/itsme/android-sdk)

## Automated releases

Each image family has a daily check workflow that queries a Google-hosted package index for new versions. When a new version is found that has no corresponding git tag, the matching release workflow is triggered automatically.

| Workflow | Schedule (UTC) | Watches |
|----------|---------------|---------|
| `tools: check release` | 00:00 daily | [Android CLI apt `Packages` index](http://dl.google.com/android/cli/latest/debian/dists/stable/main/binary-amd64/Packages) |
| `build-tools: check release` | 01:00 daily | [Android SDK repository XML](https://dl.google.com/android/repository/repository2-3.xml): `build-tools;<version>` |
| `platform: check release` | 02:00 daily | [Android SDK repository XML](https://dl.google.com/android/repository/repository2-3.xml): `platforms;android-<version>` |

Release workflows can also be triggered manually via `workflow_dispatch` with an explicit version input.

## License

[MIT](LICENSE)
