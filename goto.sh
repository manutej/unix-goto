#!/bin/bash
# unix-goto - Single file loader
# Usage: source /path/to/unix-goto/goto.sh

GOTO_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"

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
