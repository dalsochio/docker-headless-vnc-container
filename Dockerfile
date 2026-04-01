# Pinned base image for reproducible builds
# To update: docker pull debian:trixie-slim && docker inspect --format='{{index .RepoDigests 0}}' debian:trixie-slim
ARG BASE_IMAGE=debian:trixie-slim@sha256:26f98ccd92fd0a44d6928ce8ff8f4921b4d2f535bfa07555ee5d18f61429cf0c

## Stage 1: Download and extract fingerprint-chromium
FROM ${BASE_IMAGE} AS chromium-downloader
ARG FINGERPRINT_CHROMIUM_VERSION=144.0.7559.132
ARG FINGERPRINT_CHROMIUM_SHA256=bb4c44840bae7e881f6258ed5b33f972f284384d898b6289e1f0c0bf47555ede
ENV FINGERPRINT_CHROMIUM_VERSION=$FINGERPRINT_CHROMIUM_VERSION \
    FINGERPRINT_CHROMIUM_SHA256=$FINGERPRINT_CHROMIUM_SHA256
COPY src/install/fingerprint_chromium.sh /tmp/
RUN chmod +x /tmp/fingerprint_chromium.sh && /tmp/fingerprint_chromium.sh

## Stage 2: Download noVNC + websockify
FROM ${BASE_IMAGE} AS novnc-downloader
ARG NOVNC_VERSION=1.6.0
ARG WEBSOCKIFY_VERSION=0.13.0
ARG NOVNC_TITLE=cloudDevTools
ENV NOVNC_VERSION=$NOVNC_VERSION \
    WEBSOCKIFY_VERSION=$WEBSOCKIFY_VERSION \
    NOVNC_TITLE=$NOVNC_TITLE \
    NO_VNC_HOME=/novnc
COPY src/install/no_vnc.sh /tmp/
RUN chmod +x /tmp/no_vnc.sh && /tmp/no_vnc.sh

## Stage 3: Final image
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    HOME=/headless \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

EXPOSE $VNC_PORT $NO_VNC_PORT

WORKDIR $HOME

### Copy install scripts into image (kept at /headless/install/ for reference)
COPY src/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Single layer: run all install scripts + cleanup
RUN apt-get update && apt-get upgrade -y \
    && $INST_SCRIPTS/tools.sh \
    && $INST_SCRIPTS/tigervnc.sh \
    && $INST_SCRIPTS/xfce_ui.sh \
    && $INST_SCRIPTS/chromium_deps.sh \
    && $INST_SCRIPTS/libnss_wrapper.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && find /usr/share/doc -mindepth 1 -not -name 'copyright' -delete 2>/dev/null || true \
    && find /usr/share/man -type f -delete 2>/dev/null || true \
    && find /usr/share/locale -mindepth 1 -maxdepth 1 -not -name 'en*' -exec rm -rf {} + 2>/dev/null || true

### Copy noVNC from downloader stage
COPY --from=novnc-downloader /novnc $NO_VNC_HOME

### Copy fingerprint-chromium from downloader stage
COPY --from=chromium-downloader /opt/fingerprint-chromium /opt/fingerprint-chromium

### Runtime scripts
COPY src/scripts/ $STARTUPDIR/

### XFCE desktop (wm_startup.sh, dark mode, no window buttons, 28px panel, no icons, no wallpaper)
COPY src/xfce/ $HOME/
RUN mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml \
    && cp $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/

### Fix permissions for $STARTUPDIR $HOME
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
