#!/bin/bash
# Unit tests for history tracking
# Tests directory tracking, history retrieval, and recent directories

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load module under test
source "$REPO_DIR/lib/history-tracking.sh"

# Test suite entry point
main() {
    test_suite "History Tracking Unit Tests"

    # Set up test fixture
    setup_test_fixture

    # Run test cases
    test_track_directory
    test_track_multiple_directories
    test_history_max_limit
    test_get_history
    test_recent_dirs_empty
    test_recent_dirs_with_entries
    test_recent_dirs_unique
    test_recent_dirs_limit

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_track_directory() {
    test_case "Track single directory visit"

    local test_dir="/tmp/test-dir-1"

    __goto_track "$test_dir"

    assert_file_exists "$GOTO_HISTORY_FILE" "History file should be created"
    assert_file_contains "$GOTO_HISTORY_FILE" "$test_dir" \
        "History file should contain tracked directory"
}

test_track_multiple_directories() {
    test_case "Track multiple directory visits"

    local dir1="/tmp/test-dir-1"
    local dir2="/tmp/test-dir-2"
    local dir3="/tmp/test-dir-3"

    __goto_track "$dir1"
    __goto_track "$dir2"
    __goto_track "$dir3"

    assert_file_contains "$GOTO_HISTORY_FILE" "$dir1" "History should contain dir1"
    assert_file_contains "$GOTO_HISTORY_FILE" "$dir2" "History should contain dir2"
    assert_file_contains "$GOTO_HISTORY_FILE" "$dir3" "History should contain dir3"
}

test_history_max_limit() {
    test_case "History file respects max limit"

    # Track more than max entries
    local max_entries=$GOTO_HISTORY_MAX
    local extra_entries=10

    for i in $(seq 1 $((max_entries + extra_entries))); do
        __goto_track "/tmp/test-dir-$i"
    done

    local line_count=$(wc -l < "$GOTO_HISTORY_FILE" | tr -d ' ')

    if [ "$line_count" -le "$max_entries" ]; then
        test_pass "History file size limited to $max_entries entries (actual: $line_count)"
    else
        test_fail "History file exceeds limit" \
            "Expected max $max_entries, got $line_count"
    fi
}

test_get_history() {
    test_case "Retrieve complete history"

    local dir1="/tmp/hist-1"
    local dir2="/tmp/hist-2"

    __goto_track "$dir1"
    __goto_track "$dir2"

    local history=$(__goto_get_history)

    assert_contains "$history" "$dir1" "History should contain dir1"
    assert_contains "$history" "$dir2" "History should contain dir2"
}

test_recent_dirs_empty() {
    test_case "Recent directories with empty history"

    # Ensure empty history
    rm -f "$GOTO_HISTORY_FILE"

    if __goto_recent_dirs 5 2>/dev/null; then
        test_fail "Empty history should return failure"
    else
        test_pass "Empty history correctly returns failure"
    fi
}

test_recent_dirs_with_entries() {
    test_case "Recent directories with entries"

    mkdir -p "$FIXTURE_DIR/recent-1" "$FIXTURE_DIR/recent-2"

    __goto_track "$FIXTURE_DIR/recent-1"
    __goto_track "$FIXTURE_DIR/recent-2"

    local recent=$(__goto_recent_dirs 5)

    # Most recent should be listed first
    local first_line=$(echo "$recent" | head -n 1)

    assert_equal "$FIXTURE_DIR/recent-2" "$first_line" \
        "Most recent directory should be listed first"
}

test_recent_dirs_unique() {
    test_case "Recent directories are unique (no duplicates)"

    mkdir -p "$FIXTURE_DIR/unique-test"

    # Visit same directory multiple times
    __goto_track "$FIXTURE_DIR/unique-test"
    __goto_track "$FIXTURE_DIR/other-dir"
    __goto_track "$FIXTURE_DIR/unique-test"
    __goto_track "$FIXTURE_DIR/unique-test"

    local recent=$(__goto_recent_dirs 10)
    local count=$(echo "$recent" | grep -c "unique-test")

    assert_equal "1" "$count" "Directory should appear only once in recent list"
}

test_recent_dirs_limit() {
    test_case "Recent directories respects limit parameter"

    for i in $(seq 1 20); do
        mkdir -p "$FIXTURE_DIR/limit-test-$i"
        __goto_track "$FIXTURE_DIR/limit-test-$i"
    done

    local recent=$(__goto_recent_dirs 5)
    local count=$(echo "$recent" | wc -l | tr -d ' ')

    assert_equal "5" "$count" "Should return exactly 5 recent directories"
}

# Run tests
main
exit $?
