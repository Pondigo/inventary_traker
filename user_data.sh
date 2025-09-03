#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y curl git build-essential sudo

# Install Nix (multi-user installation)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Create deploy user
useradd -m -s /bin/bash deploy
usermod -aG sudo deploy
echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH for deploy user
mkdir -p /home/deploy/.ssh
chown deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh

# Create application directory
mkdir -p /opt/inventory-tracker
chown deploy:deploy /opt/inventory-tracker

# Enable Nix for all users
echo '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' >> /etc/bashrc

echo "Basic setup complete! Deploy NixOS configuration manually."