FROM quay.io/fedora-ostree-desktops/kinoite:42

LABEL quay.expires-after=8w

COPY *.rpm .

RUN /bin/bash -c "curl -L 'https://bitwarden.com/download/?app=cli&platform=linux' -o bw.zip && unzip bw.zip && mv bw /usr/bin && chmod +x /usr/bin/bw && rm bw.zip"

RUN rpm-ostree install distrobox tailscale fastfetch \
    neovim git buildah fish fzf  ripgrep bat distrobox \
    stow fd-find wireguard-tools tmux \
    NetworkManager-openvpn alacritty libvirt virt-manager  \
    *.rpm && \
    rm *.rpm && \
	ostree container commit
