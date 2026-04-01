#!/usr/bin/env bash
set -e

echo "Install XFCE4 desktop environment"
apt-get update
apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal xterm \
    dbus-x11 libdbus-glib-1-2
apt-get purge -y pm-utils *screensaver*
apt-get clean -y
