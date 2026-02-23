FROM quay.io/fedora/fedora-bootc:latest

# Copy local RPM packages
COPY rpms/*.rpm .

# Add third-party repositories
RUN dnf install -y 'dnf5-command(copr)' && \
    dnf copr enable -y karmab/kcli

# Install packages
RUN dnf install -y \
        plasma-desktop plasma-workspace plasma-nm plasma-pa \
        plasma-systemmonitor plasma-disks plasma-thunderbolt \
        plasma-login-manager xdg-desktop-portal-kde \
        kde-gtk-config kdeplasma-addons kscreen kinfocenter \
        bluedevil powerdevil \
        pipewire wireplumber \
        qt5-qtwayland qt6-qtwayland \
        dolphin okular gwenview konsole spectacle \
        glibc-langpack-en kubectl \
        flatpak btop bc pamixer playerctl protonvpn-cli \
        pavucontrol brightnessctl flatseal \
        distrobox tailscale fastfetch neovim git buildah fish fzf ripgrep bat \
        stow fd-find wireguard-tools NetworkManager-openvpn alacritty \
        libvirt virt-manager virt-install kcli nodejs-npm \
        linux-firmware linux-firmware-whence alsa-sof-firmware intel-audio-firmware realtek-firmware \
        iwlwifi-dvm-firmware iwlwifi-mvm-firmware libva-intel-media-driver \
        intel-gmmlib intel-gpu-firmware intel-mediasdk intel-vpl-gpu-rt intel-vsc-firmware \
        NetworkManager-wifi NetworkManager-wwan NetworkManager-bluetooth curl \
        restic rclone \
        alsa-ucm alsa-utils krb5-workstation \
        firefox chromium xdg-terminal-exec && \
    dnf install -y --setopt=tsflags=noscripts *.rpm && \
    rm *.rpm && \
    dnf clean all

# Install Claude Code
RUN mkdir -p /var/roothome && \
    npm install -g @anthropic-ai/claude-code

# Copy system configuration files
COPY rootfs/ /

# Set executable permissions and configure timezone/sudoers
RUN ln -sf ../usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel && \
    systemctl preset-all \
