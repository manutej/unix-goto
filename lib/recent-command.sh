#!/bin/bash
# unix-goto - recent command for showing recently visited folders
# https://github.com/manutej/unix-goto

# Source history tracking functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/history-tracking.sh" 2>/dev/null || true

# recent - Show recently visited folders
recent() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "recent - Show recently visited folders"
        echo ""
        echo "Usage:"
        echo "  recent              List 10 most recent folders"
        echo "  recent <N>          List N most recent folders"
        echo "  recent --goto <N>   Navigate to Nth recent folder"
        echo "  recent --clear      Clear recent history"
        echo "  recent --help       Show this help"
        echo ""
        echo "Examples:"
        echo "  recent              # Show recent folders"
        echo "  recent 20           # Show 20 recent folders"
        echo "  recent --goto 3     # Go to 3rd recent folder"
        echo ""
        return
    fi

    if [ "$1" = "--clear" ]; then
        rm -f "$GOTO_HISTORY_FILE"
        echo "✓ Recent history cleared"
        return
    fi

    if [ "$1" = "--goto" ] || [ "$1" = "-g" ]; then
        local index="${2:-1}"

        if ! [[ "$index" =~ ^[0-9]+$ ]]; then
            echo "Error: Index must be a number"
            return 1
        fi

        local target_dir=$(__goto_recent_dirs 50 | sed -n "${index}p")

        if [ -z "$target_dir" ]; then
            echo "⚠️  No folder at index $index"
            return 1
        fi

        if [ -d "$target_dir" ]; then
            cd "$target_dir"
            echo "→ $PWD"
        else
            echo "⚠️  Directory no longer exists: $target_dir"
            return 1
        fi

        return
    fi

    # Show recent folders
    local limit="${1:-10}"

    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
        echo "Error: Argument must be a number"
        recent --help
        return 1
    fi

    if [ ! -f "$GOTO_HISTORY_FILE" ]; then
        echo "No recent history yet."
        echo "Use 'goto' to navigate and build your history."
        return
    fi

    echo "Recently visited folders:"
    echo ""

    local index=1
    __goto_recent_dirs "$limit" | while IFS= read -r dir; do
        if [ "$dir" = "$PWD" ]; then
            printf "  \033[1;32m%2d.\033[0m %s (current)\n" "$index" "$dir"
        else
            printf "  %2d. %s\n" "$index" "$dir"
        fi
        ((index++))
    done

    echo ""
    echo "Tip: Use 'recent --goto <N>' to navigate to a folder"
}
