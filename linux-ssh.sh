#!/bin/bash
set -e

echo "🔹 Setting up Ubuntu SSH..."

# Create user if not exists
sudo useradd -m -s /bin/bash "$LINUX_USERNAME" || true
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sudo usermod -aG sudo "$LINUX_USERNAME"

# Enable password SSH
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

sudo systemctl restart ssh

# Install ngrok
wget -q -O ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok.tgz
sudo mv ngrok /usr/local/bin/ngrok

# Auth ngrok
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

# Start SSH tunnel
nohup ngrok tcp 22 > ngrok.log 2>&1 &

sleep 5

echo "===================================="
echo "✅ Ubuntu SSH VM Ready"
echo "👤 User : $LINUX_USERNAME"
echo "🖥️  Name : $LINUX_MACHINE_NAME"
echo "🔑 Password : $LINUX_USER_PASSWORD"
echo "🌐 Ngrok tunnel info:"
curl -s http://127.0.0.1:4040/api/tunnels || true
echo "===================================="
