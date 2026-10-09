#!/bin/bash
# Setup script for AWS EC2 Ubuntu instance
# Run this once on fresh EC2 t2.micro

set -e

echo "=== Setting up EC2 for Flask DevOps App ==="

# Update system
echo "Updating system..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install Nginx (optional, for reverse proxy)
echo "Installing Nginx..."
sudo apt-get install -y nginx

# Configure Nginx as reverse proxy to Docker
sudo tee /etc/nginx/sites-available/flask-app << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        proxy_pass http://localhost:5000/health;
        access_log off;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
sudo systemctl enable nginx

# Setup firewall
echo "Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Install useful tools
sudo apt-get install -y htop curl wget git

echo "=== EC2 Setup Complete ==="
echo "Docker version: $(docker --version)"
echo "Nginx status: $(sudo systemctl is-active nginx)"
echo ""
echo "Next steps:"
echo "1. Logout and login again for docker group to take effect, or run: newgrp docker"
echo "2. Test docker: docker run hello-world"
echo "3. Setup GitHub Secrets for CI/CD:"
echo "   - DOCKERHUB_USERNAME, DOCKERHUB_TOKEN"
echo "   - EC2_HOST (your EC2 public IP), EC2_USERNAME (ubuntu), EC2_SSH_KEY (private key content)"
echo "4. Push to main branch to trigger deployment"
echo ""
echo "Your EC2 IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
