#!/bin/bash
set -euo pipefail

# Setup development distrobox with tools excluded from the main bootc image
# This creates a containerized development environment with Go and Google Cloud CLI

DISTROBOX_NAME="dev"
DISTROBOX_IMAGE="fedora:42"

echo "Setting up development distrobox: ${DISTROBOX_NAME}"
echo "Using image: ${DISTROBOX_IMAGE}"
echo

# Check if distrobox exists
if ! command -v distrobox &> /dev/null; then
    echo "Error: distrobox is not installed"
    exit 1
fi

# Check if the distrobox already exists
if distrobox list | grep -q "^${DISTROBOX_NAME} "; then
    echo "Distrobox '${DISTROBOX_NAME}' already exists."
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing distrobox..."
        distrobox rm -f "${DISTROBOX_NAME}"
    else
        echo "Keeping existing distrobox. Exiting."
        exit 0
    fi
fi

# Create the distrobox
echo "Creating distrobox '${DISTROBOX_NAME}'..."
distrobox create \
    --name "${DISTROBOX_NAME}" \
    --image "${DISTROBOX_IMAGE}" \
    --yes

echo
echo "Installing development packages in distrobox..."

# Install packages inside the distrobox
distrobox enter "${DISTROBOX_NAME}" -- bash -c '
set -euo pipefail

echo "Adding Google Cloud CLI repository..."
sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null << EOF
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

echo "Installing packages..."
sudo dnf install -y \
    golang \
    gopls \
    google-cloud-cli \
    libxcrypt-compat.x86_64

echo "Development packages installed successfully!"
'

echo
echo "Exporting commands to host..."

# Export useful commands to the host
distrobox enter "${DISTROBOX_NAME}" -- distrobox-export --bin /usr/bin/go
distrobox enter "${DISTROBOX_NAME}" -- distrobox-export --bin /usr/bin/gofmt
distrobox enter "${DISTROBOX_NAME}" -- distrobox-export --bin /usr/bin/gopls
distrobox enter "${DISTROBOX_NAME}" -- distrobox-export --bin /usr/bin/gcloud
distrobox enter "${DISTROBOX_NAME}" -- distrobox-export --bin /usr/bin/gsutil
distrobox enter "${DISTROBOX_NAME}" -- distrobox-export --bin /usr/bin/bq

echo
echo "✓ Development distrobox setup complete!"
echo
echo "Usage:"
echo "  - Enter the distrobox:    distrobox enter ${DISTROBOX_NAME}"
echo "  - Run Go from host:       go version"
echo "  - Run gcloud from host:   gcloud --version"
echo "  - List exported apps:     ls ~/.local/bin/"
echo
echo "Exported commands are available in your PATH (~/.local/bin)"
