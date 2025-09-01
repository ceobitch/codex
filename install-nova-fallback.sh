#!/bin/bash
set -euo pipefail

# Nova Shield - Fallback Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-fallback.sh | bash

echo "🛡️ Nova Shield - Fallback Installation"
echo "======================================="
echo ""

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

OS=$(detect_os)

echo "🔍 Detected OS: $OS"
echo ""

# Check what's available
echo "🔧 Checking available tools..."
echo ""

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js: $NODE_VERSION"
else
    echo "❌ Node.js: Not found"
fi

# Check Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo "✅ Git: $GIT_VERSION"
else
    echo "❌ Git: Not found"
fi

# Check Rust
if command -v cargo &> /dev/null; then
    RUST_VERSION=$(cargo --version | cut -d' ' -f2)
    echo "✅ Rust: $RUST_VERSION"
else
    echo "❌ Rust: Not found"
fi

# Check Homebrew (macOS)
if [[ "$OS" == "macos" ]]; then
    if command -v brew &> /dev/null; then
        echo "✅ Homebrew: Available"
    else
        echo "❌ Homebrew: Not found"
    fi
fi

echo ""

# Determine best installation method
determine_method() {
    echo "🎯 Determining best installation method..."
    echo ""
    
    if command -v node &> /dev/null; then
        if command -v git &> /dev/null && command -v cargo &> /dev/null; then
            echo "✅ Full installation possible - all dependencies available"
            echo "🚀 Running full installer..."
            echo ""
            curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash
            return 0
        elif command -v git &> /dev/null; then
            echo "⚠️  Partial installation - missing Rust"
            echo "🦀 Installing Rust first..."
            echo ""
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            export PATH="$HOME/.cargo/bin:$PATH"
            echo "✅ Rust installed, running full installer..."
            echo ""
            curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash
            return 0
        else
            echo "⚠️  Limited installation - missing Git and Rust"
            echo "📚 Installing Git first..."
            echo ""
            if [[ "$OS" == "macos" ]]; then
                if command -v brew &> /dev/null; then
                    brew install git
                else
                    echo "❌ Cannot install Git automatically (no Homebrew)"
                    show_manual_instructions
                    return 1
                fi
            elif [[ "$OS" == "linux" ]]; then
                sudo apt-get update && sudo apt-get install -y git
            else
                echo "❌ Cannot install Git automatically for this OS"
                show_manual_instructions
                return 1
            fi
            echo "✅ Git installed, installing Rust..."
            echo ""
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            export PATH="$HOME/.cargo/bin:$PATH"
            echo "✅ Rust installed, running full installer..."
            echo ""
            curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash
            return 0
        fi
    else
        echo "❌ Node.js not available - cannot proceed with automatic installation"
        show_manual_instructions
        return 1
    fi
}

# Show manual installation instructions
show_manual_instructions() {
    echo ""
    echo "🔧 Manual Installation Required"
    echo "==============================="
    echo ""
    
    if [[ "$OS" == "macos" ]]; then
        echo "📋 For macOS, follow these steps:"
        echo ""
        echo "1️⃣  Install Homebrew (if not already installed):"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        echo "2️⃣  Install Node.js:"
        echo "   brew install node"
        echo ""
        echo "3️⃣  Install Git:"
        echo "   brew install git"
        echo ""
        echo "4️⃣  Install Rust:"
        echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo ""
        echo "5️⃣  Restart your terminal or run:"
        echo "   source ~/.cargo/env"
        echo ""
        echo "6️⃣  Run the Nova installer:"
        echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        echo ""
        
    elif [[ "$OS" == "linux" ]]; then
        echo "📋 For Linux, follow these steps:"
        echo ""
        echo "1️⃣  Install Node.js:"
        echo "   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
        echo "   sudo apt-get install -y nodejs"
        echo ""
        echo "2️⃣  Install Git:"
        echo "   sudo apt-get update"
        echo "   sudo apt-get install -y git"
        echo ""
        echo "3️⃣  Install Rust:"
        echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo ""
        echo "4️⃣  Restart your terminal or run:"
        echo "   source ~/.cargo/env"
        echo ""
        echo "5️⃣  Run the Nova installer:"
        echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        echo ""
        
    else
        echo "📋 For other operating systems:"
        echo ""
        echo "1️⃣  Install Node.js from: https://nodejs.org/"
        echo "2️⃣  Install Git from: https://git-scm.com/"
        echo "3️⃣  Install Rust from: https://rustup.rs/"
        echo "4️⃣  Run the Nova installer:"
        echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
        echo ""
    fi
    
    echo "💡 Alternative: If you have Node.js installed, try the quick installer:"
    echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova-quick.sh | bash"
    echo ""
    echo "🔗 For more help, visit: https://github.com/ceobitch/codex"
}

# Main flow
main() {
    determine_method
}

main "$@"
