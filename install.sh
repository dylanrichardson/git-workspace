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

# Detect install location
detect_install_path() {
    # Check common locations in order of preference
    if [ -w "/usr/local/bin" ]; then
        echo "/usr/local/bin/git-workspace"
    elif mkdir -p "$HOME/.local/bin" 2>/dev/null; then
        echo "$HOME/.local/bin/git-workspace"
    elif mkdir -p "$HOME/bin" 2>/dev/null; then
        echo "$HOME/bin/git-workspace"
    else
        error "No writable install location found. Try: sudo mkdir -p /usr/local/bin && sudo chown $USER /usr/local/bin"
    fi
}

# Check if location is in PATH
check_in_path() {
    local dir=$(dirname "$1")
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        return 0
    else
        return 1
    fi
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

    # Detect install location
    INSTALL_PATH=$(detect_install_path)
    info "Install location: $INSTALL_PATH"

    # Download script
    info "Downloading latest version..."
    curl -fsSL "https://raw.githubusercontent.com/dylanrichardson/git-workspace/main/git-workspace" \
        -o "$INSTALL_PATH" || error "Failed to download git-workspace"

    # Make executable
    chmod +x "$INSTALL_PATH"

    # Verify installation
    if ! "$INSTALL_PATH" --help >/dev/null 2>&1; then
        error "Installation failed - script not working"
    fi

    info "✓ git-workspace installed successfully!"

    # Check if in PATH
    if ! check_in_path "$INSTALL_PATH"; then
        warn "Warning: $(dirname "$INSTALL_PATH") is not in your PATH"
        warn "Add this to your shell config:"
        warn "  export PATH=\"$(dirname "$INSTALL_PATH"):\$PATH\""
    fi

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
