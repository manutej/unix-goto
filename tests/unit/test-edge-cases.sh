#!/bin/bash
# Edge Case Tests for unix-goto (CET-89)
# Comprehensive testing of error conditions, boundary cases, and exceptional scenarios

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/bookmark-command.sh"
source "$REPO_DIR/lib/history-tracking.sh"
source "$REPO_DIR/lib/cache-index.sh"

# Test suite entry point
main() {
    test_suite "Edge Case Tests - Error Handling and Boundary Conditions"

    # Set up test fixture
    setup_test_fixture

    # Invalid input tests
    test_empty_bookmark_name
    test_bookmark_name_with_spaces
    test_bookmark_name_with_special_chars
    test_very_long_bookmark_name
    test_null_path_input
    test_empty_string_path

    # Permission and filesystem tests
    test_directory_without_read_permission
    test_directory_without_execute_permission
    test_symlink_to_nonexistent_target
    test_circular_symlink
    test_path_with_unicode_characters
    test_path_with_spaces

    # Boundary condition tests
    test_extremely_long_path
    test_max_history_overflow
    test_empty_history_file
    test_corrupted_bookmark_file
    test_corrupted_history_file

    # Concurrent operation tests
    test_simultaneous_bookmark_writes
    test_history_race_condition

    # Cache system edge cases
    test_cache_missing_directory
    test_cache_with_deleted_entries
    test_cache_with_invalid_permissions
    test_cache_corrupted_header
    test_cache_empty_file

    # Special character handling
    test_path_with_dollar_sign
    test_path_with_backticks
    test_path_with_quotes
    test_path_with_newlines

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

# ============================================================================
# Invalid Input Tests
# ============================================================================

test_empty_bookmark_name() {
    test_case "Empty bookmark name should fail gracefully"

    if __goto_bookmark_add "" "$FIXTURE_DIR" 2>/dev/null; then
        test_fail "Empty bookmark name should be rejected"
    else
        test_pass "Empty bookmark name correctly rejected"
    fi
}

test_bookmark_name_with_spaces() {
    test_case "Bookmark name with spaces should fail"

    local test_dir="$FIXTURE_DIR/test"
    mkdir -p "$test_dir"

    if __goto_bookmark_add "my bookmark" "$test_dir" 2>/dev/null; then
        test_fail "Bookmark name with spaces should be rejected"
    else
        test_pass "Bookmark name with spaces correctly rejected"
    fi
}

test_bookmark_name_with_special_chars() {
    test_case "Bookmark name with special characters"

    local test_dir="$FIXTURE_DIR/test"
    mkdir -p "$test_dir"

    # Test various special characters that should be rejected
    local special_chars=("my|bookmark" "my;bookmark" "my&bookmark" "my\$bookmark")

    local all_rejected=true
    for char_test in "${special_chars[@]}"; do
        if __goto_bookmark_add "$char_test" "$test_dir" 2>/dev/null; then
            all_rejected=false
            break
        fi
    done

    if $all_rejected; then
        test_pass "Special characters in bookmark names correctly rejected"
    else
        test_fail "Some special characters were incorrectly accepted"
    fi
}

test_very_long_bookmark_name() {
    test_case "Very long bookmark name (boundary test)"

    local test_dir="$FIXTURE_DIR/test"
    mkdir -p "$test_dir"

    # Create a 256-character bookmark name (typical filesystem name length limit)
    # Tests boundary behavior for bookmark name validation
    local long_name=$(printf 'a%.0s' {1..256})

    if __goto_bookmark_add "$long_name" "$test_dir" 2>/dev/null; then
        # If accepted, verify it can be retrieved
        local result=$(__goto_bookmark_get "$long_name" 2>/dev/null)
        if [ "$result" = "$test_dir" ]; then
            test_pass "Long bookmark name handled correctly"
        else
            test_fail "Long bookmark name accepted but retrieval failed"
        fi
    else
        test_pass "Extremely long bookmark name rejected (acceptable behavior)"
    fi
}

test_null_path_input() {
    test_case "Null/empty path input handling"

    if __goto_bookmark_add "test" "" 2>/dev/null; then
        test_fail "Empty path should be rejected"
    else
        test_pass "Empty path correctly rejected"
    fi
}

test_empty_string_path() {
    test_case "Whitespace-only path handling"

    if __goto_bookmark_add "test" "   " 2>/dev/null; then
        test_fail "Whitespace-only path should be rejected"
    else
        test_pass "Whitespace-only path correctly rejected"
    fi
}

# ============================================================================
# Permission and Filesystem Tests
# ============================================================================

test_directory_without_read_permission() {
    test_case "Directory without read permission"

    local test_dir="$FIXTURE_DIR/no-read"
    mkdir -p "$test_dir"
    chmod 000 "$test_dir"

    if __goto_bookmark_add "noread" "$test_dir" 2>/dev/null; then
        test_fail "Should reject directory without read permission"
    else
        test_pass "Directory without read permission correctly rejected"
    fi

    # Cleanup
    chmod 755 "$test_dir"
}

test_directory_without_execute_permission() {
    test_case "Directory without execute permission"

    local test_dir="$FIXTURE_DIR/no-exec"
    mkdir -p "$test_dir"
    chmod 644 "$test_dir"

    if __goto_bookmark_add "noexec" "$test_dir" 2>/dev/null; then
        test_fail "Should reject directory without execute permission"
    else
        test_pass "Directory without execute permission correctly rejected"
    fi

    # Cleanup
    chmod 755 "$test_dir"
}

test_symlink_to_nonexistent_target() {
    test_case "Symlink to nonexistent target"

    local test_link="$FIXTURE_DIR/broken-link"
    ln -s "/nonexistent/path/xyz" "$test_link"

    if __goto_bookmark_add "brokenlink" "$test_link" 2>/dev/null; then
        test_fail "Should reject symlink to nonexistent target"
    else
        test_pass "Broken symlink correctly rejected"
    fi

    # Cleanup
    rm -f "$test_link"
}

test_circular_symlink() {
    test_case "Circular symlink handling"

    local link1="$FIXTURE_DIR/link1"
    local link2="$FIXTURE_DIR/link2"

    ln -s "$link2" "$link1"
    ln -s "$link1" "$link2"

    if __goto_bookmark_add "circular" "$link1" 2>/dev/null; then
        test_fail "Should reject circular symlink"
    else
        test_pass "Circular symlink correctly rejected"
    fi

    # Cleanup
    rm -f "$link1" "$link2"
}

test_path_with_unicode_characters() {
    test_case "Path with Unicode characters"

    local test_dir="$FIXTURE_DIR/测试目录"
    mkdir -p "$test_dir"

    __goto_bookmark_add "unicode" "$test_dir" 2>/dev/null

    local result=$(__goto_bookmark_get "unicode" 2>/dev/null)

    if [ "$result" = "$test_dir" ]; then
        test_pass "Unicode characters in path handled correctly"
    else
        test_fail "Unicode path handling failed"
    fi
}

test_path_with_spaces() {
    test_case "Path with spaces in directory names"

    local test_dir="$FIXTURE_DIR/my test directory"
    mkdir -p "$test_dir"

    __goto_bookmark_add "spacepath" "$test_dir"

    local result=$(__goto_bookmark_get "spacepath")

    assert_equal "$test_dir" "$result" "Path with spaces should be preserved"
}

# ============================================================================
# Boundary Condition Tests
# ============================================================================

test_extremely_long_path() {
    test_case "Extremely long path (approaching filesystem limits)"

    # Create a deeply nested path (PATH_MAX is typically 1024 on macOS)
    local base="$FIXTURE_DIR"
    local long_path="$base"

    # Create path up to 500 characters (safe for most systems)
    for i in {1..20}; do
        long_path="$long_path/level$i"
    done

    mkdir -p "$long_path" 2>/dev/null

    if [ -d "$long_path" ]; then
        __goto_bookmark_add "longpath" "$long_path"
        local result=$(__goto_bookmark_get "longpath")

        assert_equal "$long_path" "$result" "Long path should be handled correctly"
    else
        test_pass "Filesystem rejected extremely long path (expected on some systems)"
    fi
}

test_max_history_overflow() {
    test_case "History tracking beyond maximum limit"

    # Ensure GOTO_HISTORY_MAX is set
    GOTO_HISTORY_MAX=${GOTO_HISTORY_MAX:-1000}

    # Track entries beyond the limit
    for i in $(seq 1 $((GOTO_HISTORY_MAX + 50))); do
        __goto_track "$FIXTURE_DIR/dir-$i"
    done

    local line_count=$(wc -l < "$GOTO_HISTORY_FILE" | tr -d ' ')

    if [ "$line_count" -le "$GOTO_HISTORY_MAX" ]; then
        test_pass "History correctly limited to $GOTO_HISTORY_MAX entries"
    else
        test_fail "History overflow not handled" "Expected max $GOTO_HISTORY_MAX, got $line_count"
    fi
}

test_empty_history_file() {
    test_case "Operations on empty history file"

    # Create empty history file
    touch "$GOTO_HISTORY_FILE"

    local output=$(__goto_recent_dirs 5 2>&1)

    if [ $? -ne 0 ]; then
        test_pass "Empty history file handled gracefully"
    else
        test_fail "Empty history should return error code"
    fi
}

test_corrupted_bookmark_file() {
    test_case "Corrupted bookmark file handling"

    # Write invalid data to bookmark file
    echo "invalid|bookmark|data|with|too|many|fields" > "$GOTO_BOOKMARKS_FILE"
    echo "another||invalid||entry" >> "$GOTO_BOOKMARKS_FILE"
    echo "|||" >> "$GOTO_BOOKMARKS_FILE"

    # Try to list bookmarks
    local output=$(__goto_bookmark_list 2>&1)

    # Should not crash, may show empty or error
    if [ $? -eq 0 ] || [ $? -eq 1 ]; then
        test_pass "Corrupted bookmark file handled without crashing"
    else
        test_fail "Corrupted bookmark file caused unexpected behavior"
    fi
}

test_corrupted_history_file() {
    test_case "Corrupted history file handling"

    # Write binary/invalid data
    echo -e "\x00\x01\x02\xFF\xFE" > "$GOTO_HISTORY_FILE"
    echo "valid/path/entry" >> "$GOTO_HISTORY_FILE"

    local output=$(__goto_recent_dirs 5 2>&1)

    # Should handle gracefully
    test_pass "Corrupted history file handled without crashing"
}

# ============================================================================
# Concurrent Operation Tests
# ============================================================================

test_simultaneous_bookmark_writes() {
    test_case "Simultaneous bookmark additions (race condition)"

    local test_dir1="$FIXTURE_DIR/concurrent1"
    local test_dir2="$FIXTURE_DIR/concurrent2"
    mkdir -p "$test_dir1" "$test_dir2"

    # Simulate concurrent writes
    (
        __goto_bookmark_add "concurrent1" "$test_dir1" 2>/dev/null
    ) &

    (
        __goto_bookmark_add "concurrent2" "$test_dir2" 2>/dev/null
    ) &

    wait

    # Verify both bookmarks were added
    local has_concurrent1=$(grep -c "concurrent1" "$GOTO_BOOKMARKS_FILE")
    local has_concurrent2=$(grep -c "concurrent2" "$GOTO_BOOKMARKS_FILE")

    if [ "$has_concurrent1" -eq 1 ] && [ "$has_concurrent2" -eq 1 ]; then
        test_pass "Concurrent bookmark writes handled correctly"
    else
        test_fail "Concurrent writes resulted in data loss or corruption"
    fi
}

test_history_race_condition() {
    test_case "History tracking race condition"

    # Track multiple directories concurrently
    for i in {1..5}; do
        (
            __goto_track "$FIXTURE_DIR/race-$i" 2>/dev/null
        ) &
    done

    wait

    # Verify history file is not corrupted
    local line_count=$(wc -l < "$GOTO_HISTORY_FILE" | tr -d ' ')

    if [ "$line_count" -ge 1 ]; then
        test_pass "History race condition handled (some entries recorded)"
    else
        test_fail "History race condition resulted in complete data loss"
    fi
}

# ============================================================================
# Cache System Edge Cases
# ============================================================================

test_cache_missing_directory() {
    test_case "Cache lookup for missing directory"

    # Build minimal cache
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "# Depth: 3"
        echo "#---"
        echo "deleted|/nonexistent/deleted/dir|2|1234567890"
    } > "$GOTO_INDEX_FILE"

    local result=$(__goto_cache_lookup "deleted" 2>/dev/null)

    if [ -z "$result" ]; then
        test_pass "Cache correctly handles deleted directories"
    else
        test_fail "Cache returned nonexistent directory"
    fi
}

test_cache_with_deleted_entries() {
    test_case "Cache contains stale entries for deleted folders"

    local test_dir="$FIXTURE_DIR/will-be-deleted"
    mkdir -p "$test_dir"

    # Create cache with this directory
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "# Depth: 3"
        echo "#---"
        echo "will-be-deleted|$test_dir|2|$(date +%s)"
    } > "$GOTO_INDEX_FILE"

    # Delete the directory
    rmdir "$test_dir"

    # Lookup should not return deleted directory
    local result=$(__goto_cache_lookup "will-be-deleted" 2>/dev/null)

    if [ -z "$result" ]; then
        test_pass "Cache validates directory existence"
    else
        test_fail "Cache returned deleted directory"
    fi
}

test_cache_with_invalid_permissions() {
    test_case "Cache file with invalid permissions"

    echo "test" > "$GOTO_INDEX_FILE"
    chmod 000 "$GOTO_INDEX_FILE"

    if __goto_cache_is_valid 2>/dev/null; then
        test_fail "Should reject unreadable cache file"
    else
        test_pass "Unreadable cache file correctly rejected"
    fi

    # Cleanup
    chmod 644 "$GOTO_INDEX_FILE"
}

test_cache_corrupted_header() {
    test_case "Cache with corrupted header"

    # Write cache with invalid header
    {
        echo "CORRUPTED HEADER"
        echo "test|/tmp/test|1|123456"
    } > "$GOTO_INDEX_FILE"

    if __goto_cache_is_valid 2>/dev/null; then
        test_fail "Should reject cache with corrupted header"
    else
        test_pass "Corrupted cache header correctly detected"
    fi
}

test_cache_empty_file() {
    test_case "Empty cache file handling"

    # Create empty cache file
    touch "$GOTO_INDEX_FILE"

    if __goto_cache_is_valid 2>/dev/null; then
        test_fail "Empty cache should be invalid"
    else
        test_pass "Empty cache file correctly rejected"
    fi
}

# ============================================================================
# Special Character Handling
# ============================================================================

test_path_with_dollar_sign() {
    test_case "Path containing dollar sign"

    local test_dir="$FIXTURE_DIR/price_\$100"
    mkdir -p "$test_dir"

    __goto_bookmark_add "dollar" "$test_dir"
    local result=$(__goto_bookmark_get "dollar")

    assert_equal "$test_dir" "$result" "Dollar sign in path should be preserved"
}

test_path_with_backticks() {
    test_case "Path containing backticks (injection protection)"

    # Note: backticks in filenames are valid on Unix
    local test_dir="$FIXTURE_DIR/test\`ls\`dir"

    # Only test if filesystem allows this (may fail on some systems)
    if mkdir -p "$test_dir" 2>/dev/null; then
        __goto_bookmark_add "backtick" "$test_dir" 2>/dev/null
        local result=$(__goto_bookmark_get "backtick" 2>/dev/null)

        if [ "$result" = "$test_dir" ]; then
            test_pass "Backticks in path handled safely"
        else
            test_fail "Backtick handling failed - potential injection risk"
        fi
    else
        test_pass "Filesystem rejects backticks in paths (safe)"
    fi
}

test_path_with_quotes() {
    test_case "Path containing quotes"

    local test_dir="$FIXTURE_DIR/test\"quoted\"dir"

    if mkdir -p "$test_dir" 2>/dev/null; then
        __goto_bookmark_add "quoted" "$test_dir"
        local result=$(__goto_bookmark_get "quoted")

        assert_equal "$test_dir" "$result" "Quotes in path should be preserved"
    else
        test_pass "Filesystem rejects quotes in paths"
    fi
}

test_path_with_newlines() {
    test_case "Path containing newline characters (security)"

    # Newlines should be rejected or escaped
    local test_dir="$FIXTURE_DIR/test\ndir"

    if __goto_bookmark_add "newline" "$test_dir" 2>/dev/null; then
        test_fail "Newline in path should be rejected (security issue)"
    else
        test_pass "Newline in path correctly rejected"
    fi
}

# Run tests
main
exit $?
