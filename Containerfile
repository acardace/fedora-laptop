FROM quay.io/fedora/fedora-bootc:latest

# Copy local RPM packages
COPY rpms/*.rpm .

# Add third-party repositories
RUN dnf install -y 'dnf5-command(copr)' && \
    dnf copr enable -y karmab/kcli && \
    dnf copr enable -y solopasha/hyprland && \
    dnf copr enable -y washkinazy/wayland-wm-extras

# Install packages
RUN dnf install -y \
        hyprland hypridle hyprshot hyprpanel hyprsunset \
        hyprlock hyprpolkitagent xdg-desktop-portal-hyprland \
        hyprsysteminfo hyprland-autoname-workspaces \
        hyprland-plugins hyprland-contrib hyprqt6engine \
        pipewire wireplumber \
        qt5-qtwayland qt6-qtwayland qt5ct qt6ct \
        breeze-icon-theme breeze-cursor-theme plasma-breeze \
        xdg-desktop-portal-kde kio-extras kde-settings ark \
        dolphin sddm sddm-breeze okular gwenview \
        glibc-langpack-en kubectl \
        meld gh jq yq tmux \
        flatpak btop bc pamixer playerctl elephant swayosd walker \
        network-manager-applet blueman waybar swww protonvpn-cli \
        rofi udiskie pavucontrol brightnessctl flatseal \
        distrobox tailscale fastfetch neovim git buildah fish fzf ripgrep bat \
        stow fd-find wireguard-tools NetworkManager-openvpn alacritty kitty \
        libvirt virt-manager virt-install kcli \
        linux-firmware linux-firmware-whence alsa-sof-firmware realtek-firmware \
        intel-audio-firmware intel-gmmlib intel-gpu-firmware \
        intel-mediasdk intel-vpl-gpu-rt intel-vsc-firmware \
        iwlwifi-dvm-firmware iwlwifi-mvm-firmware libva-intel-media-driver \
        NetworkManager-wifi NetworkManager-wwan NetworkManager-bluetooth curl \
        restic rclone fprintd fprintd-pam pinentry-qt \
        alsa-ucm alsa-utils krb5-workstation \
        firefox chromium xdg-terminal-exec wiremix mako && \
    dnf install -y --setopt=tsflags=noscripts *.rpm && \
    rm *.rpm && \
    dnf clean all

# Install OpenCode
RUN dnf install -y https://github.com/anomalyco/opencode/releases/latest/download/opencode-desktop-linux-$(uname -m).rpm && \
    dnf clean all

# Copy system configuration files
COPY rootfs/ /

# Set executable permissions and configure timezone/sudoers
RUN ln -sf ../usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel && \
    systemctl preset-all \
