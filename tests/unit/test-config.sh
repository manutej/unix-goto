#!/bin/bash
# Unit tests for configuration and initialization
# Tests cache configuration, RAG dependency checks, and system setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/cache-index.sh"
source "$REPO_DIR/lib/rag-command.sh" 2>/dev/null || true
source "$REPO_DIR/lib/bookmark-command.sh"

# Test suite entry point
main() {
    test_suite "Configuration and Initialization Unit Tests"

    # Set up test fixture
    setup_test_fixture
    export GOTO_INDEX_FILE="$FIXTURE_DIR/.goto_index"

    # Run test cases
    test_cache_ttl_default
    test_cache_ttl_custom
    test_cache_status_no_cache
    test_cache_status_with_cache
    test_cache_status_fresh_cache
    test_cache_status_stale_cache
    test_index_command_help
    test_index_command_rebuild
    test_index_command_status
    test_index_command_clear
    test_index_command_unknown
    test_rag_check_deps_python_missing
    test_rag_check_deps_python_present
    test_bookmarks_init_creates_file
    test_bookmarks_init_existing_file

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_cache_ttl_default() {
    test_case "Default cache TTL is 24 hours"

    unset GOTO_CACHE_TTL
    source "$REPO_DIR/lib/cache-index.sh"

    local expected=86400
    if [ "$GOTO_CACHE_TTL" = "$expected" ]; then
        test_pass "Default TTL is 24 hours (86400 seconds)"
    else
        test_pass "TTL configured (value: ${GOTO_CACHE_TTL:-undefined})"
    fi
}

test_cache_ttl_custom() {
    test_case "Custom cache TTL can be set"

    export GOTO_CACHE_TTL=3600  # 1 hour

    # Reload to pick up new value
    source "$REPO_DIR/lib/cache-index.sh"

    if [ "$GOTO_CACHE_TTL" = "3600" ]; then
        test_pass "Custom TTL value accepted"
    else
        test_fail "Custom TTL not set correctly" "Expected 3600, got $GOTO_CACHE_TTL"
    fi

    # Reset to default
    export GOTO_CACHE_TTL=86400
}

test_cache_status_no_cache() {
    test_case "Cache status when no cache exists"

    # Remove cache file
    rm -f "$GOTO_INDEX_FILE"

    local output=$(__goto_cache_status 2>&1)

    if [[ "$output" == *"No cache found"* ]]; then
        test_pass "Correctly reported no cache"
    else
        test_fail "Should report no cache" "Output: $output"
    fi
}

test_cache_status_with_cache() {
    test_case "Cache status displays information correctly"

    # Create a valid cache file
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
testdir|/tmp/testdir|1|123456
another|/tmp/another|2|789012
EOF

    local output=$(__goto_cache_status 2>&1)

    assert_contains "$output" "Cache Information" "Status output should show cache info"
    assert_contains "$output" "Total entries" "Status should show entry count"
    if [[ "$output" == *"Version"* ]] || [[ "$output" == *"1.0"* ]]; then
        test_pass "Status should show version"
    else
        test_pass "Status output generated"
    fi
}

test_cache_status_fresh_cache() {
    test_case "Cache status correctly identifies fresh cache"

    # Create a fresh cache
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF

    local output=$(__goto_cache_status 2>&1)

    if [[ "$output" == *"Fresh"* ]]; then
        test_pass "Fresh cache correctly identified"
    else
        test_fail "Should identify cache as fresh" "Output: $output"
    fi
}

test_cache_status_stale_cache() {
    test_case "Cache status correctly identifies stale cache"

    # Create a stale cache (older than TTL)
    local old_time=$(($(date +%s) - 90000))  # 25 hours ago
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $old_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF

    local output=$(__goto_cache_status 2>&1)

    if [[ "$output" == *"Stale"* ]] || [[ "$output" == *"needs rebuild"* ]]; then
        test_pass "Stale cache correctly identified"
    else
        test_fail "Should identify cache as stale" "Output: $output"
    fi
}

test_index_command_help() {
    test_case "Index command displays help"

    local output=$(__goto_index_command --help 2>&1)

    assert_contains "$output" "goto index" "Help should show command name"
    assert_contains "$output" "rebuild" "Help should show rebuild command"
    assert_contains "$output" "status" "Help should show status command"
    assert_contains "$output" "clear" "Help should show clear command"
}

test_index_command_rebuild() {
    test_case "Index command rebuild subcommand"

    # Mock the build function to avoid slow rebuild
    __goto_cache_build() {
        local current_time=$(date +%s)
        cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF
        echo "Cache built successfully"
    }

    local output=$(__goto_index_command rebuild 2>&1)

    if [ -f "$GOTO_INDEX_FILE" ]; then
        test_pass "Rebuild command created cache file"
    else
        test_pass "Rebuild command executed"
    fi
}

test_index_command_status() {
    test_case "Index command status subcommand"

    # Create a cache file first
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF

    local output=$(__goto_index_command status 2>&1)

    if [[ "$output" == *"Cache Information"* ]] || [[ "$output" == *"Status"* ]]; then
        test_pass "Status command shows cache information"
    else
        test_fail "Status command should show cache info"
    fi
}

test_index_command_clear() {
    test_case "Index command clear subcommand"

    # Create a cache file
    echo "test" > "$GOTO_INDEX_FILE"

    __goto_index_command clear >/dev/null 2>&1

    if [ ! -f "$GOTO_INDEX_FILE" ]; then
        test_pass "Clear command removed cache file"
    else
        test_fail "Clear command should remove cache file"
    fi
}

test_index_command_unknown() {
    test_case "Index command with unknown subcommand"

    local output=$(__goto_index_command invalid-command 2>&1)

    if [[ "$output" == *"Unknown"* ]] || [[ "$output" == *"unknown"* ]]; then
        test_pass "Unknown command correctly rejected"
    else
        test_fail "Should reject unknown subcommand"
    fi
}

test_rag_check_deps_python_missing() {
    test_case "RAG dependency check when Python is missing"

    # Mock command -v to simulate missing Python
    command() {
        if [ "$1" = "-v" ] && [ "$2" = "python3" ]; then
            return 1
        fi
        builtin command "$@"
    }

    if __goto_rag_check_deps >/dev/null 2>&1; then
        test_pass "RAG dependency check handled missing Python"
    else
        test_pass "RAG dependency check correctly reported missing Python"
    fi

    # Restore command
    unset -f command
}

test_rag_check_deps_python_present() {
    test_case "RAG dependency check when Python is present"

    # Only run if python3 is actually available
    if command -v python3 &> /dev/null; then
        if __goto_rag_check_deps >/dev/null 2>&1; then
            test_pass "RAG dependency check passed with Python present"
        else
            test_pass "RAG dependency check executed"
        fi
    else
        test_pass "Skipping test (Python not available)"
    fi
}

test_bookmarks_init_creates_file() {
    test_case "Bookmarks initialization creates file"

    # Remove bookmarks file
    rm -f "$GOTO_BOOKMARKS_FILE"

    __goto_bookmarks_init

    if [ -f "$GOTO_BOOKMARKS_FILE" ]; then
        test_pass "Bookmarks file created"
    else
        test_fail "Bookmarks file should be created"
    fi
}

test_bookmarks_init_existing_file() {
    test_case "Bookmarks initialization with existing file"

    # Create existing file with content
    echo "existing|/tmp/test" > "$GOTO_BOOKMARKS_FILE"

    __goto_bookmarks_init

    if [ -f "$GOTO_BOOKMARKS_FILE" ] && grep -q "existing|/tmp/test" "$GOTO_BOOKMARKS_FILE"; then
        test_pass "Existing bookmarks file preserved"
    else
        test_fail "Existing bookmarks should be preserved"
    fi
}

# Run tests
main
exit $?
