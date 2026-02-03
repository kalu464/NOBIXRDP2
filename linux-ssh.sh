#!/bin/bash
set -e

echo "🔹 Updating system..."
sudo apt-get update -y

echo "🔹 Installing SSH..."
sudo apt-get install -y openssh-server curl wget unzip

echo "🔹 Creating / updating user..."
sudo useradd -m -s /bin/bash "$LINUX_USERNAME" || true
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sudo usermod -aG sudo "$LINUX_USERNAME"

echo "🔹 Configuring SSH..."
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "🔹 Installing ngrok..."
wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/ngrok
chmod +x /usr/local/bin/ngrok

echo "🔹 Configuring ngrok auth token..."
ngrok config add-authtoken "$NGROK_AUTH_TOKEN"

echo "🔹 Starting ngrok TCP tunnel (SSH)..."
nohup ngrok tcp 22 > ngrok.log 2>&1 &

echo "⏳ Waiting for ngrok to initialize..."
sleep 10

echo "======================================"
echo "✅ UBUNTU SSH READY"
echo "🖥️  MACHINE : $LINUX_MACHINE_NAME"
echo "👤 USER    : $LINUX_USERNAME"
echo "🔑 PASS    : $LINUX_USER_PASSWORD"
echo "🌐 NGROK TCP ADDRESS:"
curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://[^"]*' || echo "❌ TCP NOT FOUND"
echo "======================================"
