#!/bin/bash
# unix-goto - Fuzzy matching for directory navigation
# https://github.com/manutej/unix-goto

# Simple fuzzy matching using case-insensitive substring search
# Design: Keep it simple - no complex algorithms needed for v0.4.0

# Cache configuration
FUZZY_CACHE_FILE="${HOME}/.goto_fuzzy_cache"
FUZZY_CACHE_TTL=300  # 5 minutes in seconds

# Fuzzy match directories
__goto_fuzzy_match() {
    local query="$1"
    shift
    local -a candidates=("$@")
    local -a matches=()

    # Convert query to lowercase for case-insensitive matching
    local query_lower="${query,,}"

    # Find all directories that contain the query (case-insensitive)
    for candidate in "${candidates[@]}"; do
        local candidate_lower="${candidate,,}"

        # Substring match
        if [[ "$candidate_lower" == *"$query_lower"* ]]; then
            matches+=("$candidate")
        fi
    done

    # Return matches
    printf '%s\n' "${matches[@]}"
}

# Build directory cache
__goto_fuzzy_build_cache() {
    # Define search paths (same as main goto function)
    local search_paths=(
        "$HOME/ASCIIDocs"
        "$HOME/Documents/LUXOR"
        "$HOME/Documents/LUXOR/PROJECTS"
    )

    # Gather all directories
    local -a all_dirs=()
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path" ]; then
            while IFS= read -r dir; do
                local dir_name=$(basename "$dir")
                # Skip hidden directories
                [[ "$dir_name" == .* ]] && continue
                all_dirs+=("$dir_name")
            done < <(find "$base_path" -maxdepth 1 -type d -not -path "$base_path" 2>/dev/null)
        fi
    done

    # Remove duplicates
    local -a unique_dirs=()
    local -A seen
    for dir in "${all_dirs[@]}"; do
        if [[ ! ${seen[$dir]} ]]; then
            seen[$dir]=1
            unique_dirs+=("$dir")
        fi
    done

    # Write to cache with timestamp
    {
        printf '%s\n' "$(date +%s)"
        printf '%s\n' "${unique_dirs[@]}"
    } > "$FUZZY_CACHE_FILE"
}

# Get directories from cache or rebuild if stale
__goto_fuzzy_get_dirs() {
    local -a cached_dirs=()

    # Check if cache exists and is fresh
    if [ -f "$FUZZY_CACHE_FILE" ]; then
        local cache_time=$(head -n 1 "$FUZZY_CACHE_FILE" 2>/dev/null)
        local current_time=$(date +%s)

        # Check if cache is still valid
        if [ -n "$cache_time" ] && [ $((current_time - cache_time)) -lt "$FUZZY_CACHE_TTL" ]; then
            # Cache is fresh, read it
            while IFS= read -r dir; do
                [ -n "$dir" ] && cached_dirs+=("$dir")
            done < <(tail -n +2 "$FUZZY_CACHE_FILE")

            printf '%s\n' "${cached_dirs[@]}"
            return 0
        fi
    fi

    # Cache is stale or missing, rebuild it
    __goto_fuzzy_build_cache

    # Read the fresh cache
    while IFS= read -r dir; do
        [ -n "$dir" ] && cached_dirs+=("$dir")
    done < <(tail -n +2 "$FUZZY_CACHE_FILE")

    printf '%s\n' "${cached_dirs[@]}"
}

# Fuzzy search for directories in search paths
__goto_fuzzy_search() {
    local query="$1"

    # Get directories from cache (fast!)
    local -a unique_dirs=()
    while IFS= read -r dir; do
        [ -n "$dir" ] && unique_dirs+=("$dir")
    done < <(__goto_fuzzy_get_dirs)

    # Get fuzzy matches
    local -a matches=()
    while IFS= read -r match; do
        [ -n "$match" ] && matches+=("$match")
    done < <(__goto_fuzzy_match "$query" "${unique_dirs[@]}")

    # Process results
    local match_count=${#matches[@]}

    if [ "$match_count" -eq 0 ]; then
        echo "❌ No matches for '$query'. Try 'goto list' to see available directories."
        return 1
    elif [ "$match_count" -eq 1 ]; then
        # Single match - navigate to it
        local dir="${matches[0]}"
        echo "✓ Fuzzy match: $dir"

        # Let goto handle the navigation
        goto "$dir"
        return $?
    else
        # Multiple matches - show top 5
        echo "🔍 ${#matches[@]} matches for '$query':"
        for i in "${!matches[@]}"; do
            [ $i -ge 5 ] && break
            echo "  ${matches[$i]}"
        done
        [ ${#matches[@]} -gt 5 ] && echo "  ... and $((${#matches[@]} - 5)) more"
        echo "Be more specific or use full name: goto ${matches[0]}"
        return 1
    fi
}
