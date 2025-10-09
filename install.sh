#!/bin/bash
# unix-goto installation script

set -e

INSTALL_DIR="$HOME/bin"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Installing unix-goto..."

# Create bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy scripts to ~/bin
echo "📦 Installing scripts to $INSTALL_DIR..."
cp "$REPO_DIR/bin/goto-resolve" "$INSTALL_DIR/goto-resolve"
cp "$REPO_DIR/bin/finddir" "$INSTALL_DIR/finddir"
cp "$REPO_DIR/bin/finddir-resolver" "$INSTALL_DIR/finddir-resolver"
chmod +x "$INSTALL_DIR/goto-resolve"
chmod +x "$INSTALL_DIR/finddir"
chmod +x "$INSTALL_DIR/finddir-resolver"

# Detect shell
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo "⚠️  Could not detect shell type. Please manually add to your shell config."
    exit 1
fi

# Check if goto function already exists
if grep -q "# Quick project navigation with natural language support" "$SHELL_CONFIG" 2>/dev/null; then
    echo "✅ goto function already exists in $SHELL_CONFIG"
    echo "   Skipping shell configuration (already installed)"
else
    echo "📝 Adding unix-goto functions to $SHELL_CONFIG..."
    cat >> "$SHELL_CONFIG" << 'EOF'

# unix-goto - Smart navigation with natural language support
# Source: https://github.com/manutej/unix-goto
EOF

    # Add all library functions
    echo "# History tracking" >> "$SHELL_CONFIG"
    cat "$REPO_DIR/lib/history-tracking.sh" >> "$SHELL_CONFIG"
    echo "" >> "$SHELL_CONFIG"

    echo "# Back command" >> "$SHELL_CONFIG"
    cat "$REPO_DIR/lib/back-command.sh" >> "$SHELL_CONFIG"
    echo "" >> "$SHELL_CONFIG"

    echo "# Recent command" >> "$SHELL_CONFIG"
    cat "$REPO_DIR/lib/recent-command.sh" >> "$SHELL_CONFIG"
    echo "" >> "$SHELL_CONFIG"

    echo "# Bookmark command" >> "$SHELL_CONFIG"
    cat "$REPO_DIR/lib/bookmark-command.sh" >> "$SHELL_CONFIG"
    echo "" >> "$SHELL_CONFIG"

    echo "# List command" >> "$SHELL_CONFIG"
    cat "$REPO_DIR/lib/list-command.sh" >> "$SHELL_CONFIG"
    echo "" >> "$SHELL_CONFIG"

    echo "# Main goto function" >> "$SHELL_CONFIG"
    cat "$REPO_DIR/lib/goto-function.sh" >> "$SHELL_CONFIG"
fi

# Verify Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo ""
    echo "⚠️  Warning: Claude CLI not found!"
    echo "   Natural language features require Claude CLI."
    echo "   Install from: https://github.com/anthropics/claude-code"
else
    echo "✅ Claude CLI detected"
fi

# Check if glow is available
if ! command -v glow &> /dev/null; then
    echo ""
    echo "💡 Optional: Install 'glow' for pretty .zshrc display"
    echo "   brew install glow"
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Reload your shell: source $SHELL_CONFIG"
echo "  2. Try it out: goto --help"
echo "  3. Navigate: goto luxor"
echo ""
echo "Customize search paths in: $SHELL_CONFIG (search for 'search_paths')"
