#!/bin/bash
# unix-goto - Fuzzy matching for directory navigation
# https://github.com/manutej/unix-goto

# Simple fuzzy matching using case-insensitive substring search
# Design: Keep it simple - no complex algorithms needed for v0.4.0

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

# Fuzzy search for directories in search paths
__goto_fuzzy_search() {
    local query="$1"

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

    # Get fuzzy matches
    local -a matches=()
    while IFS= read -r match; do
        [ -n "$match" ] && matches+=("$match")
    done < <(__goto_fuzzy_match "$query" "${unique_dirs[@]}")

    # Process results
    local match_count=${#matches[@]}

    if [ "$match_count" -eq 0 ]; then
        echo "❌ No matches found for: $query"
        echo ""
        echo "💡 Try:"
        echo "  • Check spelling"
        echo "  • Use fewer characters"
        echo "  • Try 'goto list' to see available directories"
        return 1
    elif [ "$match_count" -eq 1 ]; then
        # Single match - navigate to it
        local dir="${matches[0]}"
        echo "✓ Fuzzy match: $dir"

        # Find the full path
        for base_path in "${search_paths[@]}"; do
            if [ -d "$base_path/$dir" ]; then
                goto "$dir"
                return $?
            fi
        done

        echo "❌ Error: Found match but directory not accessible"
        return 1
    else
        # Multiple matches - show options
        echo "🔍 Multiple matches found for '$query':"
        echo ""
        local i=1
        for match in "${matches[@]}"; do
            # Show first 10 matches
            [ $i -gt 10 ] && break
            echo "  $i) $match"
            ((i++))
        done

        if [ ${#matches[@]} -gt 10 ]; then
            echo "  ... and $((${#matches[@]} - 10)) more"
        fi

        echo ""
        echo "💡 Be more specific or use the full name:"
        echo "  goto ${matches[0]}"
        return 1
    fi
}

# Test function (for development)
__goto_fuzzy_test() {
    echo "Testing fuzzy matching..."
    echo ""

    # Test data
    local test_dirs=("GAI-3101" "GAI-3102" "HALCON" "WA3590" "project-one" "project-two")

    # Test 1: Exact substring
    echo "Test 1: Query 'GAI'"
    __goto_fuzzy_match "GAI" "${test_dirs[@]}"
    echo ""

    # Test 2: Case insensitive
    echo "Test 2: Query 'gai' (case insensitive)"
    __goto_fuzzy_match "gai" "${test_dirs[@]}"
    echo ""

    # Test 3: Partial match
    echo "Test 3: Query '3101'"
    __goto_fuzzy_match "3101" "${test_dirs[@]}"
    echo ""

    # Test 4: No match
    echo "Test 4: Query 'xyz' (no match)"
    __goto_fuzzy_match "xyz" "${test_dirs[@]}"
    echo ""

    # Test 5: Multiple partial matches
    echo "Test 5: Query 'proj'"
    __goto_fuzzy_match "proj" "${test_dirs[@]}"
    echo ""

    echo "Tests complete!"
}

# Uncomment to run tests:
# __goto_fuzzy_test
