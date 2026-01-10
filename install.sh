#!/usr/bin/env bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

# Detect shell config file
detect_shell_config() {
    if [ -n "${BASH_VERSION:-}" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            echo "$HOME/.bashrc"
        else
            echo "$HOME/.bash_profile"
        fi
    elif [ -n "${ZSH_VERSION:-}" ]; then
        echo "$HOME/.zshrc"
    else
        # Fallback: check what shell is default
        local default_shell=$(basename "$SHELL")
        if [ "$default_shell" = "zsh" ]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.bashrc"
        fi
    fi
}

main() {
    info "Installing git-workspace..."

    INSTALL_PATH="/usr/local/bin/git-workspace"

    # Check if /usr/local/bin exists and is writable
    if [ ! -d "/usr/local/bin" ]; then
        info "Creating /usr/local/bin..."
        sudo mkdir -p /usr/local/bin || error "Failed to create /usr/local/bin"
    fi

    # Download script
    info "Downloading latest version to $INSTALL_PATH..."

    if [ -w "/usr/local/bin" ]; then
        # Can write directly
        curl -fsSL "https://raw.githubusercontent.com/dylanrichardson/git-workspace/main/git-workspace" \
            -o "$INSTALL_PATH" || error "Failed to download git-workspace"
        chmod +x "$INSTALL_PATH"
    else
        # Need sudo
        local tmp_file=$(mktemp)
        curl -fsSL "https://raw.githubusercontent.com/dylanrichardson/git-workspace/main/git-workspace" \
            -o "$tmp_file" || error "Failed to download git-workspace"
        sudo mv "$tmp_file" "$INSTALL_PATH" || error "Failed to install git-workspace"
        sudo chmod +x "$INSTALL_PATH"
    fi

    # Verify installation
    if ! "$INSTALL_PATH" --help >/dev/null 2>&1; then
        error "Installation failed - script not working"
    fi

    info "✓ git-workspace installed to $INSTALL_PATH"

    # Detect shell and offer to add integration
    SHELL_CONFIG=$(detect_shell_config)

    echo ""
    info "Next step: Add shell integration to $SHELL_CONFIG"
    echo ""
    echo "Run this command:"
    echo "  echo 'eval \"\$(git-workspace init bash)\"' >> $SHELL_CONFIG"
    echo ""
    echo "Then reload your shell:"
    echo "  source $SHELL_CONFIG"
    echo ""
    info "After that, you can use: git-workspace enter"
}

main "$@"
