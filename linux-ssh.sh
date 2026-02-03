#!/bin/bash
set -e

echo "🔹 Update & install packages..."
sudo apt-get update -y
sudo apt-get install -y openssh-server curl wget

echo "🔹 Create / update user..."
sudo useradd -m -s /bin/bash "$LINUX_USERNAME" || true
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sudo usermod -aG sudo "$LINUX_USERNAME"

echo "🔹 Configure SSH..."
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "🔹 Install cloudflared..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared

echo "🔹 Start Cloudflare SSH tunnel..."
nohup cloudflared tunnel run --token "$CLOUDFLARE_TUNNEL_TOKEN" > cloudflare.log 2>&1 &

sleep 10

echo "======================================"
echo "✅ CLOUDFLARE SSH TUNNEL STARTED"
echo "👤 USER : $LINUX_USERNAME"
echo "🔑 PASS : $LINUX_USER_PASSWORD"
echo "📄 Tunnel logs (last lines):"
tail -n 15 cloudflare.log
echo "======================================"
