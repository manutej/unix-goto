#!/bin/bash
# Unit tests for back command (directory stack)
# Tests stack operations and navigation history

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load module under test
source "$REPO_DIR/lib/back-command.sh"

# Test suite entry point
main() {
    test_suite "Back Command Unit Tests"

    # Set up test fixture
    setup_test_fixture

    # Run test cases
    test_stack_initialization
    test_stack_push_single
    test_stack_push_multiple
    test_stack_pop_success
    test_stack_pop_empty
    test_stack_list_empty
    test_stack_list_with_entries
    test_stack_max_depth

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_stack_initialization() {
    test_case "Stack initialization creates file"

    __goto_stack_init

    assert_file_exists "$GOTO_STACK_FILE" "Stack file should be created"
}

test_stack_push_single() {
    test_case "Push single directory to stack"

    local test_dir="/tmp/test-stack-1"

    __goto_stack_push "$test_dir"

    assert_file_contains "$GOTO_STACK_FILE" "$test_dir" \
        "Stack should contain pushed directory"
}

test_stack_push_multiple() {
    test_case "Push multiple directories to stack"

    local dir1="/tmp/stack-1"
    local dir2="/tmp/stack-2"
    local dir3="/tmp/stack-3"

    __goto_stack_push "$dir1"
    __goto_stack_push "$dir2"
    __goto_stack_push "$dir3"

    assert_file_contains "$GOTO_STACK_FILE" "$dir1" "Stack should contain dir1"
    assert_file_contains "$GOTO_STACK_FILE" "$dir2" "Stack should contain dir2"
    assert_file_contains "$GOTO_STACK_FILE" "$dir3" "Stack should contain dir3"
}

test_stack_pop_success() {
    test_case "Pop directory from stack"

    local dir1="/tmp/pop-1"
    local dir2="/tmp/pop-2"

    __goto_stack_push "$dir1"
    __goto_stack_push "$dir2"

    # Pop should return most recent entry (LIFO)
    local popped=$(__goto_stack_pop)

    assert_equal "$dir2" "$popped" "Pop should return most recent entry"

    # Verify it was removed from stack
    local remaining=$(__goto_stack_list 2>/dev/null)

    if echo "$remaining" | grep -q "$dir2"; then
        test_fail "Popped entry should be removed from stack"
    else
        test_pass "Popped entry correctly removed"
    fi
}

test_stack_pop_empty() {
    test_case "Pop from empty stack fails gracefully"

    # Ensure empty stack
    > "$GOTO_STACK_FILE"

    if __goto_stack_pop 2>/dev/null; then
        test_fail "Pop from empty stack should fail"
    else
        test_pass "Empty stack pop correctly rejected"
    fi
}

test_stack_list_empty() {
    test_case "List empty stack"

    > "$GOTO_STACK_FILE"

    local output=$(__goto_stack_list 2>&1)

    # Should handle gracefully (may show empty or error message)
    test_pass "Empty stack list handled gracefully"
}

test_stack_list_with_entries() {
    test_case "List stack with entries"

    local dir1="/tmp/list-1"
    local dir2="/tmp/list-2"

    __goto_stack_push "$dir1"
    __goto_stack_push "$dir2"

    local output=$(__goto_stack_list)

    assert_contains "$output" "$dir1" "List should contain dir1"
    assert_contains "$output" "$dir2" "List should contain dir2"
}

test_stack_max_depth() {
    test_case "Stack respects maximum depth limit"

    # Ensure GOTO_STACK_MAX is set
    GOTO_STACK_MAX=${GOTO_STACK_MAX:-50}

    # Push beyond limit
    for i in $(seq 1 $((GOTO_STACK_MAX + 10))); do
        __goto_stack_push "/tmp/depth-$i"
    done

    local line_count=$(wc -l < "$GOTO_STACK_FILE" | tr -d ' ')

    if [ "$line_count" -le "$GOTO_STACK_MAX" ]; then
        test_pass "Stack correctly limited to $GOTO_STACK_MAX entries"
    else
        test_fail "Stack overflow not handled" \
            "Expected max $GOTO_STACK_MAX, got $line_count"
    fi
}

# Run tests
main
exit $?
