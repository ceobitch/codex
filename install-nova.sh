#!/bin/bash
set -euo pipefail

# Nova Shield - Professional One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash

REPO_URL="https://github.com/ceobitch/codex.git"
INSTALL_DIR="$HOME/.nova-shield"
NODE_MIN_VERSION="20"

echo "🛡️ Installing Nova Shield - AI Cybersecurity Expert"
echo "=================================================="

# Check if running in interactive mode
check_interactive() {
    if [[ ! -t 0 ]]; then
        echo "⚠️  Running in non-interactive mode"
        echo "   Some installations may require manual intervention"
        echo ""
    fi
}

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

# Check if user has sudo access
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "⚠️  Sudo access required for some installations"
        echo "   You may be prompted for your password"
        echo ""
    fi
}

# Install Homebrew (macOS) with better error handling
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        
        # Check if we can install Homebrew
        if [[ ! -t 0 ]]; then
            echo "❌ Cannot install Homebrew in non-interactive mode"
            echo ""
            echo "🔧 Manual installation required:"
            echo "   1. Run this command in your terminal:"
            echo "      /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo "   2. Then run this installer again:"
            echo "      curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
            echo ""
            echo "💡 Alternative: Use the quick installer (requires Node.js):"
            echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash"
            exit 1
        fi
        
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

# Install Rust with better error handling
install_rust() {
    if ! command -v cargo &> /dev/null; then
        echo "🦀 Installing Rust..."
        
        # Check if we can install Rust
        if [[ ! -t 0 ]]; then
            echo "❌ Cannot install Rust in non-interactive mode"
            echo ""
            echo "🔧 Manual installation required:"
            echo "   1. Run this command in your terminal:"
            echo "      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            echo "   2. Then run this installer again:"
            echo "      curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
            echo ""
            echo "💡 Alternative: Use the quick installer (requires Node.js):"
            echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash"
            exit 1
        fi
        
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Source Rust environment
        source "$HOME/.cargo/env"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    echo "✅ Rust $(cargo --version | cut -d' ' -f2)"
}

# Install Node.js with better error handling
install_node() {
    if ! command -v node &> /dev/null; then
        echo "📦 Installing Node.js..."
        OS=$(detect_os)
        
        if [[ "$OS" == "macos" ]]; then
            # Try to install Homebrew first
            if command -v brew &> /dev/null; then
                brew install node
            else
                echo "❌ Homebrew not available for Node.js installation"
                echo ""
                echo "🔧 Manual installation required:"
                echo "   1. Install Node.js from: https://nodejs.org/"
                echo "   2. Then run this installer again:"
                echo "      curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
                echo ""
                echo "💡 Alternative: Use the quick installer (requires Node.js):"
                echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash"
                exit 1
            fi
        elif [[ "$OS" == "linux" ]]; then
            # Check sudo access
            if ! sudo -n true 2>/dev/null; then
                echo "❌ Sudo access required for Node.js installation"
                echo ""
                echo "🔧 Manual installation required:"
                echo "   1. Install Node.js from: https://nodejs.org/"
                echo "   2. Then run this installer again:"
                echo "      curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
                echo ""
                echo "💡 Alternative: Use the quick installer (requires Node.js):"
                echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash"
                exit 1
            fi
            
            # Use NodeSource repository for Linux
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

# Install Git with better error handling
install_git() {
    if ! command -v git &> /dev/null; then
        echo "📚 Installing Git..."
        OS=$(detect_os)
        
        if [[ "$OS" == "macos" ]]; then
            if command -v brew &> /dev/null; then
                brew install git
            else
                echo "❌ Homebrew not available for Git installation"
                echo ""
                echo "🔧 Manual installation required:"
                echo "   1. Install Git from: https://git-scm.com/"
                echo "   2. Then run this installer again:"
                echo "      curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
                exit 1
            fi
        elif [[ "$OS" == "linux" ]]; then
            # Check sudo access
            if ! sudo -n true 2>/dev/null; then
                echo "❌ Sudo access required for Git installation"
                echo ""
                echo "🔧 Manual installation required:"
                echo "   1. Install Git from: https://git-scm.com/"
                echo "   2. Then run this installer again:"
                echo "      curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
                exit 1
            fi
            
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

# Check and install dependencies
setup_dependencies() {
    echo "🔧 Setting up dependencies..."
    
    # Check interactive mode and sudo access first
    check_interactive
    check_sudo
    
    install_git
    install_rust
    install_node
    
    echo "✅ All dependencies ready"
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
    
    # Clone repository
    echo "📥 Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    
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
        echo ""
        echo "🔧 Troubleshooting:"
        echo "   1. Make sure you have enough disk space"
        echo "   2. Try running: cd $INSTALL_DIR/codex-rs && cargo build --release -p codex-tui"
        echo "   3. Check the error messages above"
        exit 1
    fi
    
    echo "✅ Nova built successfully"
    
    # Create wrapper script
    echo "📁 Creating nova wrapper script..."
    mkdir -p ../codex-cli/bin
    
    cat > ../codex-cli/bin/nova << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/../.."
./codex-rs/target/release/codex-tui "$@"
EOF
    
    chmod +x ../codex-cli/bin/nova
    
    # Verify wrapper script
    if [ ! -x "../codex-cli/bin/nova" ]; then
        echo "❌ Failed to create nova wrapper script"
        exit 1
    fi
    
    echo "✅ Nova wrapper script created"
    
    # Install npm package
    echo "📦 Installing npm package..."
    cd ../codex-cli
    
    if [ ! -f "package.json" ]; then
        echo "❌ package.json not found in $INSTALL_DIR/codex-cli"
        exit 1
    fi
    
    npm install -g .
    
    echo "✅ Nova Shield installed!"
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
            echo ""
            echo "🔧 Troubleshooting:"
            echo "   1. Try running: nova --help"
            echo "   2. Check if the binary exists: ls -la $INSTALL_DIR/codex-rs/target/release/"
            echo "   3. Try reinstalling: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
            exit 1
        fi
    else
        echo "❌ Installation failed - nova command not found"
        echo ""
        echo "🔧 Troubleshooting:"
        echo "   1. Check if npm install worked: npm list -g nova-shield"
        echo "   2. Try reinstalling: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        echo "   3. Or try the quick installer: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash"
        exit 1
    fi
}

# Main flow
main() {
    echo "🚀 Starting Nova Shield installation..."
    
    setup_dependencies
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
