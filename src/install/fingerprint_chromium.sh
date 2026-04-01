#!/usr/bin/env bash
set -e

FINGERPRINT_CHROMIUM_VERSION=${FINGERPRINT_CHROMIUM_VERSION:?}
FINGERPRINT_CHROMIUM_SHA256=${FINGERPRINT_CHROMIUM_SHA256:?}

echo "Install fingerprint-chromium ${FINGERPRINT_CHROMIUM_VERSION}"

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl xz-utils

curl -sL "https://github.com/adryfish/fingerprint-chromium/releases/download/${FINGERPRINT_CHROMIUM_VERSION}/ungoogled-chromium-${FINGERPRINT_CHROMIUM_VERSION}-1-x86_64_linux.tar.xz" \
    -o /tmp/fp-chromium.tar.xz

echo "${FINGERPRINT_CHROMIUM_SHA256}  /tmp/fp-chromium.tar.xz" | sha256sum -c -

mkdir -p /opt/fingerprint-chromium
tar -xJf /tmp/fp-chromium.tar.xz -C /opt/fingerprint-chromium --strip-components=1
chmod +x /opt/fingerprint-chromium/chrome
rm -f /tmp/fp-chromium.tar.xz
