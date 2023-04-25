#!/usr/bin/env bash

# Install and configure Docker on a remote machine

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

host="$1"

ssh "$host" << 'EOF'
sudo install -m 0755 -d /etc/apt/keyrings
wget -qO- https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli
sudo usermod -aG docker $(whoami)
EOF
