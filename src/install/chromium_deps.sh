#!/usr/bin/env bash
set -e
echo "Install fingerprint-chromium runtime dependencies"
apt-get install -y --no-install-recommends \
    libnss3 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libgbm1 libasound2t64 libgtk-3-0t64
