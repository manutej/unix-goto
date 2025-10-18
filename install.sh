#!/bin/bash
# unix-goto installation script

set -e

INSTALL_DIR="$HOME/bin"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              UNIX-GOTO INSTALLATION                              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Create bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy scripts to ~/bin
echo "📦 Installing helper scripts to $INSTALL_DIR..."
cp "$REPO_DIR/bin/goto-resolve" "$INSTALL_DIR/goto-resolve"
cp "$REPO_DIR/bin/finddir" "$INSTALL_DIR/finddir"
cp "$REPO_DIR/bin/finddir-resolver" "$INSTALL_DIR/finddir-resolver"
cp "$REPO_DIR/bin/benchmark-goto" "$INSTALL_DIR/benchmark-goto"
chmod +x "$INSTALL_DIR/goto-resolve"
chmod +x "$INSTALL_DIR/finddir"
chmod +x "$INSTALL_DIR/finddir-resolver"
chmod +x "$INSTALL_DIR/benchmark-goto"
echo "   ✓ Helper scripts installed"
echo ""

# Detect shell
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo "⚠️  Could not detect shell type. Please manually add to your shell config."
    exit 1
fi

echo "🐚 Detected shell: $SHELL_NAME"
echo "   Config file: $SHELL_CONFIG"
echo ""

# Check if already configured
SOURCE_LINE="source \"$REPO_DIR/goto.sh\""
if grep -Fq "$SOURCE_LINE" "$SHELL_CONFIG" 2>/dev/null; then
    echo "✅ unix-goto already configured in $SHELL_CONFIG"
else
    echo "📝 Adding unix-goto to $SHELL_CONFIG..."

    # Add source line to shell config
    cat >> "$SHELL_CONFIG" << EOF

# unix-goto - Smart navigation with natural language support
# Source: https://github.com/manutej/unix-goto
source "$REPO_DIR/goto.sh"
EOF

    echo "   ✓ Configuration added"
fi

echo ""

# Verify Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "⚠️  Optional: Claude CLI not found"
    echo "   Natural language features require Claude CLI"
    echo "   Install from: https://github.com/anthropics/claude-code"
else
    echo "✅ Claude CLI detected (natural language support available)"
fi

# Check if glow is available
if ! command -v glow &> /dev/null; then
    echo "💡 Optional: Install 'glow' for pretty config display"
    echo "   brew install glow"
else
    echo "✅ glow detected (enhanced display available)"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              INSTALLATION COMPLETE                               ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Get Started:"
echo ""
echo "   # Reload your shell configuration"
echo "   source $SHELL_CONFIG"
echo ""
echo "   # Build the folder cache (recommended first step)"
echo "   goto index rebuild"
echo ""
echo "   # Try it out"
echo "   goto --help           # See all commands"
echo "   goto list             # Show available destinations"
echo "   goto index status     # Check cache statistics"
echo ""
echo "📝 Next Steps:"
echo ""
echo "   1. Customize search paths in: lib/goto-function.sh"
echo "      (Edit the 'search_paths' array around line 150)"
echo ""
echo "   2. Add bookmarks for frequently used locations:"
echo "      bookmark add myproject"
echo ""
echo "   3. Explore advanced features:"
echo "      goto benchmark        # Performance tests"
echo "      recent               # Navigation history"
echo "      back                 # Previous directory"
echo ""
echo "For more: https://github.com/manutej/unix-goto"
echo ""
