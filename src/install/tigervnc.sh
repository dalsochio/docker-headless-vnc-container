#!/usr/bin/env bash
set -e

echo "Install TigerVNC server"
apt-get update
apt-get install -y tigervnc-standalone-server
apt-get clean -y

# Allow remote connections
echo '$localhost = "no";' >> /etc/tigervnc/vncserver-config-defaults
