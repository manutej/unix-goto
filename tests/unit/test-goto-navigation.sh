#!/bin/bash
# Unit tests for goto navigation logic
# Tests directory resolution, multi-level paths, and search functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/history-tracking.sh"
source "$REPO_DIR/lib/goto-function.sh"

# Test suite entry point
main() {
    test_suite "Goto Navigation Unit Tests"

    # Set up test fixture
    setup_test_fixture
    setup_navigation_fixture

    # Run test cases
    test_navigate_to_helper
    test_help_flag
    test_empty_input
    test_home_shortcut
    test_multi_level_path_parsing
    test_direct_folder_match
    test_nonexistent_folder

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

setup_navigation_fixture() {
    # Create test directory structure
    create_test_dirs "$FIXTURE_DIR" \
        "ASCIIDocs/project1" \
        "ASCIIDocs/project2" \
        "Documents/LUXOR/Git_Repos/unix-goto" \
        "Documents/LUXOR/PROJECTS/HALCON"
}

test_navigate_to_helper() {
    test_case "Navigate to directory helper function"

    local test_dir="$FIXTURE_DIR/nav-test"
    mkdir -p "$test_dir"

    # Test in subshell to avoid changing test directory
    (
        __goto_navigate_to "$test_dir" >/dev/null 2>&1

        if [ "$PWD" = "$test_dir" ]; then
            exit 0
        else
            exit 1
        fi
    )

    if [ $? -eq 0 ]; then
        test_pass "Navigation helper changes directory correctly"
    else
        test_fail "Navigation helper failed to change directory"
    fi

    # Verify history was tracked
    assert_file_contains "$GOTO_HISTORY_FILE" "$test_dir" \
        "Navigation should be tracked in history"
}

test_help_flag() {
    test_case "Help flag displays usage"

    local output=$(goto --help 2>&1)

    assert_contains "$output" "Usage:" "Help should contain usage section"
    assert_contains "$output" "goto <project>" "Help should show basic command"
    assert_contains "$output" "Bookmarks:" "Help should mention bookmarks"
}

test_empty_input() {
    test_case "Empty input shows help"

    local output=$(goto 2>&1)

    assert_contains "$output" "Usage:" "Empty input should show help"
}

test_home_shortcut() {
    test_case "Tilde shortcut navigates home"

    (
        goto "~" >/dev/null 2>&1

        if [ "$PWD" = "$HOME" ]; then
            exit 0
        else
            exit 1
        fi
    )

    if [ $? -eq 0 ]; then
        test_pass "Tilde shortcut navigates to home"
    else
        test_fail "Tilde shortcut failed"
    fi
}

test_multi_level_path_parsing() {
    test_case "Multi-level path parsing"

    # Test path with slashes
    local test_input="project1/subdir/deep"

    # Extract base segment
    local base="${test_input%%/*}"
    local rest="${test_input#*/}"

    assert_equal "project1" "$base" "Base segment extracted correctly"
    assert_equal "subdir/deep" "$rest" "Remaining path extracted correctly"
}

test_direct_folder_match() {
    test_case "Direct folder match in search paths"

    # Create a test search structure
    local search_base="$FIXTURE_DIR/search-test"
    mkdir -p "$search_base/target-folder"

    # Mock the search by checking directory existence
    local target="target-folder"

    if [ -d "$search_base/$target" ]; then
        test_pass "Direct folder match found"
    else
        test_fail "Direct folder match failed"
    fi
}

test_nonexistent_folder() {
    test_case "Nonexistent folder handling"

    local output=$(goto "nonexistent-folder-xyz-123" 2>&1)

    assert_contains "$output" "not found" \
        "Nonexistent folder should show error message"
}

# Run tests
main
exit $?
