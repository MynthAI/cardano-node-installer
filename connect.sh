#!/usr/bin/env bash

# Create an SSH tunnel to enable the local machine to communicate
# with the Cardano node on a remote host.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [user@]hostname"
    exit 1
fi

rm -f /tmp/cardano-node.socket
ssh -nNT -L /tmp/cardano-node.socket:/var/lib/docker/volumes/cardano-node-ipc/_data/node.socket "$1" &
export CARDANO_NODE_SOCKET_PATH=/tmp/cardano-node.socket
