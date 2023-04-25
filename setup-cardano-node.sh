#!/usr/bin/env bash

# Install cardano-node as a Docker container and configure
# cardano-cli for interaction with cardano-node.

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

host="$1"

scp -r systemd/cardano-node.service \
    "$host":~/cardano-node.service
scp -r systemd/cardano-node-permissions.service \
    "$host":~/cardano-node-permissions.service
scp -r bin/set-cardano-node-permissions \
    "$host":~/set-cardano-node-permissions

ssh "$host" << 'EOF'
sudo mv ~/cardano-node.service /etc/systemd/system
sudo mv ~/cardano-node-permissions.service /etc/systemd/system
sudo mv ~/set-cardano-node-permissions /usr/local/bin
chmod +x /usr/local/bin/set-cardano-node-permissions
sudo systemctl daemon-reload
sudo systemctl enable cardano-node
sudo systemctl enable cardano-node-permissions
echo "Enabled cardano-node"
sudo systemctl start cardano-node
echo "Started cardano-node"
sudo systemctl start cardano-node-permissions
echo "cardano-node permissions configured"
wget -q https://update-cardano-mainnet.iohk.io/cardano-node-releases/cardano-node-1.35.7-linux.tar.gz
mkdir -p cardano-node
tar -xzf cardano-node-1.35.7-linux.tar.gz -C cardano-node
sudo mv cardano-node/cardano-cli /usr/local/bin
rm -rf cardano-node-1.35.7-linux.tar.gz cardano-node
echo "export CARDANO_NODE_SOCKET_PATH=/var/lib/docker/volumes/cardano-node-ipc/_data/node.socket" >> ~/.zshrc
EOF
