#!/bin/bash
# unix-goto - History tracking for navigation
# https://github.com/manutej/unix-goto

# History file location
GOTO_HISTORY_FILE="${GOTO_HISTORY_FILE:-$HOME/.goto_history}"
GOTO_HISTORY_MAX="${GOTO_HISTORY_MAX:-100}"

# Track directory changes
__goto_track() {
    local target_dir="$1"
    local timestamp=$(/bin/date +%s)

    # Create history file if it doesn't exist
    /usr/bin/touch "$GOTO_HISTORY_FILE"

    # Add entry: timestamp|directory
    echo "$timestamp|$target_dir" >> "$GOTO_HISTORY_FILE"

    # Keep only last N entries
    if [ -f "$GOTO_HISTORY_FILE" ]; then
        /usr/bin/tail -n "$GOTO_HISTORY_MAX" "$GOTO_HISTORY_FILE" > "$GOTO_HISTORY_FILE.tmp"
        /bin/mv "$GOTO_HISTORY_FILE.tmp" "$GOTO_HISTORY_FILE"
    fi
}

# Get navigation history
__goto_get_history() {
    if [ ! -f "$GOTO_HISTORY_FILE" ]; then
        return 1
    fi

    cat "$GOTO_HISTORY_FILE"
}

# Get recent unique directories
__goto_recent_dirs() {
    local limit="${1:-10}"

    if [ ! -f "$GOTO_HISTORY_FILE" ]; then
        return 1
    fi

    # Get unique directories in reverse chronological order
    # Use tail -r for macOS (tac not available), or tac for Linux
    if command -v tac &> /dev/null; then
        tac "$GOTO_HISTORY_FILE" | /usr/bin/awk -F'|' '!seen[$2]++ {print $2}' | /usr/bin/head -n "$limit"
    else
        /usr/bin/tail -r "$GOTO_HISTORY_FILE" | /usr/bin/awk -F'|' '!seen[$2]++ {print $2}' | /usr/bin/head -n "$limit"
    fi
}
