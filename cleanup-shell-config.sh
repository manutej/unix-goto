#!/bin/bash
# Cleanup script to migrate from embedded unix-goto code to source method
# This removes the old embedded code from ~/.zshrc/.bashrc and replaces with source line

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect shell config
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo "❌ No .zshrc or .bashrc found"
    exit 1
fi

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║         UNIX-GOTO SHELL CONFIG CLEANUP                           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "This script will:"
echo "  1. Backup your current $SHELL_CONFIG"
echo "  2. Remove old embedded unix-goto code"
echo "  3. Add modern source line instead"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Create backup
BACKUP_FILE="${SHELL_CONFIG}.backup-$(date +%Y%m%d-%H%M%S)"
echo "📦 Creating backup: $BACKUP_FILE"
cp "$SHELL_CONFIG" "$BACKUP_FILE"

# Remove old unix-goto sections
echo "🧹 Removing old embedded unix-goto code..."

# Create temp file
TEMP_FILE="${SHELL_CONFIG}.tmp"

# Use awk to remove unix-goto sections
awk '
BEGIN { skip = 0 }

# Start of unix-goto section markers
/^# unix-goto - / {
    skip = 1
    next
}

# RAG extension markers
/^# goto RAG/ {
    skip = 1
    next
}

# Function definitions that are part of unix-goto
/^__goto_/ {
    if (skip == 1) next
}

# End of function
/^}$/ {
    if (skip == 1) {
        skip = 0
        next
    }
}

# Source lines for unix-goto
/source.*unix-goto/ {
    skip = 1
    next
}

/source.*rag-/ {
    skip = 1
    next
}

# GOTO_ variable assignments
/^GOTO_/ {
    if (skip == 1) next
}

# Print lines that are not being skipped
{
    if (skip == 0) print
}
' "$SHELL_CONFIG" > "$TEMP_FILE"

# Move temp file to original
mv "$TEMP_FILE" "$SHELL_CONFIG"

# Add new source line
echo ""
echo "✨ Adding modern source line..."
cat >> "$SHELL_CONFIG" << EOF

# unix-goto - Smart navigation with natural language support
# Source: https://github.com/manutej/unix-goto
source "$REPO_DIR/goto.sh"
EOF

echo "   ✓ Configuration updated"
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                 CLEANUP COMPLETE                                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 What changed:"
echo "   - Backup saved: $BACKUP_FILE"
echo "   - Removed: Old embedded unix-goto code (~700 lines)"
echo "   - Added: Modern source line (3 lines)"
echo ""
echo "🚀 Next steps:"
echo "   1. Reload your shell:"
echo "      source $SHELL_CONFIG"
echo ""
echo "   2. Build cache:"
echo "      goto index rebuild"
echo ""
echo "   3. Test:"
echo "      goto --help"
echo ""
echo "💡 If something went wrong, restore from backup:"
echo "   cp $BACKUP_FILE $SHELL_CONFIG"
echo "   source $SHELL_CONFIG"
echo ""
