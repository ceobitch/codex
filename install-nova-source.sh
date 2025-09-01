#!/bin/bash
set -euo pipefail

# Nova Shield - Source Build Installer (Fallback)
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-source.sh | bash

REPO_URL="https://github.com/ceobitch/codex.git"
INSTALL_DIR="$HOME/.nova-shield"
NODE_MIN_VERSION="20"

echo "🛡️ Installing Nova Shield - Source Build"
echo "========================================="

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

# Check Rust
check_rust() {
    if ! command -v cargo &> /dev/null; then
        echo "❌ Rust required. Install from: https://rustup.rs/"
        exit 1
    fi
    echo "✅ Rust $(cargo --version | cut -d' ' -f2)"
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
        exit 1
    fi
    
    echo "✅ Nova built successfully"
    
    # Create wrapper script
    echo "📁 Creating nova wrapper script..."
    mkdir -p ../codex-cli/bin
    
    cat > ../codex-cli/bin/nova << 'EOF'
#!/bin/bash

# Nova Shield - Wrapper Script
# Handles nova command and special commands like update

cd "$HOME/.nova-shield"

# Check if this is an update command
if [[ "$1" == "update" ]]; then
    echo "🔄 Updating Nova Shield..."
    echo "=========================="
    
    # Check if we're in a git repository
    if [ -d ".git" ]; then
        echo "📥 Fetching latest changes from git..."
        git fetch origin main
        
        # Check if there are updates
        LOCAL_COMMIT=$(git rev-parse HEAD)
        REMOTE_COMMIT=$(git rev-parse origin/main)
        
        if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
            echo "🔄 Updates available! Building latest version..."
            git pull origin main
            
            # Rebuild Nova
            echo "🔨 Building latest Nova Shield..."
            cd codex-rs
            cargo build --release -p codex-tui
            
            if [ -f "target/release/codex-tui" ]; then
                echo "✅ Nova Shield updated successfully!"
                echo ""
                echo "🛡️ Latest version is now ready to use!"
            else
                echo "❌ Build failed during update"
                exit 1
            fi
        else
            echo "✅ Nova Shield is already up to date!"
        fi
    else
        echo "❌ Not a git repository"
        echo "💡 Try reinstalling: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        exit 1
    fi
else
    # Run the normal Nova Shield binary
    ./codex-rs/target/release/codex-tui "$@"
fi
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
            exit 1
        fi
    else
        echo "❌ Installation failed - nova command not found"
        exit 1
    fi
}

# Main flow
main() {
    echo "🚀 Starting Nova Shield source build installation..."
    
    check_node
    check_git
    check_rust
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
    echo ""
    echo "💡 Installation completed using source build!"
}

main "$@"
