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
    
    # Force remove the installation directory
    if [ -d "$INSTALL_DIR" ]; then
        echo "🗑️  Removing existing Nova Shield directory..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Double-check and force remove if still exists
    if [ -d "$INSTALL_DIR" ]; then
        echo "🔧 Force removing directory..."
        sudo rm -rf "$INSTALL_DIR" 2>/dev/null || rm -rf "$INSTALL_DIR"
    fi
    
    echo "✅ Cleanup complete"
}

# Download binary
download_binary() {
    PLATFORM=$(detect_platform)
    BINARY_NAME="nova-${PLATFORM}"
    DOWNLOAD_URL="https://github.com/ceobitch/codex/releases/latest/download/${BINARY_NAME}"
    
    echo "📥 Downloading Nova Shield binary for ${PLATFORM}..."
    
    # Download binary to temp location first
    TEMP_BINARY="/tmp/nova-${PLATFORM}"
    
    if curl -fsSL -o "$TEMP_BINARY" "$DOWNLOAD_URL"; then
        # Create installation directory only if download succeeds
        mkdir -p "$INSTALL_DIR/codex-cli/bin"
        mv "$TEMP_BINARY" "$INSTALL_DIR/codex-cli/bin/nova"
        chmod +x "$INSTALL_DIR/codex-cli/bin/nova"
        echo "✅ Binary downloaded successfully"
        return 0
    else
        echo "❌ Failed to download binary"
        echo ""
        echo "🔄 No pre-built binary available, switching to source build..."
        echo ""
        return 1
    fi
}

# Install from source
install_from_source() {
    echo "🔨 Building Nova Shield from source..."
    
    # Install required dependencies
    install_git
    install_rust
    
    # Clone repository
    echo "📥 Cloning repository..."
    git clone "https://github.com/ceobitch/codex.git" "$INSTALL_DIR"
    
    # Verify clone
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "❌ Failed to clone repository"
        exit 1
    fi
    
    echo "✅ Repository cloned to $INSTALL_DIR"
    
    # Build Nova from source
    echo "🔨 Building Nova Shield from source..."
    cd "$INSTALL_DIR/codex-rs"
    
    if [ ! -f "Cargo.toml" ]; then
        echo "❌ Cargo.toml not found in $INSTALL_DIR/codex-rs"
        exit 1
    fi
    
    echo "📦 Building with cargo (this may take a few minutes)..."
    cargo build --release -p codex-tui
    
    # Verify build
    if [ ! -f "target/release/codex-tui" ]; then
        echo "❌ Build failed - codex-tui binary not found"
        exit 1
    fi
    
    echo "✅ Nova built successfully"
    
    # Create wrapper script
    echo "📁 Creating nova wrapper script..."
    mkdir -p "$INSTALL_DIR/codex-cli/bin"
    
    cat > ../codex-cli/bin/nova << 'EOF'
#!/bin/bash
cd "$HOME/.nova-shield"
./codex-rs/target/release/codex-tui "$@"
EOF
    
    chmod +x ../codex-cli/bin/nova
    
    # Verify wrapper script
    if [ ! -x "../codex-cli/bin/nova" ]; then
        echo "❌ Failed to create nova wrapper script"
        exit 1
    fi
    
    echo "✅ Nova wrapper script created"
}

# Install Git
install_git() {
    if ! command -v git &> /dev/null; then
        echo "📚 Installing Git..."
        OS=$(detect_os)
        
        if [[ "$OS" == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install git
            else
                echo "❌ Homebrew not available for Git installation"
                echo "Please install Git manually from: https://git-scm.com/"
                exit 1
            fi
        elif [[ "$OS" == "linux" ]]; then
            sudo apt-get update
            sudo apt-get install -y git
        else
            echo "❌ Automatic Git installation not supported for this OS"
            echo "Please install Git manually from: https://git-scm.com/"
            exit 1
        fi
    fi
    echo "✅ Git $(git --version | cut -d' ' -f3)"
}

# Install Rust
install_rust() {
    if ! command -v cargo &> /dev/null; then
        echo "🦀 Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Source Rust environment
        source "$HOME/.cargo/env"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    echo "✅ Rust $(cargo --version | cut -d' ' -f2)"
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
    
    # Clean up any existing installation first
    cleanup
    
    install_node
    
    if ! download_binary; then
        install_from_source
    fi
    
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
