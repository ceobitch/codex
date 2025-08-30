#!/bin/bash
set -euo pipefail

# Nova Shield - Professional One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/nova-cli/main/install-nova.sh | bash

REPO_URL="https://github.com/ceobitch/nova-cli.git"
INSTALL_DIR="$HOME/.nova-shield"
NODE_MIN_VERSION="20"

echo "🛡️ Installing Nova Shield - AI Cybersecurity Expert"
echo "=================================================="

# Check Node.js
check_node() {
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js ${NODE_MIN_VERSION}+ required. Install from: https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt "$NODE_MIN_VERSION" ]; then
        echo "❌ Node.js ${NODE_VERSION} too old. Need ${NODE_MIN_VERSION}+: https://nodejs.org/"
        exit 1
    fi
    echo "✅ Node.js $(node --version)"
}

# Check Git
check_git() {
    if ! command -v git &> /dev/null; then
        echo "❌ Git required. Install git first."
        exit 1
    fi
    echo "✅ Git $(git --version | cut -d' ' -f3)"
}

# Clean installation
cleanup() {
    echo "🧹 Cleaning previous installations..."
    pkill -f 'nova|codex' 2>/dev/null || true
    npm uninstall -g nova-shield 2>/dev/null || true
    rm -rf "$INSTALL_DIR" 2>/dev/null || true
    echo "✅ Cleanup complete"
}

# Install Nova Shield
install_nova() {
    echo "📦 Installing Nova Shield..."
    
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR/codex-cli"
    
    echo "Installing dependencies..."
    npm install
    
    echo "Installing Nova globally..."
    npm install -g .
    
    echo "✅ Nova Shield installed!"
}

# Verify installation
verify() {
    if command -v nova &> /dev/null; then
        echo "✅ Nova command available"
        echo "📍 Location: $(which nova)"
    else
        echo "❌ Installation failed"
        exit 1
    fi
}

# Main flow
main() {
    check_node
    check_git
    cleanup
    install_nova
    verify
    
    echo ""
    echo "🎉 Nova Shield Ready!"
    echo "==================="
    echo ""
    echo "🛡️ Your AI cybersecurity expert is ready!"
    echo ""
    echo "Quick start:"
    echo "  nova                # Start Nova Shield"
    echo "  nova --help         # Show help"
    echo ""
    echo "🔥 Get started: nova"
}

main "$@"
