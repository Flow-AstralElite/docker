#!/bin/bash

# Docker and Docker Compose Installation Script
# This script installs Docker and Docker Compose on Debian/Ubuntu systems

set -e  # Exit on any error

echo "🐳 Starting Docker and Docker Compose installation..."
echo "=================================================="

# Update package index
echo "📦 Updating package index..."
sudo apt update

# Install required packages
echo "🔧 Installing required packages..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
echo "🔑 Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "📋 Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "📦 Updating package index with Docker repository..."
sudo apt update

# Install Docker Engine
echo "🐳 Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add current user to docker group
echo "👤 Adding current user to docker group..."
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create symbolic link for easier access
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Start and enable Docker service
echo "🚀 Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify installations
echo "✅ Verifying installations..."
echo "Docker version:"
docker --version
echo "Docker Compose version:"
docker-compose --version

echo ""
echo "🎉 Installation completed successfully!"
echo "=================================================="
echo "⚠️  IMPORTANT: You need to log out and log back in"
echo "   (or restart your system) for the group changes"
echo "   to take effect and use Docker without sudo."
echo ""
echo "🔧 To test Docker, run: docker run hello-world"
echo "🔧 To test Docker Compose, run: docker-compose --version"
