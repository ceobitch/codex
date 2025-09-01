#!/bin/bash

# Nova Shield - macOS Clickable Installer
# Users can double-click this file to install Nova Shield

echo "🛡️ Nova Shield - macOS Installer"
echo "================================"
echo ""

# Change to user's home directory
cd ~

# Download and run the installer
echo "📥 Downloading Nova Shield installer..."
curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh | bash

echo ""
echo "✅ Installation complete!"
echo ""
echo "Press any key to close this window..."
read -n 1
