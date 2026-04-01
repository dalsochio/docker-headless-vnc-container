#!/usr/bin/env bash
set -e

NOVNC_VERSION=${NOVNC_VERSION:?}
WEBSOCKIFY_VERSION=${WEBSOCKIFY_VERSION:?}
NOVNC_TITLE=${NOVNC_TITLE:-cloudDevTools}

echo "Install noVNC ${NOVNC_VERSION} + websockify ${WEBSOCKIFY_VERSION}"

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl

mkdir -p $NO_VNC_HOME/utils/websockify

curl -sL "https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz" \
    | tar xz --strip 1 -C $NO_VNC_HOME

curl -sL "https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz" \
    | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify

ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

# Customizations
sed -i "s|<title>noVNC</title>|<title>${NOVNC_TITLE}</title>|" $NO_VNC_HOME/vnc.html $NO_VNC_HOME/vnc_lite.html
sed -i 's|<div id="top_bar">|<div id="top_bar" style="display: none;">|' $NO_VNC_HOME/vnc_lite.html
