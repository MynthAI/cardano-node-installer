#!/usr/bin/env bash

# Setup PostgreSQL on a machine

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

host="$1"

scp -r bin/install-postgres.sh \
    "$host":~/install-postgres.sh

ssh "$host" << 'EOF'
sudo bash "$HOME"/install-postgres.sh
rm install-postgres.sh
EOF
