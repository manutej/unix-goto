#!/bin/bash
# unix-goto - bookmark command for managing favorite locations
# https://github.com/manutej/unix-goto

# Bookmarks file location
GOTO_BOOKMARKS_FILE="${GOTO_BOOKMARKS_FILE:-$HOME/.goto_bookmarks}"

# Initialize bookmarks file
__goto_bookmarks_init() {
    if [ ! -f "$GOTO_BOOKMARKS_FILE" ]; then
        /usr/bin/touch "$GOTO_BOOKMARKS_FILE"
    fi
}

# Add a bookmark
__goto_bookmark_add() {
    local name="$1"
    local path="${2:-$PWD}"

    # Validate bookmark name
    if [ -z "$name" ]; then
        echo "❌ Error: Bookmark name required"
        return 1
    fi

    # Validate path
    if [ ! -d "$path" ]; then
        echo "❌ Error: Directory does not exist: $path"
        return 1
    fi

    # Convert to absolute path
    path=$(cd "$path" && pwd)

    __goto_bookmarks_init

    # Check if bookmark already exists
    if /usr/bin/grep -q "^$name|" "$GOTO_BOOKMARKS_FILE"; then
        echo "⚠️  Bookmark '$name' already exists"
        echo "   Remove it first with: bookmark rm $name"
        return 1
    fi

    # Add bookmark: name|path|timestamp
    echo "$name|$path|$(/bin/date +%s)" >> "$GOTO_BOOKMARKS_FILE"
    echo "✓ Bookmarked '$name' → $path"
}

# Remove a bookmark
__goto_bookmark_remove() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ Error: Bookmark name required"
        return 1
    fi

    __goto_bookmarks_init

    if ! /usr/bin/grep -q "^$name|" "$GOTO_BOOKMARKS_FILE"; then
        echo "❌ Bookmark not found: $name"
        return 1
    fi

    # Remove the bookmark
    /usr/bin/grep -v "^$name|" "$GOTO_BOOKMARKS_FILE" > "$GOTO_BOOKMARKS_FILE.tmp"
    /bin/mv "$GOTO_BOOKMARKS_FILE.tmp" "$GOTO_BOOKMARKS_FILE"
    echo "✓ Removed bookmark: $name"
}

# Get bookmark path
__goto_bookmark_get() {
    local name="$1"

    __goto_bookmarks_init

    local result=$(/usr/bin/grep "^$name|" "$GOTO_BOOKMARKS_FILE" | /usr/bin/cut -d'|' -f2)
    echo "$result"
}

# List all bookmarks
__goto_bookmark_list() {
    __goto_bookmarks_init

    if [ ! -s "$GOTO_BOOKMARKS_FILE" ]; then
        echo "No bookmarks yet."
        echo "Add one with: bookmark add <name> [path]"
        return
    fi

    echo "Saved bookmarks:"
    echo ""

    local count=0
    while IFS='|' read -r name path timestamp; do
        ((count++))
        # Format with colors
        printf "  \033[1;36m%-20s\033[0m → %s\n" "$name" "$path"
    done < "$GOTO_BOOKMARKS_FILE"

    echo ""
    echo "Total: $count bookmark$([ $count -ne 1 ] && echo 's')"
    echo ""
    echo "Usage: goto @$name  or  bookmark goto $name"
}

# Navigate to bookmark
__goto_bookmark_goto() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "❌ Error: Bookmark name required"
        return 1
    fi

    local path=$(__goto_bookmark_get "$name")

    if [ -z "$path" ]; then
        echo "❌ Bookmark not found: $name"
        echo "List bookmarks with: bookmark list"
        return 1
    fi

    if [ ! -d "$path" ]; then
        echo "⚠️  Bookmark directory no longer exists: $path"
        echo "Remove it with: bookmark rm $name"
        return 1
    fi

    # Use goto navigation helper if available
    if command -v __goto_navigate_to &> /dev/null; then
        __goto_navigate_to "$path"
    else
        cd "$path"
        echo "→ $PWD"
    fi
}

# bookmark - Manage bookmarks for favorite locations
bookmark() {
    local command="$1"
    shift

    case "$command" in
        add|a)
            __goto_bookmark_add "$@"
            ;;
        remove|rm|delete|del)
            __goto_bookmark_remove "$@"
            ;;
        list|ls|l)
            __goto_bookmark_list
            ;;
        goto|go|g)
            __goto_bookmark_goto "$@"
            ;;
        --help|-h|help|"")
            echo "bookmark - Manage bookmarks for favorite locations"
            echo ""
            echo "Usage:"
            echo "  bookmark add <name> [path]    Add bookmark (defaults to current dir)"
            echo "  bookmark rm <name>            Remove bookmark"
            echo "  bookmark list                 List all bookmarks"
            echo "  bookmark goto <name>          Navigate to bookmark"
            echo "  bookmark --help               Show this help"
            echo ""
            echo "Shortcuts:"
            echo "  goto @<name>                  Navigate using @ prefix"
            echo ""
            echo "Examples:"
            echo "  bookmark add work             # Bookmark current directory as 'work'"
            echo "  bookmark add proj1 ~/code/p1  # Bookmark specific path"
            echo "  bookmark list                 # Show all bookmarks"
            echo "  bookmark goto work            # Navigate to 'work' bookmark"
            echo "  goto @work                    # Navigate using @ syntax"
            echo "  bookmark rm work              # Remove bookmark"
            echo ""
            ;;
        *)
            echo "❌ Unknown command: $command"
            echo "Try 'bookmark --help' for usage"
            return 1
            ;;
    esac
}

# Alias for convenience
alias bm='bookmark'
