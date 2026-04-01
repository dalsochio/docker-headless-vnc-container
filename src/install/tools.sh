#!/usr/bin/env bash
set -e
echo "Install common tools and utilities"
apt-get install -y --no-install-recommends \
    ca-certificates vim-tiny curl wget nano unzip jq bzip2 locales apt-utils \
    net-tools procps \
    x11vnc x11-xserver-utils xdotool \
    socat iptables iproute2 \
    ffmpeg \
    cron

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
