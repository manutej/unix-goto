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

    # If exact match not found, try fuzzy matching
    if [ -z "$path" ] && command -v __goto_fuzzy_match &> /dev/null; then
        __goto_bookmarks_init

        # Get all bookmark names
        local -a all_bookmarks=()
        while IFS='|' read -r bookmark_name bookmark_path _; do
            [ -n "$bookmark_name" ] && all_bookmarks+=("$bookmark_name")
        done < "$GOTO_BOOKMARKS_FILE"

        # Fuzzy match the bookmark name
        local -a matches=()
        while IFS= read -r match; do
            [ -n "$match" ] && matches+=("$match")
        done < <(__goto_fuzzy_match "$name" "${all_bookmarks[@]}")

        if [ ${#matches[@]} -eq 1 ]; then
            # Single fuzzy match found
            local matched_name="${matches[0]}"
            echo "✓ Fuzzy match: @$name → @$matched_name"
            path=$(__goto_bookmark_get "$matched_name")
        elif [ ${#matches[@]} -gt 1 ]; then
            echo "❌ Multiple bookmark matches for '@$name':"
            for match in "${matches[@]:0:5}"; do
                echo "  @$match"
            done
            [ ${#matches[@]} -gt 5 ] && echo "  ... and $((${#matches[@]} - 5)) more"
            echo "Be more specific"
            return 1
        fi
    fi

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
        cd "$path" || return 1
        echo "→ $PWD"
    fi
}

# Sync bookmarks from configuration file
__goto_bookmark_sync() {
    local config_file="${HOME}/.goto_config"
    local repo_config=".goto_config.example"

    # Check if user config exists
    if [ ! -f "$config_file" ]; then
        if [ -f "$repo_config" ]; then
            echo "📋 No configuration found at: $config_file"
            echo "   Copy the example config to get started:"
            echo "   cp .goto_config.example ~/.goto_config"
            echo "   vim ~/.goto_config  # Add your workspace paths"
            return 1
        else
            echo "❌ No configuration file found"
            return 1
        fi
    fi

    __goto_bookmarks_init

    echo "🔄 Syncing bookmarks from config..."
    echo ""

    # Read workspace paths from config
    local -a workspace_paths=()
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Expand tilde and environment variables
        line=$(eval echo "$line")

        # Validate path exists
        if [ -d "$line" ]; then
            workspace_paths+=("$line")
        else
            echo "⚠️  Skipping non-existent path: $line"
        fi
    done < "$config_file"

    if [ ${#workspace_paths[@]} -eq 0 ]; then
        echo "❌ No valid workspace paths found in config"
        echo "   Edit ~/.goto_config and add your workspace directories"
        return 1
    fi

    echo "Found ${#workspace_paths[@]} workspace path(s):"
    for path in "${workspace_paths[@]}"; do
        echo "  • $path"
    done
    echo ""

    # Track sync-generated bookmarks
    local -a new_bookmarks=()
    local added_count=0
    local updated_count=0
    local skipped_count=0

    # Scan each workspace path
    for workspace_path in "${workspace_paths[@]}"; do
        echo "Scanning: $workspace_path"

        # Add bookmark for the workspace itself
        local workspace_name=$(basename "$workspace_path" | tr '[:upper:]' '[:lower:]')
        local workspace_full_path=$(cd "$workspace_path" && pwd)

        # Check if bookmark exists
        if /usr/bin/grep -q "^${workspace_name}|" "$GOTO_BOOKMARKS_FILE"; then
            # Update if path changed
            local existing_path=$(__goto_bookmark_get "$workspace_name")
            if [ "$existing_path" != "$workspace_full_path" ]; then
                /usr/bin/grep -v "^${workspace_name}|" "$GOTO_BOOKMARKS_FILE" > "$GOTO_BOOKMARKS_FILE.tmp"
                /bin/mv "$GOTO_BOOKMARKS_FILE.tmp" "$GOTO_BOOKMARKS_FILE"
                echo "${workspace_name}|${workspace_full_path}|$(/bin/date +%s)|sync" >> "$GOTO_BOOKMARKS_FILE"
                echo "  ↻ Updated: $workspace_name → $workspace_full_path"
                ((updated_count++))
            else
                ((skipped_count++))
            fi
        else
            echo "${workspace_name}|${workspace_full_path}|$(/bin/date +%s)|sync" >> "$GOTO_BOOKMARKS_FILE"
            echo "  ✓ Added: $workspace_name → $workspace_full_path"
            ((added_count++))
        fi
        new_bookmarks+=("$workspace_name")

        # Scan subdirectories (one level deep)
        while IFS= read -r subdir; do
            local subdir_name=$(basename "$subdir" | tr '[:upper:]' '[:lower:]')
            local subdir_full_path=$(cd "$subdir" && pwd)

            # Skip hidden directories
            [[ "$subdir_name" == .* ]] && continue

            # Check if bookmark exists
            if /usr/bin/grep -q "^${subdir_name}|" "$GOTO_BOOKMARKS_FILE"; then
                # Update if path changed
                local existing_path=$(__goto_bookmark_get "$subdir_name")
                if [ "$existing_path" != "$subdir_full_path" ]; then
                    /usr/bin/grep -v "^${subdir_name}|" "$GOTO_BOOKMARKS_FILE" > "$GOTO_BOOKMARKS_FILE.tmp"
                    /bin/mv "$GOTO_BOOKMARKS_FILE.tmp" "$GOTO_BOOKMARKS_FILE"
                    echo "${subdir_name}|${subdir_full_path}|$(/bin/date +%s)|sync" >> "$GOTO_BOOKMARKS_FILE"
                    echo "  ↻ Updated: $subdir_name → $subdir_full_path"
                    ((updated_count++))
                else
                    ((skipped_count++))
                fi
            else
                echo "${subdir_name}|${subdir_full_path}|$(/bin/date +%s)|sync" >> "$GOTO_BOOKMARKS_FILE"
                echo "  ✓ Added: $subdir_name → $subdir_full_path"
                ((added_count++))
            fi
            new_bookmarks+=("$subdir_name")
        done < <(find "$workspace_path" -maxdepth 1 -type d -not -path "$workspace_path" 2>/dev/null)
    done

    echo ""
    echo "=== Sync Summary ==="
    echo "Added:   $added_count bookmarks"
    echo "Updated: $updated_count bookmarks"
    echo "Skipped: $skipped_count bookmarks (unchanged)"
    echo ""
    echo "✓ Sync complete! Use 'bookmark list' to see all bookmarks"
    echo "  Or try: goto @${new_bookmarks[0]}"
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
        sync|s)
            __goto_bookmark_sync
            ;;
        --help|-h|help|"")
            echo "bookmark - Manage bookmarks for favorite locations"
            echo ""
            echo "Usage:"
            echo "  bookmark add <name> [path]    Add bookmark (defaults to current dir)"
            echo "  bookmark rm <name>            Remove bookmark"
            echo "  bookmark list                 List all bookmarks"
            echo "  bookmark goto <name>          Navigate to bookmark"
            echo "  bookmark sync                 Auto-generate bookmarks from ~/.goto_config"
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
            echo "Configuration-based bookmarks:"
            echo "  cp .goto_config.example ~/.goto_config  # Create config"
            echo "  vim ~/.goto_config                      # Add workspace paths"
            echo "  bookmark sync                           # Auto-generate bookmarks"
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
