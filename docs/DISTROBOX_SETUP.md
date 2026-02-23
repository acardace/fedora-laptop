# Development Environment with Distrobox

This guide explains how to set up a development environment using Distrobox for tools that are excluded from the main bootc image to keep it smaller.

## Why Distrobox?

The main bootc image excludes certain development tools to reduce image size and build time:

**Excluded packages (~600 MiB):**
- `google-cloud-cli` (487 MiB) - Google Cloud SDK
- `golang` (~24 MiB) - Go programming language
- `gopls` (~8 MiB) - Go language server
- `rust` + `cargo` (~80 MiB) - Rust programming language and package manager
- `libxcrypt-compat` (~200 KiB) - Legacy crypt library

These tools are installed in a Distrobox container instead, providing:
- ✓ Smaller bootc image (faster updates, less disk usage)
- ✓ Isolated development environment
- ✓ Easy to reset/recreate
- ✓ Commands exported to host (work transparently)
- ✓ Access to host filesystem and resources

## Quick Setup

Run the automated setup script:

```bash
./scripts/setup-devbox.sh
```

This will:
1. Create a Fedora 42 distrobox named `dev` (or update if it exists)
2. Install golang, gopls, rust, cargo, google-cloud-cli, and libxcrypt-compat
3. Export common commands to the host (`go`, `cargo`, `rustc`, `gcloud`, etc.)

**The script is idempotent** - you can run it repeatedly to update packages. Use `--recreate` for a fresh start:

```bash
# Update packages in existing distrobox
./scripts/setup-devbox.sh

# Force recreation (clean slate)
./scripts/setup-devbox.sh --recreate
```

## Manual Setup

If you prefer to set up manually:

### Create the Distrobox

```bash
distrobox create --name dev --image fedora:42
```

### Install Packages

```bash
distrobox enter dev
```

Inside the container:

```bash
# Add Google Cloud CLI repository
sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null << 'EOF'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install development packages
sudo dnf install -y golang gopls rust cargo google-cloud-cli libxcrypt-compat.x86_64
```

### Export Commands to Host

While inside the container, export commands:

```bash
# Go tools
distrobox-export --bin /usr/bin/go
distrobox-export --bin /usr/bin/gofmt
distrobox-export --bin /usr/bin/gopls

# Rust tools
distrobox-export --bin /usr/bin/cargo
distrobox-export --bin /usr/bin/rustc
distrobox-export --bin /usr/bin/rustfmt
distrobox-export --bin /usr/bin/rust-analyzer

# Google Cloud tools
distrobox-export --bin /usr/bin/gcloud
distrobox-export --bin /usr/bin/gsutil
distrobox-export --bin /usr/bin/bq
```

Exit the container:
```bash
exit
```

## Usage

### Using Exported Commands

After export, commands work directly from your host shell:

```bash
# These run inside the distrobox but feel like native commands
go version
cargo --version
rustc --version
gcloud --version
```

Exported binaries are located in `~/.local/bin/` (automatically in your PATH).

### Entering the Distrobox

To run commands inside the container or install additional packages:

```bash
distrobox enter dev
```

Inside, you have full access to:
- Your home directory (shared with host)
- Host filesystem
- Host's network configuration
- Host's X11/Wayland display (for GUI apps)

### Working with Go

Development works seamlessly:

```bash
# Create a Go project (on host or in distrobox)
mkdir ~/myproject && cd ~/myproject
go mod init example.com/myproject

# Use gopls with your editor (it's exported to host)
# Your LSP configuration will find gopls automatically

# Build and run
go build
./myproject
```

### Working with Rust

Rust development works transparently:

```bash
# Create a new Rust project
cargo new myproject
cd myproject

# Build and run
cargo build
cargo run

# Use rust-analyzer with your editor
# The LSP will find rust-analyzer automatically

# Add dependencies
cargo add serde
```

### Working with Google Cloud

```bash
# Initialize gcloud (first time only)
gcloud init

# Use gcloud commands normally
gcloud projects list
gsutil ls
bq ls
```

Configuration is stored in `~/.config/gcloud` (persisted on host).

## Managing the Distrobox

### List Distroboxes

```bash
distrobox list
```

### Stop/Start

```bash
# Stop
distrobox stop dev

# Start (happens automatically when you enter)
distrobox enter dev
```

### Update Packages

```bash
distrobox enter dev
sudo dnf update
exit
```

### Remove and Recreate

```bash
# Remove
distrobox rm dev

# Recreate (run setup script again)
./scripts/setup-devbox.sh
```

### Install Additional Packages

```bash
distrobox enter dev
sudo dnf install <package-name>

# Export if it's a command-line tool
distrobox-export --bin /usr/bin/<command>
```

## IDE Integration

### VS Code / VSCodium

Since commands are exported to your host PATH, most extensions work automatically:

**Go extension:**
```json
{
  "go.gopath": "~/go",
  "go.toolsGopath": "~/go",
  "gopls": {}
}
```

**Rust Analyzer extension:**
```json
{
  "rust-analyzer.server.path": "rust-analyzer"
}
```
The extension will automatically use the exported `rust-analyzer` command.

**Google Cloud Code:**
- Works with exported `gcloud` command
- Configure project in extension settings

### Neovim

For LSP configuration (e.g., with nvim-lspconfig):

```lua
-- Go
require'lspconfig'.gopls.setup{}

-- Rust
require'lspconfig'.rust_analyzer.setup{}
```

Since `gopls` and `rust-analyzer` are in your PATH via export, they work automatically.

## Advanced Tips

### Custom Distrobox Image

Create a custom image with more tools:

```bash
distrobox create --name dev-full --image fedora:42
distrobox enter dev-full
sudo dnf install -y python3 nodejs rust cargo
# Export as needed
```

### Host Integration

Distrobox containers have access to:
- Docker/Podman socket (can build containers from inside)
- systemd user services
- SSH agent
- D-Bus

Example - Using host Docker:
```bash
distrobox enter dev
docker ps  # Uses host Docker daemon
```

### Performance

Distrobox has minimal overhead:
- No VM, just containers
- Direct filesystem access (no copying)
- Native CPU/memory performance
- Shared kernel with host

## Troubleshooting

### Command Not Found After Export

Ensure `~/.local/bin` is in your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
# Or for fish shell
fish_add_path ~/.local/bin
```

Reload your shell or source the config file.

### Distrobox Won't Start

Check Podman/Docker is running:
```bash
podman ps
```

Recreate the distrobox:
```bash
distrobox rm dev
./scripts/setup-devbox.sh
```

### Permission Denied Errors

Distrobox runs as your user, but might need to add user to groups:

```bash
# Usually not needed, but if you see permission errors:
distrobox enter dev
sudo usermod -aG wheel $USER
```

### Exported Command Shows Wrapper Script

This is normal - distrobox creates wrapper scripts in `~/.local/bin/` that:
1. Start the container if needed
2. Execute the command inside
3. Pass through all arguments

The wrappers are transparent and shouldn't cause issues.

## References

- [Distrobox Documentation](https://distrobox.privatedns.org/)
- [Go Installation Guide](https://go.dev/doc/install)
- [Google Cloud CLI Docs](https://cloud.google.com/sdk/docs)
