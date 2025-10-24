#!/bin/bash
# Unit tests for bookmark command
# Tests bookmark creation, retrieval, deletion, and navigation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load module under test
source "$REPO_DIR/lib/bookmark-command.sh"

# Test suite entry point
main() {
    test_suite "Bookmark Command Unit Tests"

    # Set up test fixture
    setup_test_fixture

    # Run test cases
    test_bookmark_initialization
    test_bookmark_add
    test_bookmark_add_with_explicit_path
    test_bookmark_add_duplicate
    test_bookmark_add_invalid_path
    test_bookmark_remove
    test_bookmark_remove_nonexistent
    test_bookmark_get
    test_bookmark_list_empty
    test_bookmark_list_with_entries
    test_bookmark_goto
    test_bookmark_goto_nonexistent
    test_bookmark_goto_deleted_dir

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_bookmark_initialization() {
    test_case "Bookmark file initialization"

    __goto_bookmarks_init

    assert_file_exists "$GOTO_BOOKMARKS_FILE" "Bookmark file should be created"
}

test_bookmark_add() {
    test_case "Add bookmark for current directory"

    local test_dir="$FIXTURE_DIR/test-project"
    mkdir -p "$test_dir"
    cd "$test_dir"

    __goto_bookmark_add "myproject"

    assert_file_contains "$GOTO_BOOKMARKS_FILE" "myproject|$test_dir" \
        "Bookmark entry should be added to file"
}

test_bookmark_add_with_explicit_path() {
    test_case "Add bookmark with explicit path"

    local test_dir="$FIXTURE_DIR/another-project"
    mkdir -p "$test_dir"

    __goto_bookmark_add "anotherproj" "$test_dir"

    assert_file_contains "$GOTO_BOOKMARKS_FILE" "anotherproj|$test_dir" \
        "Bookmark with explicit path should be added"
}

test_bookmark_add_duplicate() {
    test_case "Add duplicate bookmark should fail"

    local test_dir="$FIXTURE_DIR/duplicate"
    mkdir -p "$test_dir"

    __goto_bookmark_add "dup" "$test_dir"

    if __goto_bookmark_add "dup" "$test_dir" 2>/dev/null; then
        test_fail "Duplicate bookmark should fail" "Function returned success"
    else
        test_pass "Duplicate bookmark correctly rejected"
    fi
}

test_bookmark_add_invalid_path() {
    test_case "Add bookmark with invalid path should fail"

    if __goto_bookmark_add "invalid" "/nonexistent/path/xyz" 2>/dev/null; then
        test_fail "Invalid path should fail" "Function returned success"
    else
        test_pass "Invalid path correctly rejected"
    fi
}

test_bookmark_remove() {
    test_case "Remove existing bookmark"

    local test_dir="$FIXTURE_DIR/removeme"
    mkdir -p "$test_dir"

    __goto_bookmark_add "removeme" "$test_dir"
    __goto_bookmark_remove "removeme"

    if grep -q "removeme|" "$GOTO_BOOKMARKS_FILE"; then
        test_fail "Bookmark should be removed" "Bookmark still exists in file"
    else
        test_pass "Bookmark successfully removed"
    fi
}

test_bookmark_remove_nonexistent() {
    test_case "Remove nonexistent bookmark should fail"

    if __goto_bookmark_remove "doesnotexist" 2>/dev/null; then
        test_fail "Removing nonexistent bookmark should fail"
    else
        test_pass "Nonexistent bookmark removal correctly rejected"
    fi
}

test_bookmark_get() {
    test_case "Get bookmark path"

    local test_dir="$FIXTURE_DIR/gettest"
    mkdir -p "$test_dir"

    __goto_bookmark_add "gettest" "$test_dir"

    local result=$(__goto_bookmark_get "gettest")

    assert_equal "$test_dir" "$result" "Retrieved path should match stored path"
}

test_bookmark_list_empty() {
    test_case "List bookmarks when empty"

    # Clear bookmarks file completely
    > "$GOTO_BOOKMARKS_FILE"

    local output=$(__goto_bookmark_list)

    assert_contains "$output" "No bookmarks yet" "Empty list should show message"
}

test_bookmark_list_with_entries() {
    test_case "List bookmarks with entries"

    # Start fresh
    > "$GOTO_BOOKMARKS_FILE"

    local test_dir1="$FIXTURE_DIR/proj1"
    local test_dir2="$FIXTURE_DIR/proj2"
    mkdir -p "$test_dir1" "$test_dir2"

    __goto_bookmark_add "proj1" "$test_dir1"
    __goto_bookmark_add "proj2" "$test_dir2"

    local output=$(__goto_bookmark_list)

    assert_contains "$output" "proj1" "List should contain proj1"
    assert_contains "$output" "proj2" "List should contain proj2"
    assert_contains "$output" "Total: 2" "List should show correct count"
}

test_bookmark_goto() {
    test_case "Navigate to bookmark"

    local test_dir="$FIXTURE_DIR/gototest"
    mkdir -p "$test_dir"

    __goto_bookmark_add "gototest" "$test_dir"

    local original_dir="$PWD"

    # Navigate using bookmark (capture in subshell to avoid changing test dir)
    (
        __goto_bookmark_goto "gototest" >/dev/null 2>&1
        current_dir="$PWD"

        if [ "$current_dir" = "$test_dir" ]; then
            exit 0
        else
            exit 1
        fi
    )

    if [ $? -eq 0 ]; then
        test_pass "Navigation to bookmark succeeded"
    else
        test_fail "Navigation to bookmark failed"
    fi
}

test_bookmark_goto_nonexistent() {
    test_case "Navigate to nonexistent bookmark should fail"

    if __goto_bookmark_goto "nosuchbookmark" 2>/dev/null; then
        test_fail "Nonexistent bookmark navigation should fail"
    else
        test_pass "Nonexistent bookmark navigation correctly rejected"
    fi
}

test_bookmark_goto_deleted_dir() {
    test_case "Navigate to bookmark with deleted directory should fail"

    local test_dir="$FIXTURE_DIR/deleted"
    mkdir -p "$test_dir"

    __goto_bookmark_add "deleted" "$test_dir"

    # Delete the directory
    rmdir "$test_dir"

    if __goto_bookmark_goto "deleted" 2>/dev/null; then
        test_fail "Navigation to deleted directory should fail"
    else
        test_pass "Navigation to deleted directory correctly rejected"
    fi
}

# Run tests
main
exit $?
