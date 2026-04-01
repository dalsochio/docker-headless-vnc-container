#!/usr/bin/env bash
set -e

NOVNC_VERSION=${NOVNC_VERSION:-1.6.0}
WEBSOCKIFY_VERSION=${WEBSOCKIFY_VERSION:-0.13.0}

echo "Install noVNC ${NOVNC_VERSION} + websockify ${WEBSOCKIFY_VERSION}"

mkdir -p $NO_VNC_HOME/utils/websockify

curl -sL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz \
    | tar xz --strip 1 -C $NO_VNC_HOME

curl -sL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz \
    | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify

# vnc_lite.html is the lightweight client used as default
ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html
