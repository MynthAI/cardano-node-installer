#!/usr/bin/env bash

# Waits for an SSH connection to become available on a remote
# host. This is helpful when setting up new machines or during
# the reboot process of existing machines.

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [user@]hostname password"
    exit 1
fi

host="$1"
password="$2"
timeout=5
interval=5

# Function to check SSH connectivity
check_ssh() {
    sshpass -p "$password" \
        ssh -o ConnectTimeout="$timeout" \
            -o StrictHostKeyChecking=no -q "$host" exit
}

# Main loop
while true; do
    if check_ssh; then
        echo "SSH is now responsive on $host"
        break
    else
        echo "Waiting for SSH to become responsive on $host"
        sleep "$interval"
    fi
done
