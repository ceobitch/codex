#!/bin/bash
set -euo pipefail

# Nova Shield - Quick Installer (Pre-built Binaries)
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash

INSTALL_DIR="$HOME/.nova-shield"
NODE_MIN_VERSION="20"

echo "🛡️ Installing Nova Shield - Quick Install"
echo "========================================="

# Detect OS and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    case $OS in
        darwin) OS="apple-darwin" ;;
        linux) OS="unknown-linux-gnu" ;;
        *) echo "❌ Unsupported OS: $OS"; exit 1 ;;
    esac
    
    echo "${ARCH}-${OS}"
}

# Install Node.js (minimal check)
check_node() {
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js ${NODE_MIN_VERSION}+ required for npm package management"
        echo "Please install Node.js from: https://nodejs.org/"
        echo "Or use the full installer: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt "$NODE_MIN_VERSION" ]; then
        echo "❌ Node.js ${NODE_VERSION} too old. Need ${NODE_MIN_VERSION}+"
        echo "Please update Node.js from: https://nodejs.org/"
        exit 1
    fi
    echo "✅ Node.js $(node --version)"
}

# Download pre-built binary
download_binary() {
    PLATFORM=$(detect_platform)
    BINARY_NAME="nova-${PLATFORM}"
    DOWNLOAD_URL="https://github.com/ceobitch/codex/releases/latest/download/${BINARY_NAME}"
    
    echo "📥 Downloading Nova Shield binary for ${PLATFORM}..."
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR/codex-cli/bin"
    
    # Download binary
    if curl -fsSL -o "$INSTALL_DIR/codex-cli/bin/nova" "$DOWNLOAD_URL"; then
        chmod +x "$INSTALL_DIR/codex-cli/bin/nova"
        echo "✅ Binary downloaded successfully"
    else
        echo "❌ Failed to download binary"
        echo "This might be because:"
        echo "  - No pre-built binary available for your platform"
        echo "  - Network connectivity issues"
        echo ""
        echo "Try the full installer instead:"
        echo "curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        exit 1
    fi
}

# Install npm package
install_npm_package() {
    echo "📦 Installing npm package..."
    
    # Create minimal package.json for the binary
    cat > "$INSTALL_DIR/codex-cli/package.json" << 'EOF'
{
  "name": "nova-shield",
  "version": "1.0.0",
  "description": "Nova Shield - AI Cybersecurity Expert",
  "bin": {
    "nova": "bin/nova"
  },
  "files": ["bin/"],
  "repository": {
    "type": "git",
    "url": "https://github.com/ceobitch/codex.git"
  },
  "keywords": ["ai", "cybersecurity", "cli", "nova"],
  "author": "$NVIA 3SkFJRqMPTKZLqKK1MmY2mvAm711FGAtJ9ZbL6r1coin",
  "license": "MIT"
}
EOF
    
    cd "$INSTALL_DIR/codex-cli"
    npm install -g .
    echo "✅ npm package installed"
}

# Verify installation
verify() {
    echo "🧪 Verifying installation..."
    
    if command -v nova &> /dev/null; then
        echo "✅ Nova command available"
        echo "📍 Location: $(which nova)"
        
        # Test if nova works
        echo "🧪 Testing Nova command..."
        if nova --help &> /dev/null; then
            echo "✅ Nova command working correctly"
        else
            echo "❌ Nova command has issues"
            exit 1
        fi
    else
        echo "❌ Installation failed - nova command not found"
        exit 1
    fi
}

# Clean installation
cleanup() {
    echo "🧹 Cleaning previous installations..."
    pkill -f 'nova|codex' 2>/dev/null || true
    npm uninstall -g nova-shield 2>/dev/null || true
    rm -rf "$INSTALL_DIR" 2>/dev/null || true
    echo "✅ Cleanup complete"
}

# Main flow
main() {
    echo "🚀 Starting Nova Shield quick installation..."
    
    check_node
    cleanup
    download_binary
    install_npm_package
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
    echo ""
    echo "💡 Note: This is a quick install using pre-built binaries."
    echo "   For source builds, use: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
}

main "$@"
