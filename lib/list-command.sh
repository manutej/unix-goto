#!/bin/bash
# unix-goto - list command to show available destinations
# https://github.com/manutej/unix-goto

# Show all available destinations
__goto_list_all() {
    local show_shortcuts="${1:-true}"
    local show_folders="${2:-true}"
    local show_bookmarks="${3:-true}"

    echo "Available destinations:"
    echo ""

    # Show shortcuts
    if [ "$show_shortcuts" = "true" ]; then
        echo "  \033[1;33m⚡ Shortcuts:\033[0m"
        echo "     luxor     → $HOME/Documents/LUXOR"
        echo "     halcon    → $HOME/Documents/LUXOR/PROJECTS/HALCON"
        echo "     docs      → $HOME/ASCIIDocs"
        echo "     infra     → $HOME/ASCIIDocs/infra"
        echo ""
    fi

    # Show bookmarks
    if [ "$show_bookmarks" = "true" ] && [ -f "$GOTO_BOOKMARKS_FILE" ] && [ -s "$GOTO_BOOKMARKS_FILE" ]; then
        echo "  \033[1;36m🔖 Bookmarks:\033[0m"
        while IFS='|' read -r name path timestamp; do
            printf "     @%-10s → %s\n" "$name" "$path"
        done < "$GOTO_BOOKMARKS_FILE"
        echo ""
    fi

    # Show folders from search paths
    if [ "$show_folders" = "true" ]; then
        echo "  \033[1;32m📁 Available Folders:\033[0m"

        local search_paths=(
            "$HOME/ASCIIDocs"
            "$HOME/Documents/LUXOR"
            "$HOME/Documents/LUXOR/PROJECTS"
        )

        local folder_count=0
        for base_path in "${search_paths[@]}"; do
            if [ -d "$base_path" ]; then
                # List directories in this base path
                while IFS= read -r dir; do
                    local folder_name=$(/usr/bin/basename "$dir")
                    # Skip hidden folders and the base path itself
                    if [[ ! "$folder_name" == .* ]]; then
                        printf "     %-15s (in %s)\n" "$folder_name" "$(/usr/bin/basename "$base_path")"
                        ((folder_count++))
                    fi
                done < <(/usr/bin/find "$base_path" -maxdepth 1 -type d -not -path "$base_path" 2>/dev/null | /usr/bin/sort)
            fi
        done

        if [ $folder_count -eq 0 ]; then
            echo "     (No folders found in search paths)"
        fi
        echo ""
    fi

    echo "  \033[1;35m💡 Tips:\033[0m"
    echo "     Use 'goto <name>' to navigate"
    echo "     Use 'goto @<bookmark>' for bookmarked locations"
    echo "     Use 'goto \"natural language\"' for AI-powered search"
    echo ""
}

# Handle goto list command
__goto_list() {
    local filter="$1"

    case "$filter" in
        --shortcuts|-s)
            __goto_list_all true false false
            ;;
        --folders|-f)
            __goto_list_all false true false
            ;;
        --bookmarks|-b)
            __goto_list_all false false true
            ;;
        --help|-h)
            echo "goto list - Show available destinations"
            echo ""
            echo "Usage:"
            echo "  goto list              Show all destinations"
            echo "  goto list --shortcuts  Show only shortcuts"
            echo "  goto list --folders    Show only folders"
            echo "  goto list --bookmarks  Show only bookmarks"
            echo ""
            ;;
        "")
            __goto_list_all
            ;;
        *)
            echo "Unknown option: $filter"
            echo "Try 'goto list --help' for usage"
            return 1
            ;;
    esac
}
