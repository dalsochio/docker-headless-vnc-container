#!/usr/bin/env bash
set -e
echo "Install TigerVNC server"
apt-get install -y --no-install-recommends \
    tigervnc-standalone-server tigervnc-tools

echo '$localhost = "no";' >> /etc/tigervnc/vncserver-config-defaults
