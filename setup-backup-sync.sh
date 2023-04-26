#!/usr/bin/env bash

# Configure backups to be synced with KeyCDN

set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 hostname username zone"
    exit 1
fi

host="$1"
username="$2"
zone="$3"

sed "s/{username}/$username/g" conf/lsyncd.conf.lua > \
    lsyncd.conf.temp.lua
sed -i "s/{zone}/$zone/g" lsyncd.conf.temp.lua
scp lsyncd.conf.temp.lua "$host":~/lsyncd.conf.lua
rm lsyncd.conf.temp.lua

ssh "$host" << 'EOF'
sudo apt update
sudo apt install -y lsyncd
sudo sh -c '[ ! -d /root/.ssh ] && mkdir -p /root/.ssh'
sudo chmod 700 /root/.ssh
sudo sh -c "[ ! -f /root/.ssh/id_rsa ] && \
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N '' \
        -C '$(hostname)'"
sudo chmod 600 /root/.ssh/id_rsa
sudo mkdir -p /var/log/lsyncd
sudo mkdir -p /etc/lsyncd
sudo touch /var/log/lsyncd/lsyncd.log
sudo touch /var/log/lsyncd/lsyncd-status.log
sudo mv ~/lsyncd.conf.lua /etc/lsyncd/lsyncd.conf.lua
sudo systemctl enable lsyncd
sudo systemctl start lsyncd
echo
echo "Add the following public key to KeyCDN account"
sudo cat /root/.ssh/id_rsa.pub
EOF
