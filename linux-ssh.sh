#!/bin/bash
set -e

echo "🔹 Update & install deps..."
sudo apt-get update -y
sudo apt-get install -y openssh-server curl wget unzip

echo "🔹 Create/update user..."
sudo useradd -m -s /bin/bash "$LINUX_USERNAME" || true
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sudo usermod -aG sudo "$LINUX_USERNAME"

echo "🔹 Configure SSH..."
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "🔹 Install ngrok v3..."
wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/ngrok
chmod +x /usr/local/bin/ngrok

echo "🔹 Add ngrok auth token..."
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

echo "🔹 Start ngrok TCP tunnel (SSH)..."
nohup ngrok tcp 22 --log=stdout > ngrok.log 2>&1 &

echo "⏳ Waiting for ngrok..."
sleep 15

echo "======================================"
echo "✅ UBUNTU SSH READY"
echo "🖥️  MACHINE : $LINUX_MACHINE_NAME"
echo "👤 USER    : $LINUX_USERNAME"
echo "🌐 NGROK TCP ADDRESS:"
grep -o 'tcp://[^ ]*' ngrok.log | head -n 1 || echo "❌ TCP STILL NOT FOUND"
echo "======================================"

echo "🔎 ngrok log (last lines):"
tail -n 20 ngrok.log
