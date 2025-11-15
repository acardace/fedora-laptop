FROM quay.io/fedora/fedora-bootc:43

LABEL quay.expires-after=12w

# Copy local RPM packages
COPY rpms/*.rpm .

# Add third-party repositories
RUN dnf install -y 'dnf5-command(copr)' && \
    dnf copr enable -y karmab/kcli && \
    dnf copr enable -y solopasha/hyprland && \
    dnf copr enable -y erikreider/SwayNotificationCenter

# Install packages
RUN dnf install -y \
        hyprland hypridle hyprshot hyprpanel hyprsunset \
        hyprlock hyprpolkitagent xdg-desktop-portal-hyprland \
        hyprsysteminfo hyprland-autoname-workspaces \
        hyprland-plugins hyprland-contrib hyprqt6engine \
        SwayNotificationCenter pipewire wireplumber \
        qt5-qtwayland qt6-qtwayland \
        dolphin sddm okular gwenview \
        glibc-langpack-en kubectl \
        flatpak btop bc pamixer playerctl \
        ramalama \
        network-manager-applet blueman waybar swww  \
        rofi udiskie pavucontrol brightnessctl flatseal \
        distrobox tailscale fastfetch neovim git buildah fish fzf ripgrep bat \
        stow fd-find wireguard-tools NetworkManager-openvpn alacritty \
        libvirt virt-manager virt-install kcli nodejs-npm \
        linux-firmware linux-firmware-whence alsa-sof-firmware intel-audio-firmware realtek-firmware \
        iwlwifi-dvm-firmware iwlwifi-mvm-firmware libva-intel-media-driver \
        intel-gmmlib intel-gpu-firmware intel-mediasdk intel-vpl-gpu-rt intel-vsc-firmware \
        NetworkManager-wifi NetworkManager-wwan NetworkManager-bluetooth curl \
        restic rclone \
        alsa-ucm alsa-utils krb5-workstation \
        firefox chromium xdg-terminal-exec wiremix mako && \
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
