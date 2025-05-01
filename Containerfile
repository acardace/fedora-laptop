FROM quay.io/fedora-ostree-desktops/cosmic-atomic:42

# Keep container image for ~2 months
LABEL quay.expires-after=8w

COPY redhat-internal-cert-install-0.1-29.el7.noarch.rpm  redhat-internal-NetworkManager-openvpn-profiles-0.1-62.el8.noarch.rpm .

RUN rpm-ostree install fastfetch neovim git buildah fish fzf  ripgrep bat \
    stow fd-find wireguard-tools tmux NetworkManager-openvpn \
    redhat-internal-cert-install-0.1-29.el7.noarch.rpm  redhat-internal-NetworkManager-openvpn-profiles-0.1-62.el8.noarch.rpm && \
    rm redhat-internal-cert-install-0.1-29.el7.noarch.rpm  redhat-internal-NetworkManager-openvpn-profiles-0.1-62.el8.noarch.rpm && \
	ostree container commit
