#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

host="$1"

ssh "$host" << 'EOF'
sudo apt-get update
sudo apt-get install -y aria2 lz4
export latest="$(wget -qO- https://node-downloads.mynth.ai/latest.txt)"
export BACKUP="https://node-downloads.mynth.ai/mainnet-db-$latest.tar.lz4"
aria2c -x 16 -s 16 -k 100M -c "$BACKUP"
echo "Download complete"
sudo systemctl stop cardano-node
sudo rm -rf /var/lib/docker/volumes/cardano-node-data/_data/db
echo "Cleared cardano-node data. Extracting backup"
lz4 -dc "mainnet-db-$latest.tar.lz4" | sudo tar -xvf - -C /
echo "Backup restore complete"
sudo systemctl start cardano-node
rm -f "mainnet-db-$latest.tar.lz4"
EOF
