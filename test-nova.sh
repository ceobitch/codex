#!/bin/bash
cd "$(dirname "$0")/codex-rs"

# Set terminal to be more compatible
export TERM=xterm-256color
export COLORTERM=truecolor

# Try to run Nova with explicit terminal settings
echo "Testing Nova with explicit terminal settings..."
RUST_LOG=info cargo run -p codex-tui "hi" 2>&1
