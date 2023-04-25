#!/usr/bin/env bash

# Configure a daily backup of Cardano-node data

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

host="$1"

scp -r bin/cardano-node-backup \
    "$host":~/cardano-node-backup

ssh "$host" << 'EOF'
sudo mv ~/cardano-node-backup /usr/local/bin
chmod +x /usr/local/bin/cardano-node-backup
sudo apt install -y cron liblz4-tool
(sudo crontab -l | \
    grep -c "/usr/local/bin/cardano-node-backup") > /dev/null || \
    (sudo crontab -l 2>/dev/null; \
        echo "0 0 * * * /usr/local/bin/cardano-node-backup") | \
    sudo crontab -
EOF
