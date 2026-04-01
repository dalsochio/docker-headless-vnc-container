#!/usr/bin/env bash
set -e

echo "Install common tools"
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates vim wget curl nano unzip jq \
    net-tools procps bzip2 locales apt-utils \
    python3-numpy \
    x11vnc x11-xserver-utils xdotool \
    socat iptables iproute2 \
    ffmpeg cron
apt-get clean -y

echo "Generate en_US.UTF-8 locale"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
