#!/usr/bin/env bash
set -e
echo "Fix permissions for: $@"
for dir in "$@"; do
    echo "-- fix permissions for: $dir"
    find "$dir"/ -name '*.sh' -exec chmod a+x {} +
    chgrp -R 0 "$dir" && chmod -R a+rw "$dir" && find "$dir"/ -type d -exec chmod a+x {} +
done
