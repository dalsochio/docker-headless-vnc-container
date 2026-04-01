#!/usr/bin/env bash
set -e

NOVNC_TITLE=${NOVNC_TITLE:-cloudDevTools}

echo "Apply noVNC customizations (title: ${NOVNC_TITLE})"

# Change browser tab title
sed -i "s|<title>noVNC</title>|<title>${NOVNC_TITLE}</title>|" "$NO_VNC_HOME/vnc.html"
sed -i "s|<title>noVNC</title>|<title>${NOVNC_TITLE}</title>|" "$NO_VNC_HOME/vnc_lite.html"

# Hide the top bar (connection status + ctrl+alt+del button)
sed -i 's|<div id="top_bar">|<div id="top_bar" style="display: none;">|' "$NO_VNC_HOME/vnc_lite.html"
