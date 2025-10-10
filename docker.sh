#!/bin/bash

# Docker and Docker Compose Installation Script
# This script installs Docker and Docker Compose on Debian/Ubuntu systems.
# It includes security enhancements like checksum verification for Docker Compose.

set -e # Exit on any error

echo "🐳 Starting Docker and Docker Compose installation..."
echo "=================================================="

# --- Function to detect the operating system ---
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "❌ Cannot detect the operating system."
        exit 1
    fi
}

detect_os

# --- Check for supported OS ---
if [ "$OS" != "debian" ] && [ "$OS" != "ubuntu" ]; then
    echo "❌ This script currently supports Debian and Ubuntu only."
    exit 1
fi

# --- Update package index ---
echo "📦 Updating package index..."
sudo apt-get update

# --- Install required packages ---
echo "🔧 Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# --- Add Docker's official GPG key ---
echo "🔑 Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${OS}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# --- Set up the stable repository ---
echo "📋 Setting up Docker repository for ${OS}..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS} \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Update package index again ---
echo "📦 Updating package index with Docker repository..."
sudo apt-get update

# --- Install Docker Engine ---
echo "🐳 Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# --- Add current user to docker group with a strong warning ---
echo "👤 Adding current user to the 'docker' group..."
echo "⚠️  SECURITY WARNING: Adding a user to the 'docker' group is equivalent to granting root access."
echo "   This is a significant security risk. Only proceed if you fully understand the implications."
read -p "   Do you want to continue? (y/N): " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo usermod -aG docker "$USER"
    echo "✅ User '$USER' added to the 'docker' group."
    echo "   You will need to log out and log back in for this change to take effect."
else
    echo "Skipping adding user to the 'docker' group."
fi

# --- Install Docker Compose ---
echo "🔧 Installing Docker Compose..."
# Use a more robust method to get the latest version
LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$LATEST_COMPOSE_VERSION" ]; then
    echo "❌ Could not determine the latest Docker Compose version."
    exit 1
fi

echo "Found latest Docker Compose version: ${LATEST_COMPOSE_VERSION}"

# Construct the download URL
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"

# Download Docker Compose
echo "Downloading Docker Compose from ${DOCKER_COMPOSE_URL}..."
sudo curl -L "${DOCKER_COMPOSE_URL}" -o /usr/local/bin/docker-compose

# --- Verify Docker Compose Checksum ---
echo "🔒 Verifying Docker Compose checksum..."
# Download the official checksums
CHECKSUM_URL="https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m).sha256"
EXPECTED_CHECKSUM=$(curl -sL "${CHECKSUM_URL}" | awk '{print $1}')

# Calculate the checksum of the downloaded file
DOWNLOADED_CHECKSUM=$(sha256sum /usr/local/bin/docker-compose | awk '{print $1}')

# Compare checksums
if [ "$DOWNLOADED_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
    echo "❌ Checksum verification failed for Docker Compose."
    echo "   Expected: ${EXPECTED_CHECKSUM}"
    echo "   Got:      ${DOWNLOADED_CHECKSUM}"
    sudo rm /usr/local/bin/docker-compose
    exit 1
fi

echo "✅ Checksum verified successfully."

# --- Make Docker Compose executable ---
sudo chmod +x /usr/local/bin/docker-compose

# --- Start and enable Docker service ---
echo "🚀 Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# --- Verify installations ---
echo "✅ Verifying installations..."
echo "   Docker version:"
docker --version
echo "   Docker Compose version:"
docker-compose --version

echo ""
echo "🎉 Installation completed successfully!"
echo "=================================================="
echo "🔧 To test your Docker installation, run: docker run hello-world"
echo "🔧 To test Docker Compose, run: docker-compose --version"
echo ""
echo "If you added your user to the 'docker' group, remember to log out and back in."