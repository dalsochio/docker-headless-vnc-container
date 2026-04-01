# Docker Headless VNC Container

Minimal Docker image with a headless VNC desktop environment, based on [ConSol/docker-headless-vnc-container](https://github.com/ConSol/docker-headless-vnc-container).

- **Debian 13 (trixie)** base
- **XFCE4** desktop (dark mode, no window decorations)
- **TigerVNC** server (port `5901`)
- **noVNC 1.6.0** HTML5 client (port `6901`)
- **fingerprint-chromium** pre-installed at `/opt/fingerprint-chromium/`
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

## Structure

```
Dockerfile              # Multi-stage build
src/
  install/              # Package install scripts (unused at runtime, baked into image)
  scripts/              # vnc_startup.sh, generate_container_user
  xfce/                 # wm_startup.sh, XFCE configs (dark mode, panel, etc.)
```
