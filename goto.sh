#!/bin/bash
# unix-goto - Single file loader
# Usage: source /path/to/unix-goto/goto.sh

# Shell-agnostic path resolution (works in both bash and zsh)
if [ -n "${BASH_SOURCE[0]}" ]; then
    # Bash
    GOTO_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" 2>/dev/null && pwd)"
else
    # Zsh uses a different mechanism
    GOTO_LIB_DIR="$(cd "$(dirname "${(%):-%x}")/lib" 2>/dev/null && pwd)"
fi

# Verify lib directory exists
if [ ! -d "$GOTO_LIB_DIR" ]; then
    echo "Error: lib directory not found at expected location" >&2
    return 1 2>/dev/null || exit 1
fi

# Load all modules in correct order
source "$GOTO_LIB_DIR/history-tracking.sh"
source "$GOTO_LIB_DIR/back-command.sh"
source "$GOTO_LIB_DIR/recent-command.sh"
source "$GOTO_LIB_DIR/bookmark-command.sh"
source "$GOTO_LIB_DIR/cache-index.sh"
source "$GOTO_LIB_DIR/list-command.sh"
source "$GOTO_LIB_DIR/benchmark-command.sh"
source "$GOTO_LIB_DIR/benchmark-workspace.sh"
source "$GOTO_LIB_DIR/goto-function.sh"
