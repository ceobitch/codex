#!/bin/bash

# Nova Shield - Uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/uninstall-nova.sh | bash

echo "🛡️ Uninstalling Nova Shield..."
echo "=============================="

# Kill any running Nova processes
echo "🔄 Stopping Nova Shield processes..."
pkill -f 'nova|codex' 2>/dev/null || true

# Uninstall npm package
echo "📦 Uninstalling npm package..."
npm uninstall -g nova-shield 2>/dev/null || true

# Remove installation directory
echo "🗑️  Removing Nova Shield files..."
if [ -d "$HOME/.nova-shield" ]; then
    rm -rf "$HOME/.nova-shield"
    echo "✅ Nova Shield files removed"
else
    echo "❌ Nova Shield not found"
fi

echo ""
echo "🎉 Nova Shield uninstalled successfully!"
echo ""
echo "💡 To reinstall, run:"
echo "   curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash"
