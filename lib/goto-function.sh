#!/bin/bash
# unix-goto - Smart project navigation with natural language support
# https://github.com/manutej/unix-goto

# Helper function to navigate and track history
__goto_navigate_to() {
    local target_dir="$1"

    # Push current directory to stack before navigating
    if command -v __goto_stack_push &> /dev/null; then
        __goto_stack_push "$PWD"
    fi

    # Navigate
    cd "$target_dir"

    # Track in history
    if command -v __goto_track &> /dev/null; then
        __goto_track "$PWD"
    fi

    echo "→ $PWD"
}

# Quick project navigation with natural language support
goto() {
    # Handle --help flag
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "goto - Smart project navigation with natural language support"
        echo ""
        echo "Usage:"
        echo "  goto <project>           Navigate to project folder"
        echo "  goto <path/to/folder>    Navigate to nested folder (multi-level)"
        echo "  goto <unique-name>       Find and navigate to uniquely named folder"
        echo "  goto @<bookmark>         Navigate to bookmarked location"
        echo "  goto ~                   Return to home directory"
        echo "  goto zshrc               Source and display .zshrc"
        echo "  goto list                List all available destinations"
        echo "  goto --help              Show this help"
        echo ""
        echo "Direct shortcuts:"
        echo "  luxor                    LUXOR root"
        echo "  halcon                   HALCON project"
        echo "  docs                     ASCIIDocs root"
        echo "  infra                    ASCIIDocs/infra"
        echo ""
        echo "Folder names:"
        echo "  GAI-3101, WA3590, etc.   Any subfolder in search paths"
        echo ""
        echo "Multi-level navigation:"
        echo "  GAI-3101/docs            Navigate to nested folders"
        echo "  LUXOR/Git_Repos/unix-goto  Full path navigation"
        echo ""
        echo "Smart search (recursively finds unique folders):"
        echo "  unix-goto                Finds LUXOR/Git_Repos/unix-goto"
        echo "  If multiple matches, shows options"
        echo ""
        echo "Bookmarks:"
        echo "  @work, @proj1, etc.      Saved bookmark locations"
        echo "  Use 'bookmark --help' for bookmark management"
        echo ""
        echo "Natural language (powered by Claude):"
        echo "  'the halcon project'"
        echo "  'infrastructure folder'"
        echo "  'that GAI project from March'"
        echo ""
        return
    fi

    # Handle empty input
    if [ -z "$1" ]; then
        goto --help
        return
    fi

    # Handle bookmark syntax (@name)
    if [[ "$1" == @* ]]; then
        local bookmark_name="${1#@}"
        if command -v __goto_bookmark_goto &> /dev/null; then
            __goto_bookmark_goto "$bookmark_name"
        else
            echo "⚠️  Bookmark system not loaded"
        fi
        return
    fi

    # Handle special cases
    case "$1" in
        list)
            if command -v __goto_list &> /dev/null; then
                __goto_list "$2"
            else
                echo "⚠️  List command not loaded"
            fi
            return
            ;;
        "~")
            cd "$HOME"
            echo "→ $HOME"
            return
            ;;
        zshrc)
            echo "Sourcing ~/.zshrc..."
            source "$HOME/.zshrc"
            echo ""
            echo "Current .zshrc contents:"
            glow "$HOME/.zshrc" 2>/dev/null || cat "$HOME/.zshrc"
            return
            ;;
        bashrc)
            echo "Sourcing ~/.bashrc..."
            source "$HOME/.bashrc"
            echo ""
            echo "Current .bashrc contents:"
            glow "$HOME/.bashrc" 2>/dev/null || cat "$HOME/.bashrc"
            return
            ;;
        luxor)
            __goto_navigate_to "$HOME/Documents/LUXOR"
            return
            ;;
        halcon)
            __goto_navigate_to "$HOME/Documents/LUXOR/PROJECTS/HALCON"
            return
            ;;
        docs)
            __goto_navigate_to "$HOME/ASCIIDocs"
            return
            ;;
        infra)
            __goto_navigate_to "$HOME/ASCIIDocs/infra"
            return
            ;;
    esac

    # Search paths for direct folder matching
    # Customize these paths for your environment
    local search_paths=(
        "$HOME/ASCIIDocs"
        "$HOME/Documents/LUXOR"
        "$HOME/Documents/LUXOR/PROJECTS"
    )

    # Check if input contains path separators (multi-level navigation)
    if [[ "$1" == */* ]]; then
        # Multi-level path: goto project/subfolder/deep
        local base_segment="${1%%/*}"
        local rest_path="${1#*/}"

        # Search for base segment in search paths
        for base_path in "${search_paths[@]}"; do
            if [ -d "$base_path/$base_segment" ]; then
                local full_path="$base_path/$base_segment/$rest_path"
                if [ -d "$full_path" ]; then
                    __goto_navigate_to "$full_path"
                    return 0
                else
                    echo "❌ Path not found: $full_path"
                    echo "Base folder '$base_segment' found, but '$rest_path' doesn't exist within it"
                    return 1
                fi
            fi
        done

        # Base segment not found
        echo "❌ Base folder not found: $base_segment"
        echo "Try 'goto list --folders' to see available folders"
        return 1
    fi

    # Try direct folder match at root level first
    local target_dir
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path/$1" ]; then
            target_dir="$base_path/$1"
            __goto_navigate_to "$target_dir"
            return 0
        fi
    done

    # If not found at root level, search recursively for unique folder names
    # This allows: goto unix-goto (finds LUXOR/Git_Repos/unix-goto)
    echo "🔍 Searching in subdirectories..."

    local matches=()
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path" ]; then
            # Find all directories matching the name (max depth 3 for performance)
            while IFS= read -r match; do
                matches+=("$match")
            done < <(/usr/bin/find "$base_path" -maxdepth 3 -type d -name "$1" 2>/dev/null)
        fi
    done

    # Check results
    if [ ${#matches[@]} -eq 0 ]; then
        # No matches found anywhere
        echo "❌ Project not found: $1"
        echo "Try 'goto list --folders' to see available folders"
        return 1
    elif [ ${#matches[@]} -eq 1 ]; then
        # Exactly one match - navigate to it
        echo "✓ Found: ${matches[0]}"
        __goto_navigate_to "${matches[0]}"
        return 0
    else
        # Multiple matches - show options
        echo "⚠️  Multiple folders named '$1' found:"
        echo ""
        local i=1
        for match in "${matches[@]}"; do
            echo "  $i) $match"
            ((i++))
        done
        echo ""
        echo "Please be more specific or use the full path:"
        echo "  Example: goto Git_Repos/$1"
        return 1
    fi

    # If no direct match and input contains spaces or looks like natural language, use Claude AI
    if [[ "$*" == *" "* ]] || [[ ${#1} -gt 20 ]]; then
        echo "🤖 Using natural language processing..."

        # Try to find goto-resolve in PATH or in the installed location
        local resolver
        if command -v goto-resolve &> /dev/null; then
            resolver="goto-resolve"
        elif [ -f "$HOME/bin/goto-resolve" ]; then
            resolver="$HOME/bin/goto-resolve"
        else
            echo "⚠️  goto-resolve not found. Install unix-goto properly or add to PATH."
            return 1
        fi

        local resolved_folder=$($resolver "$*" 2>/dev/null)

        if [ -n "$resolved_folder" ] && [ "$resolved_folder" != "" ]; then
            # Try the resolved folder name
            goto "$resolved_folder"
            return
        fi
    fi

    # Not found
    echo "❌ Project not found: $*"
    echo "Try 'goto --help' for usage examples"
}
