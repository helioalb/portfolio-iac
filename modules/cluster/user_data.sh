#!/bin/bash
set -e

# Update system packages
dnf update -y

# Install Docker
dnf install -y docker

# Start Docker daemon
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group for passwordless docker commands
usermod -aG docker ec2-user

# Install Docker Compose plugin
dnf install -y docker-compose-plugin

# Verify installations
docker --version
docker compose version

echo "Docker installation completed successfully"
