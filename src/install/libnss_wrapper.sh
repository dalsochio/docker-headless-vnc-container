#!/usr/bin/env bash
set -e
echo "Install libnss_wrapper for container user generation"
apt-get install -y --no-install-recommends \
    libnss-wrapper gettext

echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc
