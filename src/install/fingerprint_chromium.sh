#!/usr/bin/env bash
set -e

FINGERPRINT_CHROMIUM_VERSION=${FINGERPRINT_CHROMIUM_VERSION:-144.0.7559.132}

echo "Install fingerprint-chromium ${FINGERPRINT_CHROMIUM_VERSION}"

# Dependencies required by the Chromium binary
apt-get update
apt-get install -y --no-install-recommends \
    xz-utils libnss3 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libgbm1 libasound2 libgtk-3-0
apt-get clean -y

wget -q "https://github.com/adryfish/fingerprint-chromium/releases/download/${FINGERPRINT_CHROMIUM_VERSION}/ungoogled-chromium-${FINGERPRINT_CHROMIUM_VERSION}-1-x86_64_linux.tar.xz" \
    -O /tmp/fp-chromium.tar.xz

mkdir -p /opt/fingerprint-chromium
tar -xJf /tmp/fp-chromium.tar.xz -C /opt/fingerprint-chromium --strip-components=1
chmod +x /opt/fingerprint-chromium/chrome
rm -f /tmp/fp-chromium.tar.xz
