#!/bin/bash
set -euo pipefail

# Nova Shield - Super Simple Installer for Everyone
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash

INSTALL_DIR="$HOME/.nova-shield"
NODE_MIN_VERSION="20"

echo "🛡️ Installing Nova Shield - AI Cybersecurity Expert"
echo "=================================================="

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Install Homebrew (macOS)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            export PATH="/usr/local/bin:$PATH"
        fi
    fi
    echo "✅ Homebrew available"
}

# Install Node.js automatically
install_node() {
    if ! command -v node &> /dev/null; then
        echo "📦 Installing Node.js..."
        OS=$(detect_os)
        
        if [[ "$OS" == "macos" ]]; then
            install_homebrew
            brew install node
        elif [[ "$OS" == "linux" ]]; then
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
        else
            echo "❌ Automatic Node.js installation not supported for this OS"
            echo "Please install Node.js manually from: https://nodejs.org/"
            exit 1
        fi
    fi
    
    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt "$NODE_MIN_VERSION" ]; then
        echo "❌ Node.js ${NODE_VERSION} too old. Need ${NODE_MIN_VERSION}+"
        echo "Please update Node.js from: https://nodejs.org/"
        exit 1
    fi
    echo "✅ Node.js $(node --version)"
}

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

# Clean installation
cleanup() {
    echo "🧹 Cleaning previous installations..."
    pkill -f 'nova|codex' 2>/dev/null || true
    npm uninstall -g nova-shield 2>/dev/null || true
    rm -rf "$INSTALL_DIR" 2>/dev/null || true
    echo "✅ Cleanup complete"
}

# Download binary
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
        echo ""
        echo "🔧 This might be because:"
        echo "  - No pre-built binary available for your platform"
        echo "  - Network connectivity issues"
        echo ""
        echo "💡 Try the source build installer instead:"
        echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-source.sh | bash"
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

# Main flow
main() {
    echo "🚀 Starting Nova Shield installation..."
    
    install_node
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
    echo "💡 Installation completed automatically!"
}

main "$@"
