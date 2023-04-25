# Cardano Node Installer

This project automates the installation and configuration of
cardano-node on a remote machine. Cardano nodes are essential components
of the Cardano blockchain network, enabling users to participate in the
decentralized network as a stake pool operator or a relay node.

## Prerequisites

Before starting, ensure you have the following prerequisites:

  - A remote machine running Ubuntu (22.04 recommended)
  - Root SSH access to the remote machine
  - Git and bash installed on your local machine
  - Basic knowledge of Cardano Node operation

## Installation

To use this tool, clone the repository to your local machine and
navigate to the directory:

    git clone https://github.com/MynthExchange/cardano-node-installer.git
    cd cardano-node-installer

To prepare a new remote machine, use `setup.sh`. This script updates all
packages to the latest version, creates a non-root user, enhances SSH
security, and sets up Zsh.

    bash setup.sh [REMOTE_IP]

Cardano-node runs inside a Docker container. To install Docker on your
remote machine, use `setup-docker.sh`:

    bash setup-docker.sh [REMOTE_IP]

With Docker installed, you can install cardano-node using
`setup-cardano-node.sh`:

    bash setup-cardano-node.sh [REMOTE_IP]

The script will automatically install and configure a Cardano node on
the remote machine. This process may take several minutes.

Optionally, you can set up regular backups using `setup-backup.sh`. This
script takes a daily snapshot of the Cardano data and stores it locally
in a backups folder on the remote machine.

    bash setup-backup.sh [REMOTE_IP]

Additional steps are necessary to upload these backups to a remote
service, such as cloud storage. This repository supports saving backups
to [KeyCDN](https://www.keycdn.com/). To set up file syncing with
KeyCDN, use `setup-backup-sync.sh`:

    bash setup-backup-sync.sh [REMOTE_IP] [KEYCDN_USER] [KEYCDN_ZONE]

After setup, it will output a public SSH key that you will need to add
to your KeyCDN account to authorize the machine to upload files to
KeyCDN.

## Using cardano-cli

`cardano-cli` will be automatically installed upon installation of the
node. You can SSH into your remote machine and query the latest block:

    cardano-cli query tip --mainnet

You can also use `cardano-cli` locally. First, install it on your local
machine, and then use connect.sh to create a secure connection to your
remote Cardano node.

    bash connect.sh [REMOTE_IP]

## Troubleshooting

If you encounter any issues during installation or operation, join the
Mynth Discord server for further guidance.

## License

This project is released under the GNU GPLv3. See COPYING for more
information.
