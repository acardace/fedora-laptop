#!/bin/bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_PATH")")"
INI_FILE="${ROOT_DIR}/distrobox.ini"
BREWFILE="${ROOT_DIR}/Brewfile"

sync_packages() {
    # Install/update dnf packages from distrobox.ini
    local packages
    packages=$(grep '^additional_packages=' "${INI_FILE}" | sed 's/additional_packages="//' | sed 's/"$//' | tr -s ' ')
    if [[ -n "$packages" ]]; then
        echo "Syncing dnf packages..."
        sudo dnf install -y $packages
    fi

    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    # Install/update brew packages from Brewfile
    echo "Syncing brew packages..."
    brew bundle --file="${BREWFILE}" install --upgrade --cleanup

    # Helm plugins
    helm plugin install https://github.com/databus23/helm-diff --verify=false
}

# Ensure the script is available as a command
mkdir -p "${HOME}/.local/bin"
ln -sf "${SCRIPT_PATH}" "${HOME}/.local/bin/setup-devbox"

# If we're inside the distrobox, sync packages directly
if [[ "${CONTAINER_ID:-}" == "dev" ]]; then
    sync_packages
    exit 0
fi

# From the host: create/update the container, then sync
distrobox assemble create --file "${INI_FILE}" "$@"
distrobox enter dev -- "${SCRIPT_PATH}"
