#!/bin/bash
# unix-goto - Smart project navigation with natural language support
# https://github.com/manutej/unix-goto

# Helper function to navigate and track history
__goto_navigate_to() {
    local target_dir="$1"

    # Verify target directory exists before attempting navigation
    if [ ! -d "$target_dir" ]; then
        echo "❌ Error: Directory not found: $target_dir" >&2
        return 1
    fi

    # Push current directory to stack before navigating
    if command -v __goto_stack_push &> /dev/null; then
        __goto_stack_push "$PWD"
    fi

    # Navigate with error checking
    if ! cd "$target_dir" 2>/dev/null; then
        echo "❌ Error: Failed to navigate to: $target_dir" >&2
        return 1
    fi

    # Track in history
    if command -v __goto_track &> /dev/null; then
        __goto_track "$PWD"
    fi

    echo "→ $PWD"
    return 0
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
        echo ""
        echo "Core Commands:"
        echo "  goto list [options]      List available destinations"
        echo "  goto index <cmd>         Manage folder cache index"
        echo "  goto benchmark [cmd]     Run performance benchmarks"
        echo "  goto --help              Show this help"
        echo ""
        echo "Direct Shortcuts:"
        echo "  luxor                    LUXOR root"
        echo "  halcon                   HALCON project"
        echo "  docs                     ASCIIDocs root"
        echo "  infra                    ASCIIDocs/infra"
        echo "  zshrc                    Source and display ~/.zshrc"
        echo "  bashrc                   Source and display ~/.bashrc"
        echo ""
        echo "Smart Features:"
        echo "  Cache Lookup             O(1) fast navigation (8x faster)"
        echo "  Multi-level Paths        goto GAI-3101/docs"
        echo "  Recursive Search         Finds nested folders up to 3 levels"
        echo "  Natural Language         'the halcon project' (powered by Claude)"
        echo ""
        echo "Bookmarks:"
        echo "  @work, @proj1, etc.      Quick access to saved locations"
        echo "  bookmark add <name>      Save current directory"
        echo "  bookmark list            Show all bookmarks"
        echo "  bookmark goto <name>     Navigate to bookmark"
        echo "  bookmark --help          Full bookmark management"
        echo ""
        echo "Navigation History:"
        echo "  back                     Go to previous directory"
        echo "  back <N>                 Go back N directories"
        echo "  recent                   Show recently visited folders"
        echo "  recent --goto <N>        Navigate to Nth recent folder"
        echo ""
        echo "Cache Management:"
        echo "  goto index rebuild       Build/rebuild cache index"
        echo "  goto index status        Show cache statistics"
        echo "  goto index clear         Clear cache"
        echo "  goto index --help        Full cache commands"
        echo ""
        echo "Performance:"
        echo "  goto benchmark           Run performance tests"
        echo "  goto benchmark compare   Compare cache vs search"
        echo "  goto benchmark --help    Full benchmark options"
        echo ""
        echo "Examples:"
        echo "  goto unix-goto           Find and navigate to unix-goto folder"
        echo "  goto Git_Repos/unix-goto Navigate using multi-level path"
        echo "  goto @work               Navigate to 'work' bookmark"
        echo "  goto 'the halcon folder' Natural language navigation"
        echo "  back                     Return to previous directory"
        echo "  recent --goto 3          Go to 3rd recent folder"
        echo ""
        echo "For more: https://github.com/manutej/unix-goto"
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

    # Check regular bookmarks (without @ prefix) before searching
    if command -v __goto_bookmark_get &> /dev/null; then
        local bookmark_path=$(__goto_bookmark_get "$1" 2>/dev/null)
        if [ -n "$bookmark_path" ] && [ -d "$bookmark_path" ]; then
            echo "✓ Using bookmark: $1"
            __goto_navigate_to "$bookmark_path"
            return 0
        fi
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
        index)
            if command -v __goto_index_command &> /dev/null; then
                shift
                __goto_index_command "$@"
            else
                echo "⚠️  Index/cache command not loaded"
            fi
            return
            ;;
        benchmark|bench)
            if command -v __goto_benchmark &> /dev/null; then
                shift
                __goto_benchmark "$@"
            else
                echo "⚠️  Benchmark command not loaded"
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

    # Validate single argument for directory navigation
    # (multi-word directories should use hyphens: unix-goto, not "unix goto")
    if [ $# -gt 1 ]; then
        local hyphenated_arg="${1}-${2}"

        echo "⚠️  Multiple arguments detected: '$*'"
        echo ""
        echo "For multi-word directory names, use hyphens or quotes:"
        echo "  ✓ goto unix-goto"
        echo "  ✓ goto 'unix goto'  (if directory name has spaces)"
        echo ""
        echo "Did you mean: goto $hyphenated_arg ?"
        return 1
    fi

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

    # NEW: Try cache lookup first (O(1) performance)
    if command -v __goto_cache_lookup &> /dev/null; then
        local cache_result
        cache_result=$(__goto_cache_lookup "$1" 2>/dev/null)
        local lookup_status=$?

        if [ $lookup_status -eq 0 ]; then
            # Single match found in cache
            echo "✓ Found in cache: $cache_result"
            __goto_navigate_to "$cache_result"
            return 0
        elif [ $lookup_status -eq 2 ]; then
            # Multiple matches in cache
            echo "⚠️  Multiple folders named '$1' found in cache:"
            echo ""
            local i=1
            while IFS= read -r match; do
                echo "  $i) $match"
                ((i++))
            done <<< "$cache_result"
            echo ""
            echo "Please be more specific or use the full path"
            return 1
        fi
        # If cache lookup failed (status 1), fall through to regular search
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
    echo "🔍 Searching in subdirectories (cache miss)..."

    local matches=()

    # First try exact match across all search paths
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path" ]; then
            while IFS= read -r match; do
                matches+=("$match")
            done < <(/usr/bin/find "$base_path" -maxdepth 3 -type d -name "$1" 2>/dev/null)
        fi
    done

    # If no exact matches found, try partial match (contains search term)
    if [ ${#matches[@]} -eq 0 ]; then
        echo "🔍 No exact match, trying partial match..."
        for base_path in "${search_paths[@]}"; do
            if [ -d "$base_path" ]; then
                while IFS= read -r match; do
                    matches+=("$match")
                done < <(/usr/bin/find "$base_path" -maxdepth 3 -type d -name "*$1*" 2>/dev/null)
            fi
        done
    fi

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
