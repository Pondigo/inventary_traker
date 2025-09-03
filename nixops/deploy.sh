#!/bin/bash
set -e

# NixOps deployment script for Inventory Tracker

echo "Starting NixOps deployment..."

# Check if deployment exists
if nixops list | grep -q "inventory-tracker"; then
    echo "Deployment exists, updating..."
    nixops modify -d inventory-tracker network.nix
else
    echo "Creating new deployment..."
    nixops create -d inventory-tracker network.nix
fi

# Deploy
echo "Deploying to AWS..."
nixops deploy -d inventory-tracker --allow-reboot

# Get deployment info
echo "Deployment complete!"
echo "Instance information:"
nixops info -d inventory-tracker

echo "SSH into the instance:"
nixops ssh -d inventory-tracker inventory-tracker

echo "To destroy the deployment:"
echo "nixops destroy -d inventory-tracker --confirm"