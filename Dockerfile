## Stage 1: Download and extract fingerprint-chromium
FROM debian:trixie-slim AS chromium-downloader
ARG FINGERPRINT_CHROMIUM_VERSION=144.0.7559.132
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && curl -sL "https://github.com/adryfish/fingerprint-chromium/releases/download/${FINGERPRINT_CHROMIUM_VERSION}/ungoogled-chromium-${FINGERPRINT_CHROMIUM_VERSION}-1-x86_64_linux.tar.xz" \
       -o /tmp/fp-chromium.tar.xz \
    && mkdir -p /opt/fingerprint-chromium \
    && tar -xJf /tmp/fp-chromium.tar.xz -C /opt/fingerprint-chromium --strip-components=1 \
    && chmod +x /opt/fingerprint-chromium/chrome \
    && rm -f /tmp/fp-chromium.tar.xz

## Stage 2: Download noVNC + websockify
FROM debian:trixie-slim AS novnc-downloader
ARG NOVNC_VERSION=1.6.0
ARG WEBSOCKIFY_VERSION=0.13.0
ARG NOVNC_TITLE=cloudDevTools
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && mkdir -p /novnc/utils/websockify \
    && curl -sL "https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz" | tar xz --strip 1 -C /novnc \
    && curl -sL "https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz" | tar xz --strip 1 -C /novnc/utils/websockify \
    && ln -s /novnc/vnc_lite.html /novnc/index.html \
    && sed -i "s|<title>noVNC</title>|<title>${NOVNC_TITLE}</title>|" /novnc/vnc.html /novnc/vnc_lite.html \
    && sed -i 's|<div id="top_bar">|<div id="top_bar" style="display: none;">|' /novnc/vnc_lite.html

## Stage 3: Final image
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    HOME=/headless \
    STARTUPDIR=/dockerstartup \
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

### Single apt-get layer: all packages + cleanup
RUN apt-get update && apt-get install -y --no-install-recommends \
    # -- basic tools --
    ca-certificates vim-tiny curl wget nano unzip jq bzip2 locales apt-utils \
    net-tools procps \
    # -- VNC & desktop --
    tigervnc-standalone-server tigervnc-tools \
    xfce4 xfce4-terminal xterm dbus-x11 libdbus-glib-1-2 \
    x11vnc x11-xserver-utils xdotool \
    # -- network tools --
    socat iptables iproute2 \
    # -- media --
    ffmpeg \
    # -- scheduled tasks --
    cron \
    # -- container user support --
    libnss-wrapper gettext \
    # -- fingerprint-chromium runtime deps --
    libnss3 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libgbm1 libasound2t64 libgtk-3-0t64 \
    && apt-get purge -y pm-utils *screensaver* \
    # -- locale --
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
    # -- allow remote VNC --
    && echo '$localhost = "no";' >> /etc/tigervnc/vncserver-config-defaults \
    # -- cleanup --
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && find /usr/share/doc -mindepth 1 -not -name 'copyright' -delete 2>/dev/null || true \
    && find /usr/share/man -type f -delete 2>/dev/null || true \
    && find /usr/share/locale -mindepth 1 -maxdepth 1 -not -name 'en*' -exec rm -rf {} + 2>/dev/null || true

### Copy noVNC from downloader stage (no curl/xz-utils bloat)
COPY --from=novnc-downloader /novnc $NO_VNC_HOME

### Copy fingerprint-chromium from downloader stage (no xz-utils bloat)
COPY --from=chromium-downloader /opt/fingerprint-chromium /opt/fingerprint-chromium

### Runtime scripts
COPY src/scripts/ $STARTUPDIR/

### XFCE config (dark mode, no window buttons, 28px panel, no icons, no wallpaper)
COPY src/xfce/.config/ $HOME/.config/
RUN mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml \
    && cp $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/

### Window manager startup
COPY src/xfce/wm_startup.sh $HOME/wm_startup.sh

### nss_wrapper hook in .bashrc
RUN echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc

### Fix permissions
RUN find $STARTUPDIR/ $HOME/ -name '*.sh' -exec chmod a+x {} + \
    && chgrp -R 0 $STARTUPDIR $HOME \
    && chmod -R a+rw $STARTUPDIR $HOME \
    && find $STARTUPDIR/ $HOME/ -type d -exec chmod a+x {} +

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
