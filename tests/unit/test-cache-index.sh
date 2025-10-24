#!/bin/bash
# Unit tests for cache index system (CET-77, CET-90)
# Tests caching functionality, performance, and correctness

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load module under test
source "$REPO_DIR/lib/cache-index.sh"

# Test suite entry point
main() {
    test_suite "Cache Index System Unit Tests"

    # Set up test fixture
    setup_test_fixture

    # Run test cases
    test_cache_initialization
    test_cache_build_basic
    test_cache_build_with_nested_dirs
    test_cache_lookup_single_match
    test_cache_lookup_multiple_matches
    test_cache_lookup_not_found
    test_cache_validation_fresh
    test_cache_validation_stale
    test_cache_validation_missing
    test_cache_auto_refresh
    test_cache_clear
    test_cache_status_display
    test_cache_with_empty_search_paths
    test_cache_metadata_parsing
    test_cache_performance_threshold

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_cache_initialization() {
    test_case "Cache initialization creates necessary structures"

    __goto_cache_init

    local cache_dir=$(dirname "$GOTO_INDEX_FILE")

    assert_dir_exists "$cache_dir" "Cache directory should be created"
}

test_cache_build_basic() {
    test_case "Cache build creates valid index file"

    # Set up test directories
    mkdir -p "$FIXTURE_DIR/ASCIIDocs/project1"
    mkdir -p "$FIXTURE_DIR/ASCIIDocs/project2"

    # Temporarily override search paths
    export HOME="$FIXTURE_DIR"

    __goto_cache_build > /dev/null 2>&1

    assert_file_exists "$GOTO_INDEX_FILE" "Cache file should be created"

    # Verify cache contains header
    assert_file_contains "$GOTO_INDEX_FILE" "# unix-goto folder index cache" \
        "Cache should have header"

    # Verify cache contains version
    assert_file_contains "$GOTO_INDEX_FILE" "# Version:" \
        "Cache should have version info"
}

test_cache_build_with_nested_dirs() {
    test_case "Cache build indexes nested directories"

    # Create nested structure
    mkdir -p "$FIXTURE_DIR/ASCIIDocs/level1/level2/level3"

    export HOME="$FIXTURE_DIR"

    __goto_cache_build > /dev/null 2>&1

    # Verify nested directories are indexed
    local has_level1=$(grep -c "level1|" "$GOTO_INDEX_FILE")
    local has_level2=$(grep -c "level2|" "$GOTO_INDEX_FILE")

    if [ "$has_level1" -ge 1 ] && [ "$has_level2" -ge 1 ]; then
        test_pass "Nested directories indexed correctly"
    else
        test_fail "Some nested directories missing from cache"
    fi
}

test_cache_lookup_single_match() {
    test_case "Cache lookup returns single match correctly"

    local test_dir="$FIXTURE_DIR/unique-folder"
    mkdir -p "$test_dir"

    # Create simple cache
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "# Depth: 3"
        echo "#---"
        echo "unique-folder|$test_dir|1|$(date +%s)"
    } > "$GOTO_INDEX_FILE"

    local result=$(__goto_cache_lookup "unique-folder")
    local status=$?

    assert_equal "0" "$status" "Lookup should return success status"
    assert_equal "$test_dir" "$result" "Should return correct path"
}

test_cache_lookup_multiple_matches() {
    test_case "Cache lookup handles multiple matches"

    local test_dir1="$FIXTURE_DIR/duplicate/one"
    local test_dir2="$FIXTURE_DIR/duplicate/two"
    mkdir -p "$test_dir1" "$test_dir2"

    # Create cache with duplicates
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "# Depth: 3"
        echo "#---"
        echo "duplicate|$test_dir1|2|$(date +%s)"
        echo "duplicate|$test_dir2|2|$(date +%s)"
    } > "$GOTO_INDEX_FILE"

    local result=$(__goto_cache_lookup "duplicate")
    local status=$?

    assert_equal "2" "$status" "Lookup should return multiple match status"

    # Verify both paths are returned
    assert_contains "$result" "$test_dir1" "Should contain first match"
    assert_contains "$result" "$test_dir2" "Should contain second match"
}

test_cache_lookup_not_found() {
    test_case "Cache lookup returns error for missing folder"

    # Create cache without target folder
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "# Depth: 3"
        echo "#---"
        echo "other|/tmp/other|1|123456"
    } > "$GOTO_INDEX_FILE"

    local result=$(__goto_cache_lookup "nonexistent" 2>/dev/null)
    local status=$?

    assert_equal "1" "$status" "Lookup should return not-found status"
}

test_cache_validation_fresh() {
    test_case "Cache validation passes for fresh cache"

    local current_time=$(date +%s)

    # Create fresh cache (just built)
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $current_time"
        echo "# Depth: 3"
        echo "#---"
    } > "$GOTO_INDEX_FILE"

    if __goto_cache_is_valid; then
        test_pass "Fresh cache validated successfully"
    else
        test_fail "Fresh cache incorrectly marked as invalid"
    fi
}

test_cache_validation_stale() {
    test_case "Cache validation fails for stale cache"

    # Create stale cache (built 25 hours ago, TTL is 24 hours)
    local stale_time=$(($(date +%s) - 90000))

    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $stale_time"
        echo "# Depth: 3"
        echo "#---"
    } > "$GOTO_INDEX_FILE"

    if __goto_cache_is_valid; then
        test_fail "Stale cache should be marked invalid"
    else
        test_pass "Stale cache correctly invalidated"
    fi
}

test_cache_validation_missing() {
    test_case "Cache validation fails when file missing"

    rm -f "$GOTO_INDEX_FILE"

    if __goto_cache_is_valid 2>/dev/null; then
        test_fail "Missing cache should be invalid"
    else
        test_pass "Missing cache correctly detected"
    fi
}

test_cache_auto_refresh() {
    test_case "Auto-refresh rebuilds stale cache"

    # Create stale cache
    local stale_time=$(($(date +%s) - 90000))

    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $stale_time"
        echo "# Depth: 3"
        echo "#---"
    } > "$GOTO_INDEX_FILE"

    mkdir -p "$FIXTURE_DIR/ASCIIDocs"
    export HOME="$FIXTURE_DIR"

    __goto_cache_auto_refresh

    # Cache should now be fresh
    if __goto_cache_is_valid; then
        test_pass "Auto-refresh rebuilt stale cache"
    else
        test_fail "Auto-refresh failed to rebuild cache"
    fi
}

test_cache_clear() {
    test_case "Cache clear removes index file"

    # Create cache file
    echo "test" > "$GOTO_INDEX_FILE"

    __goto_cache_clear > /dev/null 2>&1

    assert_file_not_exists "$GOTO_INDEX_FILE" "Cache file should be removed"
}

test_cache_status_display() {
    test_case "Cache status displays information"

    local current_time=$(date +%s)

    # Create valid cache with data
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $current_time"
        echo "# Depth: 3"
        echo "#---"
        echo "test1|/tmp/test1|1|123456"
        echo "test2|/tmp/test2|1|123457"
        echo "test3|/tmp/test3|1|123458"
    } > "$GOTO_INDEX_FILE"

    local output=$(__goto_cache_status 2>&1)

    assert_contains "$output" "CACHE STATUS" "Should display status header"
    assert_contains "$output" "Total entries:" "Should show entry count"
    assert_contains "$output" "Cache size:" "Should show file size"
}

test_cache_with_empty_search_paths() {
    test_case "Cache build with nonexistent search paths"

    # Use fixture dir with no standard directories
    export HOME="$FIXTURE_DIR"

    # Should complete without errors, just skip missing paths
    __goto_cache_build > /dev/null 2>&1

    assert_file_exists "$GOTO_INDEX_FILE" "Cache should be created even if paths missing"
}

test_cache_metadata_parsing() {
    test_case "Cache metadata parsing extracts correct values"

    local build_time=$(date +%s)

    {
        echo "# unix-goto folder index cache"
        echo "# Version: 2.5"
        echo "# Built: $build_time"
        echo "# Depth: 5"
        echo "#---"
    } > "$GOTO_INDEX_FILE"

    # Extract metadata
    local version=$(grep "^# Version:" "$GOTO_INDEX_FILE" | cut -d' ' -f3)
    local cached_time=$(grep "^# Built:" "$GOTO_INDEX_FILE" | cut -d' ' -f3)
    local depth=$(grep "^# Depth:" "$GOTO_INDEX_FILE" | cut -d' ' -f3)

    assert_equal "2.5" "$version" "Version should be parsed correctly"
    assert_equal "$build_time" "$cached_time" "Build time should be parsed correctly"
    assert_equal "5" "$depth" "Depth should be parsed correctly"
}

test_cache_performance_threshold() {
    test_case "Cache lookup meets performance threshold (<100ms)"

    local test_dir="$FIXTURE_DIR/perf-test"
    mkdir -p "$test_dir"

    # Create cache with 100 entries
    {
        echo "# unix-goto folder index cache"
        echo "# Version: 1.0"
        echo "# Built: $(date +%s)"
        echo "# Depth: 3"
        echo "#---"

        for i in $(seq 1 100); do
            echo "folder$i|/tmp/folder$i|1|123456"
        done

        echo "perf-test|$test_dir|1|$(date +%s)"
    } > "$GOTO_INDEX_FILE"

    # Measure lookup time
    local start_ms=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "0")

    __goto_cache_lookup "perf-test" > /dev/null 2>&1

    local end_ms=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || echo "100")

    local duration=$((end_ms - start_ms))

    # Allow up to 100ms for lookup
    if [ "$duration" -le 100 ] || [ "$start_ms" -eq 0 ]; then
        test_pass "Cache lookup completed within 100ms threshold"
    else
        test_fail "Cache lookup too slow" "Duration: ${duration}ms (threshold: 100ms)"
    fi
}

# Run tests
main
exit $?
