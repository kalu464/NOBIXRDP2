#!/bin/bash
set -e

echo "🔹 Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "🔹 Starting Tailscale with auth key..."
# LINUX_TAILSCALE_KEY is a GitHub Secret
sudo tailscale up --authkey "${TAILSCALE_AUTH_KEY}"

sleep 5

# Print VM Tailscale IP
TS_IP=$(tailscale ip -4)
echo "======================================"
echo "✅ Tailscale setup complete!"
echo "🌐 Connect to VM using Termius / SSH:"
echo "Host / Address: ${TS_IP}"
echo "Port: 22"
echo "Username: ${LINUX_USERNAME}"
echo "Password: ${LINUX_USER_PASSWORD}"
echo "======================================"
