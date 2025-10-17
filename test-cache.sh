#!/bin/bash
# unix-goto - Cache Index System Tests (CET-77)
# Comprehensive test suite for folder index caching
# https://github.com/manutej/unix-goto

set -e

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_WORKSPACE="/tmp/goto-cache-test-$$"
GOTO_INDEX_FILE_BACKUP="${HOME}/.goto_index.backup"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Helper functions
print_header() {
    echo ""
    echo "================================================================"
    echo "$1"
    echo "================================================================"
    echo ""
}

print_test() {
    echo -e "${BLUE}TEST:${NC} $1"
}

pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
}

fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
}

skip() {
    echo -e "${YELLOW}⊘ SKIP:${NC} $1"
}

setup_test_workspace() {
    print_header "Setting Up Test Workspace"

    # Create test directory structure
    mkdir -p "$TEST_WORKSPACE"
    mkdir -p "$TEST_WORKSPACE/projects/proj1"
    mkdir -p "$TEST_WORKSPACE/projects/proj2"
    mkdir -p "$TEST_WORKSPACE/projects/deep/nested/folder"
    mkdir -p "$TEST_WORKSPACE/work/client-a"
    mkdir -p "$TEST_WORKSPACE/work/client-b"
    mkdir -p "$TEST_WORKSPACE/docs/guides"
    mkdir -p "$TEST_WORKSPACE/duplicate/name"
    mkdir -p "$TEST_WORKSPACE/other/duplicate/name"

    echo "Created test workspace at: $TEST_WORKSPACE"
    echo "Total test directories: $(find "$TEST_WORKSPACE" -type d | wc -l | tr -d ' ')"
}

cleanup_test_workspace() {
    print_header "Cleaning Up Test Workspace"

    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
        echo "Removed test workspace: $TEST_WORKSPACE"
    fi

    # Restore original cache if backed up
    if [ -f "$GOTO_INDEX_FILE_BACKUP" ]; then
        mv "$GOTO_INDEX_FILE_BACKUP" "${HOME}/.goto_index"
        echo "Restored original cache"
    fi
}

backup_existing_cache() {
    if [ -f "${HOME}/.goto_index" ]; then
        cp "${HOME}/.goto_index" "$GOTO_INDEX_FILE_BACKUP"
        echo "Backed up existing cache"
    fi
}

# Load cache functions
source_cache_functions() {
    if [ -f "$SCRIPT_DIR/lib/cache-index.sh" ]; then
        source "$SCRIPT_DIR/lib/cache-index.sh"
        echo "Loaded cache functions from lib/cache-index.sh"
    else
        echo "ERROR: Cannot find lib/cache-index.sh"
        exit 1
    fi
}

# Test 1: Cache file creation
test_cache_creation() {
    print_test "Cache file creation"

    rm -f "${HOME}/.goto_index"

    # Override search paths for testing
    GOTO_SEARCH_PATHS=("$TEST_WORKSPACE")

    # Build cache (should create file)
    __goto_cache_build > /dev/null 2>&1

    if [ -f "${HOME}/.goto_index" ]; then
        pass "Cache file created successfully"
    else
        fail "Cache file not created"
    fi
}

# Test 2: Cache format validation
test_cache_format() {
    print_test "Cache format validation"

    # Check header exists
    if grep -q "^# unix-goto folder index cache" "${HOME}/.goto_index"; then
        pass "Cache header is valid"
    else
        fail "Cache header missing or invalid"
    fi

    # Check version line
    if grep -q "^# Version:" "${HOME}/.goto_index"; then
        pass "Cache version line present"
    else
        fail "Cache version line missing"
    fi

    # Check timestamp
    if grep -q "^# Built:" "${HOME}/.goto_index"; then
        pass "Cache timestamp present"
    else
        fail "Cache timestamp missing"
    fi

    # Check data entries format (should be: name|path|depth|mtime)
    local entry_count=$(grep -v "^#" "${HOME}/.goto_index" | wc -l | tr -d ' ')
    if [ "$entry_count" -gt 0 ]; then
        pass "Cache contains $entry_count data entries"
    else
        fail "Cache contains no data entries"
    fi
}

# Test 3: Cache lookup - exact match
test_cache_lookup_exact() {
    print_test "Cache lookup - exact match"

    # Test looking up a folder that should exist
    local result
    result=$(__goto_cache_lookup "proj1" 2>/dev/null)
    local status=$?

    if [ $status -eq 0 ] && [[ "$result" == *"proj1"* ]]; then
        pass "Exact match lookup successful: $result"
    else
        fail "Exact match lookup failed (status: $status)"
    fi
}

# Test 4: Cache lookup - not found
test_cache_lookup_not_found() {
    print_test "Cache lookup - not found"

    local result
    result=$(__goto_cache_lookup "nonexistent-folder-xyz" 2>/dev/null)
    local status=$?

    if [ $status -eq 1 ]; then
        pass "Not found lookup returned correct status"
    else
        fail "Not found lookup returned wrong status: $status"
    fi
}

# Test 5: Cache lookup - multiple matches
test_cache_lookup_multiple() {
    print_test "Cache lookup - multiple matches"

    # Look up "name" which exists in multiple locations
    local result
    result=$(__goto_cache_lookup "name" 2>/dev/null)
    local status=$?

    if [ $status -eq 2 ]; then
        pass "Multiple matches returned correct status"
        local count=$(echo "$result" | wc -l | tr -d ' ')
        echo "  Found $count matches"
    else
        fail "Multiple matches returned wrong status: $status"
    fi
}

# Test 6: Cache validity check - fresh cache
test_cache_validity_fresh() {
    print_test "Cache validity - fresh cache"

    # Cache was just built, should be valid
    if __goto_cache_is_valid; then
        pass "Fresh cache is valid"
    else
        fail "Fresh cache incorrectly marked as invalid"
    fi
}

# Test 7: Cache validity check - stale cache
test_cache_validity_stale() {
    print_test "Cache validity - stale cache"

    # Modify cache timestamp to make it stale
    local old_timestamp=$(($(date +%s) - 90000))  # 25 hours ago

    # Create a stale cache by modifying the timestamp
    sed -i.bak "s/^# Built: .*/# Built: $old_timestamp/" "${HOME}/.goto_index"

    if ! __goto_cache_is_valid; then
        pass "Stale cache correctly identified"
    else
        fail "Stale cache incorrectly marked as valid"
    fi

    # Restore fresh cache
    mv "${HOME}/.goto_index.bak" "${HOME}/.goto_index"
}

# Test 8: Cache status command
test_cache_status() {
    print_test "Cache status command"

    local status_output
    status_output=$(__goto_cache_status 2>&1)

    if [[ "$status_output" == *"Cache Information"* ]] && [[ "$status_output" == *"Statistics"* ]]; then
        pass "Cache status output is complete"
    else
        fail "Cache status output is incomplete"
    fi
}

# Test 9: Cache clear command
test_cache_clear() {
    print_test "Cache clear command"

    __goto_cache_clear > /dev/null 2>&1

    if [ ! -f "${HOME}/.goto_index" ]; then
        pass "Cache cleared successfully"
    else
        fail "Cache not cleared"
    fi
}

# Test 10: Cache rebuild
test_cache_rebuild() {
    print_test "Cache rebuild"

    # Clear cache
    rm -f "${HOME}/.goto_index"

    # Rebuild
    __goto_cache_build > /dev/null 2>&1

    if [ -f "${HOME}/.goto_index" ]; then
        pass "Cache rebuilt successfully"
    else
        fail "Cache rebuild failed"
    fi
}

# Test 11: Cache performance - lookup speed
test_cache_performance() {
    print_test "Cache performance - lookup speed"

    # Ensure cache exists
    if [ ! -f "${HOME}/.goto_index" ]; then
        __goto_cache_build > /dev/null 2>&1
    fi

    # Measure lookup time (should be <100ms)
    local start_us=$(python3 -c "import time; print(int(time.time() * 1000000))" 2>/dev/null || echo "0")

    __goto_cache_lookup "proj1" > /dev/null 2>&1

    local end_us=$(python3 -c "import time; print(int(time.time() * 1000000))" 2>/dev/null || echo "0")
    local duration_ms=$(( (end_us - start_us) / 1000 ))

    if [ $duration_ms -lt 100 ]; then
        pass "Cache lookup is fast: ${duration_ms}ms (<100ms target)"
    else
        fail "Cache lookup is slow: ${duration_ms}ms (>100ms target)"
    fi
}

# Test 12: Cache auto-refresh
test_cache_auto_refresh() {
    print_test "Cache auto-refresh when stale"

    # Make cache stale
    local old_timestamp=$(($(date +%s) - 90000))
    sed -i.bak "s/^# Built: .*/# Built: $old_timestamp/" "${HOME}/.goto_index"

    # Call auto-refresh
    __goto_cache_auto_refresh > /dev/null 2>&1

    # Check if cache was refreshed (timestamp should be recent)
    local cache_time=$(grep "^# Built:" "${HOME}/.goto_index" | cut -d' ' -f3)
    local current_time=$(date +%s)
    local age=$((current_time - cache_time))

    if [ $age -lt 60 ]; then
        pass "Cache auto-refreshed successfully (age: ${age}s)"
    else
        fail "Cache not auto-refreshed (age: ${age}s)"
    fi
}

# Test 13: Integration with goto function
test_goto_integration() {
    print_test "Integration with goto function"

    # Source the goto function
    if [ -f "$SCRIPT_DIR/lib/goto-function.sh" ]; then
        source "$SCRIPT_DIR/lib/goto-function.sh"

        # Test that cache functions are available
        if command -v __goto_cache_lookup &> /dev/null; then
            pass "Cache functions available to goto"
        else
            fail "Cache functions not available to goto"
        fi
    else
        skip "goto-function.sh not found"
    fi
}

# Test 14: Edge case - empty cache
test_empty_cache() {
    print_test "Edge case - empty cache"

    # Create empty cache file
    echo "# unix-goto folder index cache" > "${HOME}/.goto_index"
    echo "# Version: 1.0" >> "${HOME}/.goto_index"
    echo "# Built: $(date +%s)" >> "${HOME}/.goto_index"
    echo "#---" >> "${HOME}/.goto_index"

    local result
    result=$(__goto_cache_lookup "proj1" 2>/dev/null)
    local status=$?

    if [ $status -eq 1 ]; then
        pass "Empty cache returns not found"
    else
        fail "Empty cache handling incorrect"
    fi
}

# Test 15: Edge case - corrupted cache
test_corrupted_cache() {
    print_test "Edge case - corrupted cache"

    # Create corrupted cache
    echo "CORRUPTED DATA" > "${HOME}/.goto_index"

    # Should detect as invalid
    if ! __goto_cache_is_valid; then
        pass "Corrupted cache detected as invalid"
    else
        fail "Corrupted cache not detected"
    fi
}

# Test 16: Deep nesting support
test_deep_nesting() {
    print_test "Deep nesting support"

    # Rebuild cache with depth
    GOTO_SEARCH_DEPTH=5 __goto_cache_build > /dev/null 2>&1

    # Look for deeply nested folder
    local result
    result=$(__goto_cache_lookup "folder" 2>/dev/null)

    if [[ "$result" == *"deep/nested/folder"* ]]; then
        pass "Deep nested folders indexed correctly"
    else
        fail "Deep nested folders not found"
    fi
}

# Test 17: Performance comparison
test_performance_comparison() {
    print_test "Performance comparison - cached vs uncached"

    echo ""
    echo "Measuring performance improvements..."

    # Uncached search (using find)
    local start_uncached=$(python3 -c "import time; print(int(time.time() * 1000000))" 2>/dev/null || echo "0")
    /usr/bin/find "$TEST_WORKSPACE" -maxdepth 3 -type d -name "proj1" > /dev/null 2>&1
    local end_uncached=$(python3 -c "import time; print(int(time.time() * 1000000))" 2>/dev/null || echo "0")
    local uncached_ms=$(( (end_uncached - start_uncached) / 1000 ))

    # Cached search
    local start_cached=$(python3 -c "import time; print(int(time.time() * 1000000))" 2>/dev/null || echo "0")
    __goto_cache_lookup "proj1" > /dev/null 2>&1
    local end_cached=$(python3 -c "import time; print(int(time.time() * 1000000))" 2>/dev/null || echo "0")
    local cached_ms=$(( (end_cached - start_cached) / 1000 ))

    echo "  Uncached (find):    ${uncached_ms}ms"
    echo "  Cached (lookup):    ${cached_ms}ms"

    if [ $cached_ms -gt 0 ]; then
        local speedup=$((uncached_ms / cached_ms))
        echo "  Speedup:            ${speedup}x"

        if [ $speedup -ge 10 ]; then
            pass "Cache provides significant speedup (${speedup}x)"
        else
            fail "Cache speedup below expectations (${speedup}x, target: 20-50x)"
        fi
    else
        skip "Cache lookup too fast to measure accurately"
    fi
}

# Main test runner
main() {
    print_header "unix-goto Cache Index System Tests (CET-77)"

    echo "Test Environment:"
    echo "  Script directory: $SCRIPT_DIR"
    echo "  Test workspace:   $TEST_WORKSPACE"
    echo "  Cache file:       ${HOME}/.goto_index"
    echo ""

    # Setup
    backup_existing_cache
    setup_test_workspace
    source_cache_functions

    # Run all tests
    print_header "Running Tests"

    test_cache_creation
    test_cache_format
    test_cache_lookup_exact
    test_cache_lookup_not_found
    test_cache_lookup_multiple
    test_cache_validity_fresh
    test_cache_validity_stale
    test_cache_status
    test_cache_clear
    test_cache_rebuild
    test_cache_performance
    test_cache_auto_refresh
    test_goto_integration
    test_empty_cache
    test_corrupted_cache
    test_deep_nesting
    test_performance_comparison

    # Cleanup
    cleanup_test_workspace

    # Summary
    print_header "Test Summary"

    echo "Total tests:    $TESTS_TOTAL"
    echo -e "${GREEN}Passed:         $TESTS_PASSED${NC}"
    echo -e "${RED}Failed:         $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        exit 0
    else
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        exit 1
    fi
}

# Run tests
main "$@"
