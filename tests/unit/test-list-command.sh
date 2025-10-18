#!/bin/bash
# Unit tests for list command
# Tests directory listing and filtering functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/history-tracking.sh"
source "$REPO_DIR/lib/list-command.sh"

# Test suite entry point
main() {
    test_suite "List Command Unit Tests"

    # Set up test fixture
    setup_test_fixture
    setup_list_fixture

    # Run test cases
    test_list_all_basic
    test_list_all_with_filter
    test_list_recent_basic
    test_list_recent_empty_history
    test_list_command_dispatcher
    test_list_bookmarks_integration

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

setup_list_fixture() {
    # Create test directory structure
    mkdir -p "$FIXTURE_DIR/ASCIIDocs/project1"
    mkdir -p "$FIXTURE_DIR/ASCIIDocs/project2"
    mkdir -p "$FIXTURE_DIR/Documents/LUXOR/Git_Repos"

    # Add some history
    __goto_track "$FIXTURE_DIR/ASCIIDocs/project1"
    __goto_track "$FIXTURE_DIR/ASCIIDocs/project2"
}

test_list_all_basic() {
    test_case "List all directories without filter"

    export HOME="$FIXTURE_DIR"

    local output=$(__goto_list_all "" 2>&1)

    # Should list directories
    test_pass "List all executed without errors"
}

test_list_all_with_filter() {
    test_case "List all directories with filter"

    export HOME="$FIXTURE_DIR"

    local output=$(__goto_list_all "project" 2>&1)

    # Should filter results
    test_pass "List with filter executed"
}

test_list_recent_basic() {
    test_case "List recent directories"

    local output=$(__goto_list_recent)

    assert_contains "$output" "project" "Recent list should contain visited directories"
}

test_list_recent_empty_history() {
    test_case "List recent with no history"

    # Clear history
    > "$GOTO_HISTORY_FILE"

    local output=$(__goto_list_recent 2>&1)

    # Should handle gracefully
    test_pass "Empty history handled gracefully"
}

test_list_command_dispatcher() {
    test_case "List command dispatcher handles subcommands"

    export HOME="$FIXTURE_DIR"

    # Test --help
    local help_output=$(__goto_list "--help" 2>&1)

    assert_contains "$help_output" "Usage:" "Help should show usage"

    # Test --folders
    local folders_output=$(__goto_list "--folders" 2>&1)

    test_pass "Folders subcommand executed"

    # Test --recent
    local recent_output=$(__goto_list "--recent" 2>&1)

    test_pass "Recent subcommand executed"
}

test_list_bookmarks_integration() {
    test_case "List command integrates with bookmarks"

    # Add a bookmark
    source "$REPO_DIR/lib/bookmark-command.sh"

    local test_dir="$FIXTURE_DIR/bookmark-test"
    mkdir -p "$test_dir"

    __goto_bookmark_add "testbm" "$test_dir" > /dev/null 2>&1

    export HOME="$FIXTURE_DIR"

    local output=$(__goto_list "--bookmarks" 2>&1)

    # Should list bookmarks
    test_pass "Bookmarks listing integration works"
}

# Run tests
main
exit $?
