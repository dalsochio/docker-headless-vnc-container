# Docker Headless VNC Container

Minimal Docker image with a headless VNC desktop environment, based on [ConSol/docker-headless-vnc-container](https://github.com/ConSol/docker-headless-vnc-container).

- **Debian 13 (trixie)** base, pinned by digest
- **XFCE4** desktop (dark mode, no window decorations)
- **TigerVNC** server (port `5901`)
- **noVNC 1.6.0** HTML5 client (port `6901`)
- **fingerprint-chromium** pre-installed at `/opt/fingerprint-chromium/` (SHA256-verified)
- Tools: x11vnc, xdotool, socat, ffmpeg, iptables, iproute2, curl, jq, etc.

## Usage

```bash
# Build
docker build -t headless-vnc .

# Run
docker run -d -p 5901:5901 -p 6901:6901 headless-vnc

# Run with custom user
docker run -d -p 5901:5901 -p 6901:6901 --user $(id -u):$(id -g) headless-vnc

# Run as root (needed for iptables/tun2socks)
docker run -d -p 5901:5901 -p 6901:6901 --user 0 headless-vnc

# Interactive
docker run -it -p 5901:5901 -p 6901:6901 headless-vnc bash
```

## Connect

- **VNC viewer**: `localhost:5901` (password: `vncpassword`)
- **noVNC web client**: [http://localhost:6901/?password=vncpassword](http://localhost:6901/?password=vncpassword)

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `VNC_PW` | `vncpassword` | VNC password |
| `VNC_PASSWORDLESS` | - | Set `true` to disable password |
| `VNC_RESOLUTION` | `1280x1024` | Screen resolution |
| `VNC_COL_DEPTH` | `24` | Color depth |
| `VNC_VIEW_ONLY` | `false` | Disable mouse/keyboard control |

```bash
# Custom resolution, no password
docker run -d -p 6901:6901 -e VNC_RESOLUTION=1920x1080 -e VNC_PASSWORDLESS=true headless-vnc
```

## Extending

The image runs as user `1000` by default. Switch to root to install packages:

```dockerfile
FROM headless-vnc

USER 0
RUN apt-get update && apt-get install -y <your-packages> && apt-get clean
USER 1000
```

## Architecture

Only `linux/amd64` (fingerprint-chromium constraint).

## Quick Test

```bash
# Build and run
docker build -t headless-vnc .
docker run -d --rm --name vnc-test -p 5901:5901 -p 6901:6901 --shm-size=256m -e VNC_PASSWORDLESS=true headless-vnc

# Wait for VNC to start, then launch fingerprint-chromium
sleep 5
docker exec vnc-test bash -c 'DISPLAY=:1 /opt/fingerprint-chromium/chrome \
  --no-sandbox --no-first-run --disable-default-apps \
  --start-maximized --force-dark-mode \
  --fingerprint="12345" &'

# Open in browser
# http://localhost:6901

# Cleanup
docker stop vnc-test
```

## Structure

```
Dockerfile              # Multi-stage build (3 stages), pinned base digest
src/
  install/              # Install scripts (tools, tigervnc, xfce, novnc, chromium, etc.)
  scripts/              # vnc_startup.sh, generate_container_user
  xfce/                 # wm_startup.sh, XFCE configs (dark mode, panel, etc.)
```

## Updating

Versions are controlled by `ARG`s at the top of the `Dockerfile`:

| Component | ARG | Current |
|---|---|---|
| Base image | `BASE_IMAGE` | `debian:trixie-slim@sha256:26f9...` |
| fingerprint-chromium | `FINGERPRINT_CHROMIUM_VERSION` | `144.0.7559.132` |
| fingerprint-chromium checksum | `FINGERPRINT_CHROMIUM_SHA256` | `bb4c4484...` |
| noVNC | `NOVNC_VERSION` | `1.6.0` |
| websockify | `WEBSOCKIFY_VERSION` | `0.13.0` |

To update safely:

```bash
# 1. Update base image digest
docker pull debian:trixie-slim
docker inspect --format='{{index .RepoDigests 0}}' debian:trixie-slim
# Replace the digest in Dockerfile ARG BASE_IMAGE

# 2. Update fingerprint-chromium (if new release)
# Download new tarball and get its SHA256:
curl -sL "https://github.com/adryfish/fingerprint-chromium/releases/download/<VERSION>/ungoogled-chromium-<VERSION>-1-x86_64_linux.tar.xz" | sha256sum
# Update FINGERPRINT_CHROMIUM_VERSION and FINGERPRINT_CHROMIUM_SHA256

# 3. Rebuild with latest security patches
docker build --pull --no-cache -t headless-vnc .
```
