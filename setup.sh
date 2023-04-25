#!/usr/bin/env bash

# Configure a new Ubuntu machine. Update all packages to the
# latest version. Create a non-root user. Enhance SSH security.
# Set up Zsh.

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname [user]"
    exit 1
fi

host="$1"

echo -n "Setting up machine. Please enter your root password: "
read -rs password
echo

bash wait-for-ssh.sh root@"$host" "$password"

# Update the software
sshpass -p "$password" ssh root@"$host" << 'EOF'
apt update
apt upgrade -y
apt autoremove -y
EOF

# Wait for reboot
sshpass -p "$password" ssh root@"$host" reboot || true
echo "Waiting for reboot..."
bash wait-for-ssh.sh root@"$host" "$password"

# Create a non-root user with zsh shell
if [ "$#" -ge 2 ]; then
    user="$2"
    ssh_key_file="$HOME/.ssh/$user.pub"
    ssh_key=$(cat "$ssh_key_file")
else
    user=$(whoami)
    ssh_key_file=$(
        find ~/.ssh -type f -name "*.pub" -exec ls -tr {} + |
        head -n 1
    )
    ssh_key=$(cat "$ssh_key_file")
fi

# Create non-root user with ssh access
echo "Creating $user user with key $ssh_key_file"
sshpass -p "$password" \
    ssh root@"$host" "bash -s '""$user""' '$ssh_key'" << 'EOF'
adduser --disabled-password --gecos "User" $1
usermod -aG sudo $1
mkdir -p /home/$1/.ssh
chmod 700 /home/$1/.ssh
echo "$2" >> /home/$1/.ssh/authorized_keys
chmod 600 /home/$1/.ssh/authorized_keys
chown -R $1:$1 /home/$1/.ssh
echo "$1 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$1
chmod 0440 /etc/sudoers.d/$1
EOF

# Make ssh more secure
ssh -i "$ssh_key" "$user@$host" << 'EOF'
sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
EOF

# Set up zsh
ssh -i "$ssh_key" "$user@$host" << 'EOF'
sudo apt install -y git zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
sudo chsh -s /bin/zsh $(whoami)
EOF
