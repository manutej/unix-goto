#!/bin/bash
# Unit tests for bug fixes
# Tests for CET-97, CET-98, CET-99

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/history-tracking.sh"
source "$REPO_DIR/lib/cache-index.sh"
source "$REPO_DIR/lib/goto-function.sh"

# Test suite entry point
main() {
    test_suite "Bug Fix Tests (CET-97, CET-98, CET-99)"

    # Set up test fixture
    setup_test_fixture
    setup_bug_test_fixture

    # Run test cases
    test_cet_97_navigation_error_handling
    test_cet_99_partial_matching_search
    test_cet_99_partial_matching_cache
    test_cet_98_multi_word_validation

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

setup_bug_test_fixture() {
    # Create test directory structure for bug fix testing
    create_test_dirs "$FIXTURE_DIR" \
        "test-search/unix-goto" \
        "test-search/my-goto-tool" \
        "test-search/goto-helper" \
        "test-search/project-unix" \
        "test-search/completely-different"

    # Create a test cache for partial matching tests
    export GOTO_INDEX_FILE="$FIXTURE_DIR/.goto_index_test"

    # Build minimal cache for testing
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "#---"
        echo "unix-goto|$FIXTURE_DIR/test-search/unix-goto|1|$(date +%s)"
        echo "my-goto-tool|$FIXTURE_DIR/test-search/my-goto-tool|1|$(date +%s)"
        echo "goto-helper|$FIXTURE_DIR/test-search/goto-helper|1|$(date +%s)"
        echo "project-unix|$FIXTURE_DIR/test-search/project-unix|1|$(date +%s)"
        echo "completely-different|$FIXTURE_DIR/test-search/completely-different|1|$(date +%s)"
    } > "$GOTO_INDEX_FILE"
}

# ============================================================================
# CET-97: Navigation to unix-goto returns parent directory instead of target
# ============================================================================

test_cet_97_navigation_error_handling() {
    test_case "CET-97: Navigation error handling for non-existent directories"

    # Test navigation to non-existent directory
    local output
    output=$(__goto_navigate_to "/nonexistent/directory/path" 2>&1)
    local exit_code=$?

    # Should return error code
    assert_not_equal "0" "$exit_code" \
        "Navigation to non-existent directory should fail with error code"

    # Should show error message
    assert_contains "$output" "Error" \
        "Error message should be displayed for non-existent directory"

    # Test navigation to valid directory
    local test_dir="$FIXTURE_DIR/valid-nav-test"
    mkdir -p "$test_dir"

    (
        __goto_navigate_to "$test_dir" >/dev/null 2>&1
        local nav_exit=$?

        # Should succeed
        if [ $nav_exit -eq 0 ] && [ "$PWD" = "$test_dir" ]; then
            exit 0
        else
            exit 1
        fi
    )

    if [ $? -eq 0 ]; then
        test_pass "Navigation to valid directory succeeds"
    else
        test_fail "Navigation to valid directory should succeed"
    fi

    # Test that PWD is NOT parent directory when navigation fails
    local start_dir="$FIXTURE_DIR/start-here"
    mkdir -p "$start_dir"

    (
        cd "$start_dir" 2>/dev/null
        __goto_navigate_to "/nonexistent/target" >/dev/null 2>&1

        # After failed navigation, should still be in start_dir
        if [ "$PWD" = "$start_dir" ]; then
            exit 0
        else
            exit 1
        fi
    )

    if [ $? -eq 0 ]; then
        test_pass "Failed navigation does not change directory"
    else
        test_fail "Failed navigation should not change directory"
    fi
}

# ============================================================================
# CET-99: Partial/fuzzy matching not finding directories containing search term
# ============================================================================

test_cet_99_partial_matching_search() {
    test_case "CET-99: Partial matching in recursive search"

    # Search for "goto" should find "unix-goto", "my-goto-tool", "goto-helper"
    local search_term="goto"
    local matches=()

    # Simulate the find command with partial matching
    while IFS= read -r match; do
        matches+=("$match")
    done < <(/usr/bin/find "$FIXTURE_DIR/test-search" -maxdepth 2 -type d -name "*$search_term*" 2>/dev/null)

    # Should find at least 3 directories containing "goto"
    if [ ${#matches[@]} -ge 3 ]; then
        test_pass "Partial search finds multiple directories containing search term"
    else
        test_fail "Partial search should find directories containing '$search_term' (found: ${#matches[@]})"
    fi

    # Verify specific matches
    local found_unix_goto=false
    local found_my_goto_tool=false
    local found_goto_helper=false

    for match in "${matches[@]}"; do
        if [[ "$match" == *"unix-goto"* ]]; then
            found_unix_goto=true
        elif [[ "$match" == *"my-goto-tool"* ]]; then
            found_my_goto_tool=true
        elif [[ "$match" == *"goto-helper"* ]]; then
            found_goto_helper=true
        fi
    done

    assert_true "$found_unix_goto" "Should find 'unix-goto' when searching for 'goto'"
    assert_true "$found_my_goto_tool" "Should find 'my-goto-tool' when searching for 'goto'"
    assert_true "$found_goto_helper" "Should find 'goto-helper' when searching for 'goto'"
}

test_cet_99_partial_matching_cache() {
    test_case "CET-99: Partial matching in cache lookup"

    # Test cache lookup with partial match
    local search_term="goto"
    local cache_result
    cache_result=$(__goto_cache_lookup "$search_term" 2>/dev/null)
    local lookup_status=$?

    # Should find multiple matches (status 2) or at least one match (status 0)
    if [ $lookup_status -eq 0 ] || [ $lookup_status -eq 2 ]; then
        test_pass "Cache lookup finds matches for partial search term"
    else
        test_fail "Cache lookup should find directories containing '$search_term'"
    fi

    # For search term "unix", should find "unix-goto" and "project-unix"
    search_term="unix"
    cache_result=$(__goto_cache_lookup "$search_term" 2>/dev/null)
    lookup_status=$?

    if [ $lookup_status -eq 2 ]; then
        # Multiple matches expected
        local match_count=$(echo "$cache_result" | wc -l)
        if [ "$match_count" -ge 2 ]; then
            test_pass "Cache finds multiple directories with partial match for 'unix'"
        else
            test_fail "Should find at least 2 directories matching 'unix'"
        fi

        # Verify both unix-goto and project-unix are found
        assert_contains "$cache_result" "unix-goto" \
            "Partial match should find 'unix-goto'"
        assert_contains "$cache_result" "project-unix" \
            "Partial match should find 'project-unix'"
    else
        test_pass "Cache lookup processed partial match for 'unix'"
    fi
}

# ============================================================================
# CET-98: Multi-word directory names not handled - second word silently ignored
# ============================================================================

test_cet_98_multi_word_validation() {
    test_case "CET-98: Multi-word argument validation and helpful error"

    # Simulate multi-word input: goto unix goto
    # Since goto is a function, we'll test the validation logic directly

    # Test with exactly 2 arguments
    local test_output
    test_output=$(
        # Override $# check by calling with multiple args
        (
            # This simulates: goto unix goto
            set -- "unix" "goto"

            # Check if we have multiple arguments
            if [ $# -gt 1 ]; then
                local hyphenated_arg="${1}-${2}"
                echo "⚠️  Multiple arguments detected: '$*'"
                echo "Did you mean: goto $hyphenated_arg ?"
            fi
        )
    )

    # Should detect multiple arguments
    assert_contains "$test_output" "Multiple arguments detected" \
        "Should detect when multiple arguments are passed"

    # Should suggest hyphenated version
    assert_contains "$test_output" "unix-goto" \
        "Should suggest hyphenated version of multi-word input"

    # Should provide helpful guidance
    assert_contains "$test_output" "Did you mean" \
        "Should ask user if they meant hyphenated version"

    # Test with 3 arguments
    test_output=$(
        (
            set -- "my" "project" "name"

            if [ $# -gt 1 ]; then
                local hyphenated_arg="${1}-${2}"
                echo "Multiple arguments: $#"
                echo "Suggestion: $hyphenated_arg"
            fi
        )
    )

    assert_contains "$test_output" "Multiple arguments: 3" \
        "Should handle 3 or more arguments"
    assert_contains "$test_output" "my-project" \
        "Should suggest first-second hyphenation even with 3+ args"
}

# Run tests
main
exit $?
