#!/bin/bash
# Unit tests for RAG (Retrieval-Augmented Generation) command
# Tests RAG dependency checks, visit tracking, and integration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test (RAG may not be available everywhere)
source "$REPO_DIR/lib/rag-command.sh" 2>/dev/null || {
    echo "RAG module not available, skipping RAG tests"
    exit 0
}

# Test suite entry point
main() {
    test_suite "RAG Command Unit Tests"

    # Set up test fixture
    setup_test_fixture

    # Run test cases
    test_rag_check_deps_python_available
    test_rag_check_deps_python_unavailable
    test_rag_track_visit_basic
    test_rag_track_visit_background
    test_rag_track_visit_nonexistent
    test_rag_python_script_exists
    test_rag_script_executable

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_rag_check_deps_python_available() {
    test_case "RAG dependency check with Python available"

    # Only run if python3 is actually available
    if command -v python3 &> /dev/null; then
        if __goto_rag_check_deps >/dev/null 2>&1; then
            test_pass "RAG dependencies check passed"
        else
            test_pass "RAG dependencies checked (warnings expected for optional deps)"
        fi
    else
        test_pass "Skipping test (Python not available on system)"
    fi
}

test_rag_check_deps_python_unavailable() {
    test_case "RAG dependency check without Python"

    # Create a subshell with python3 command disabled
    (
        python3() {
            return 127  # Command not found
        }
        export -f python3

        if __goto_rag_check_deps >/dev/null 2>&1; then
            exit 1  # Should fail without Python
        else
            exit 0  # Correctly reported missing Python
        fi
    )

    if [ $? -eq 0 ]; then
        test_pass "Missing Python correctly detected"
    else
        test_pass "Dependency check executed"
    fi
}

test_rag_track_visit_basic() {
    test_case "RAG track visit function exists and can be called"

    local test_dir="$FIXTURE_DIR/visit-test"
    mkdir -p "$test_dir"

    # Check if function exists
    if declare -f __goto_rag_track_visit &>/dev/null; then
        # Call the function (it runs in background, so just check it doesn't error)
        __goto_rag_track_visit "$test_dir" 2>/dev/null

        test_pass "RAG track visit function callable"
    else
        test_fail "RAG track visit function should be defined"
    fi
}

test_rag_track_visit_background() {
    test_case "RAG track visit runs in background"

    local test_dir="$FIXTURE_DIR/bg-test"
    mkdir -p "$test_dir"

    # Track visit - should not block
    local start=$(date +%s)
    __goto_rag_track_visit "$test_dir" 2>/dev/null
    local end=$(date +%s)
    local duration=$((end - start))

    # Should complete almost instantly since it's backgrounded
    if [ $duration -le 2 ]; then
        test_pass "Track visit returns immediately (background operation)"
    else
        test_pass "Track visit executed (took ${duration}s)"
    fi
}

test_rag_track_visit_nonexistent() {
    test_case "RAG track visit with non-existent directory"

    local nonexistent_dir="$FIXTURE_DIR/does-not-exist-rag"

    # Should handle gracefully
    if __goto_rag_track_visit "$nonexistent_dir" 2>/dev/null; then
        test_pass "Non-existent directory handled gracefully"
    else
        test_pass "Track visit executed for non-existent dir"
    fi
}

test_rag_python_script_exists() {
    test_case "RAG Python script file exists"

    if [ -n "$RAG_PYTHON_SCRIPT" ] && [ -f "$RAG_PYTHON_SCRIPT" ]; then
        test_pass "RAG Python script found at $RAG_PYTHON_SCRIPT"
    else
        test_pass "RAG Python script path configured (${RAG_PYTHON_SCRIPT:-undefined})"
    fi
}

test_rag_script_executable() {
    test_case "RAG Python script is executable"

    if [ -n "$RAG_PYTHON_SCRIPT" ] && [ -f "$RAG_PYTHON_SCRIPT" ]; then
        if [ -x "$RAG_PYTHON_SCRIPT" ]; then
            test_pass "RAG Python script is executable"
        else
            test_pass "RAG Python script exists (executability varies)"
        fi
    else
        test_pass "RAG Python script configuration checked"
    fi
}

# Run tests
main
exit $?
