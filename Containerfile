FROM quay.io/fedora-ostree-desktops/kinoite:42

# Keep container image for ~2 months
LABEL quay.expires-after=8w

COPY redhat-internal-cert-install-0.1-29.el7.noarch.rpm  redhat-internal-NetworkManager-openvpn-profiles-0.1-62.el8.noarch.rpm .

RUN /bin/bash -c "curl -L 'https://bitwarden.com/download/?app=cli&platform=linux' -o bw.zip && unzip bw.zip && mv bw /usr/bin && chmod +x /usr/bin/bw && rm bw.zip"

RUN rpm-ostree install distrobox tailscale fastfetch neovim git buildah fish fzf  ripgrep bat distrobox \
    stow fd-find wireguard-tools tmux NetworkManager-openvpn alacritty \
    redhat-internal-cert-install-0.1-29.el7.noarch.rpm  redhat-internal-NetworkManager-openvpn-profiles-0.1-62.el8.noarch.rpm https://github.com/block/goose/releases/download/v1.0.29/Goose-1.0.29-1.x86_64.rpm && \
    rm redhat-internal-cert-install-0.1-29.el7.noarch.rpm  redhat-internal-NetworkManager-openvpn-profiles-0.1-62.el8.noarch.rpm && \
	ostree container commit
