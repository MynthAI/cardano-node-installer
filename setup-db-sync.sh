#!/usr/bin/env bash

# Install db-sync as a Docker container

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

host="$1"

scp systemd/cardano-db-sync.service \
    "$host":~/cardano-db-sync.service

ssh "$host" << 'EOF'
sudo mv ~/cardano-db-sync.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable cardano-db-sync
echo "Enabled db-sync"
sudo systemctl start cardano-db-sync
echo "Started db-sync"
EOF
