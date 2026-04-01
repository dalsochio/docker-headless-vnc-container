#!/usr/bin/env bash
set -e

echo "Install libnss_wrapper for container user generation"
apt-get update
apt-get install -y libnss-wrapper gettext
apt-get clean -y

# Source generate_container_user on every shell login
echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc
