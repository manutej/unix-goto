#!/bin/bash
# unix-goto - back command for navigation history
# https://github.com/manutej/unix-goto

# Directory navigation stack
GOTO_STACK_FILE="${GOTO_STACK_FILE:-$HOME/.goto_stack}"

# Initialize or load the directory stack
__goto_stack_init() {
    if [ ! -f "$GOTO_STACK_FILE" ]; then
        echo "$PWD" > "$GOTO_STACK_FILE"
    fi
}

# Push current directory to stack
__goto_stack_push() {
    local dir="$1"
    __goto_stack_init
    echo "$dir" >> "$GOTO_STACK_FILE"

    # Keep stack size reasonable (max 50 entries)
    /usr/bin/tail -n 50 "$GOTO_STACK_FILE" > "$GOTO_STACK_FILE.tmp"
    /bin/mv "$GOTO_STACK_FILE.tmp" "$GOTO_STACK_FILE"
}

# Pop from stack and navigate
__goto_stack_pop() {
    __goto_stack_init

    local stack_size=$(/usr/bin/wc -l < "$GOTO_STACK_FILE")

    if [ "$stack_size" -le 1 ]; then
        echo "⚠️  Already at the first directory"
        return 1
    fi

    # Remove last line and get the previous directory
    local prev_dir=$(/usr/bin/tail -n 2 "$GOTO_STACK_FILE" | /usr/bin/head -n 1)

    # Remove last line from stack (use sed for macOS compatibility)
    /usr/bin/sed -i.bak '$d' "$GOTO_STACK_FILE"
    /bin/rm -f "$GOTO_STACK_FILE.bak"

    if [ -d "$prev_dir" ]; then
        cd "$prev_dir"
        echo "← $PWD"
    else
        echo "⚠️  Directory no longer exists: $prev_dir"
        __goto_stack_pop  # Try the next one
    fi
}

# Show navigation stack
__goto_stack_list() {
    __goto_stack_init

    echo "Navigation history (most recent last):"
    echo ""

    local index=0
    while IFS= read -r dir; do
        if [ "$dir" = "$PWD" ]; then
            echo "  [$index] → $dir (current)"
        else
            echo "  [$index]   $dir"
        fi
        ((index++))
    done < "$GOTO_STACK_FILE"
}

# back - Navigate backward through directory history
back() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "back - Navigate backward through directory history"
        echo ""
        echo "Usage:"
        echo "  back           Go to previous directory"
        echo "  back <N>       Go back N directories"
        echo "  back --list    Show navigation history"
        echo "  back --clear   Clear navigation history"
        echo "  back --help    Show this help"
        echo ""
        return
    fi

    if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
        __goto_stack_list
        return
    fi

    if [ "$1" = "--clear" ]; then
        rm -f "$GOTO_STACK_FILE"
        echo "✓ Navigation history cleared"
        return
    fi

    # Default: go back once
    local steps="${1:-1}"

    # Validate numeric input
    if ! [[ "$steps" =~ ^[0-9]+$ ]]; then
        echo "Error: Argument must be a number"
        back --help
        return 1
    fi

    # Go back N steps
    for ((i=0; i<steps; i++)); do
        __goto_stack_pop || break
    done
}
