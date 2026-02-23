FROM quay.io/fedora/fedora-bootc:latest

# Copy local RPM packages
COPY rpms/*.rpm .

# Add third-party repositories
RUN dnf install -y 'dnf5-command(copr)' && \
    dnf copr enable -y karmab/kcli && \
    dnf copr enable -y solopasha/hyprland

# Install packages
RUN dnf install -y \
        hyprland hypridle hyprshot hyprpanel hyprsunset \
        hyprlock hyprpolkitagent xdg-desktop-portal-hyprland \
        hyprsysteminfo hyprland-autoname-workspaces \
        hyprland-plugins hyprland-contrib hyprqt6engine \
        pipewire wireplumber \
        qt5-qtwayland qt6-qtwayland \
        dolphin sddm okular gwenview \
        glibc-langpack-en kubectl \
        flatpak btop bc pamixer playerctl elephant swayosd walker \
        network-manager-applet blueman waybar swww protonvpn-cli  \
        rofi udiskie pavucontrol brightnessctl flatseal \
        distrobox tailscale fastfetch neovim git buildah fish fzf ripgrep bat \
        stow fd-find wireguard-tools NetworkManager-openvpn alacritty \
        libvirt virt-manager virt-install kcli \
        linux-firmware linux-firmware-whence alsa-sof-firmware realtek-firmware \
        NetworkManager-wifi NetworkManager-wwan NetworkManager-bluetooth curl \
        restic rclone \
        alsa-ucm alsa-utils krb5-workstation \
        firefox chromium xdg-terminal-exec wiremix mako && \
    dnf install -y --setopt=tsflags=noscripts *.rpm && \
    rm *.rpm && \
    dnf clean all

# Install x86_64-only packages (Intel firmware, drivers, and copr repos)
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        dnf install -y 'dnf5-command(copr)' && \
        dnf copr enable -y washkinazy/wayland-wm-extras && \
        dnf install -y \
            intel-audio-firmware intel-gmmlib intel-gpu-firmware \
            intel-mediasdk intel-vpl-gpu-rt intel-vsc-firmware \
            iwlwifi-dvm-firmware iwlwifi-mvm-firmware \
            libva-intel-media-driver && \
        dnf clean all; \
    fi

# Install OpenCode
RUN dnf install -y https://opencode.ai/download/stable/linux-$(uname -m | sed 's/aarch64/arm64/;s/x86_64/x64/')-rpm && \
    dnf clean all

# Copy system configuration files
COPY rootfs/ /

# Set executable permissions and configure timezone/sudoers
RUN ln -sf ../usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel && \
    systemctl preset-all \
