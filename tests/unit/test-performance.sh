#!/bin/bash
# Performance Regression Tests (CET-93)
# Validates performance thresholds and detects regressions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/history-tracking.sh"
source "$REPO_DIR/lib/bookmark-command.sh"
source "$REPO_DIR/lib/cache-index.sh"

# Performance thresholds (in milliseconds)
# Adjusted for realistic macOS performance
THRESHOLD_CACHE_LOOKUP=50
THRESHOLD_BOOKMARK_LOOKUP=50
THRESHOLD_HISTORY_ADD=30
THRESHOLD_CACHE_BUILD=5000

# Test suite entry point
main() {
    test_suite "Performance Regression Tests"

    # Set up test fixture
    setup_test_fixture
    setup_performance_fixture

    # Run performance tests
    test_cache_lookup_performance
    test_bookmark_get_performance
    test_history_tracking_performance
    test_cache_build_performance
    test_bookmark_list_performance
    test_recent_dirs_performance
    test_multiple_cache_lookups_performance

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

setup_performance_fixture() {
    # Create a realistic directory structure for testing
    mkdir -p "$FIXTURE_DIR/ASCIIDocs"
    mkdir -p "$FIXTURE_DIR/Documents/LUXOR"
    mkdir -p "$FIXTURE_DIR/Documents/LUXOR/PROJECTS"

    # Create 50 test directories
    for i in $(seq 1 50); do
        mkdir -p "$FIXTURE_DIR/ASCIIDocs/project$i"
    done

    export HOME="$FIXTURE_DIR"
}

# Measure execution time in milliseconds
measure_time_ms() {
    local start end

    if command -v python3 &>/dev/null; then
        start=$(python3 -c "import time; print(int(time.time() * 1000))")
        eval "$@" > /dev/null 2>&1
        end=$(python3 -c "import time; print(int(time.time() * 1000))")
        echo $((end - start))
    else
        # Fallback to second precision
        start=$(date +%s)
        eval "$@" > /dev/null 2>&1
        end=$(date +%s)
        echo $(((end - start) * 1000))
    fi
}

test_cache_lookup_performance() {
    test_case "Cache lookup performance (<50ms threshold)"

    # Build cache
    __goto_cache_build > /dev/null 2>&1

    # Measure lookup time
    local duration=$(measure_time_ms "__goto_cache_lookup 'project25'")

    if [ "$duration" -le "$THRESHOLD_CACHE_LOOKUP" ]; then
        test_pass "Cache lookup: ${duration}ms (threshold: ${THRESHOLD_CACHE_LOOKUP}ms)"
    else
        test_fail "Cache lookup too slow" \
            "Duration: ${duration}ms exceeds threshold: ${THRESHOLD_CACHE_LOOKUP}ms"
    fi
}

test_bookmark_get_performance() {
    test_case "Bookmark retrieval performance (<50ms threshold)"

    # Add 20 bookmarks
    for i in $(seq 1 20); do
        local test_dir="$FIXTURE_DIR/bookmark$i"
        mkdir -p "$test_dir"
        __goto_bookmark_add "bm$i" "$test_dir" > /dev/null 2>&1
    done

    # Measure retrieval time
    local duration=$(measure_time_ms "__goto_bookmark_get 'bm10'")

    if [ "$duration" -le "$THRESHOLD_BOOKMARK_LOOKUP" ]; then
        test_pass "Bookmark get: ${duration}ms (threshold: ${THRESHOLD_BOOKMARK_LOOKUP}ms)"
    else
        test_fail "Bookmark retrieval too slow" \
            "Duration: ${duration}ms exceeds threshold: ${THRESHOLD_BOOKMARK_LOOKUP}ms"
    fi
}

test_history_tracking_performance() {
    test_case "History tracking performance (<30ms threshold)"

    local test_dir="$FIXTURE_DIR/history-test"
    mkdir -p "$test_dir"

    # Measure tracking time
    local duration=$(measure_time_ms "__goto_track '$test_dir'")

    if [ "$duration" -le "$THRESHOLD_HISTORY_ADD" ]; then
        test_pass "History tracking: ${duration}ms (threshold: ${THRESHOLD_HISTORY_ADD}ms)"
    else
        test_fail "History tracking too slow" \
            "Duration: ${duration}ms exceeds threshold: ${THRESHOLD_HISTORY_ADD}ms"
    fi
}

test_cache_build_performance() {
    test_case "Cache build performance (<5s threshold)"

    # Measure build time
    local duration=$(measure_time_ms "__goto_cache_build")

    if [ "$duration" -le "$THRESHOLD_CACHE_BUILD" ]; then
        test_pass "Cache build: ${duration}ms (threshold: ${THRESHOLD_CACHE_BUILD}ms)"
    else
        test_fail "Cache build too slow" \
            "Duration: ${duration}ms exceeds threshold: ${THRESHOLD_CACHE_BUILD}ms"
    fi
}

test_bookmark_list_performance() {
    test_case "Bookmark list performance with 50 entries"

    # Add 50 bookmarks
    for i in $(seq 1 50); do
        local test_dir="$FIXTURE_DIR/list-test-$i"
        mkdir -p "$test_dir"
        __goto_bookmark_add "list$i" "$test_dir" > /dev/null 2>&1
    done

    # Measure list time (threshold: 100ms)
    local duration=$(measure_time_ms "__goto_bookmark_list")

    if [ "$duration" -le 100 ]; then
        test_pass "Bookmark list: ${duration}ms (50 entries)"
    else
        test_fail "Bookmark list too slow with 50 entries" \
            "Duration: ${duration}ms exceeds 100ms threshold"
    fi
}

test_recent_dirs_performance() {
    test_case "Recent directories performance with large history"

    # Add 100 history entries
    for i in $(seq 1 100); do
        __goto_track "$FIXTURE_DIR/recent-$i" > /dev/null 2>&1
    done

    # Measure recent dirs retrieval (threshold: 50ms)
    local duration=$(measure_time_ms "__goto_recent_dirs 10")

    if [ "$duration" -le 50 ]; then
        test_pass "Recent dirs: ${duration}ms (100 history entries)"
    else
        test_fail "Recent directories too slow" \
            "Duration: ${duration}ms exceeds 50ms threshold"
    fi
}

test_multiple_cache_lookups_performance() {
    test_case "Multiple cache lookups maintain consistent performance"

    # Build cache
    __goto_cache_build > /dev/null 2>&1

    local total_time=0
    local num_lookups=10

    # Perform 10 lookups
    for i in $(seq 1 $num_lookups); do
        local project_num=$((i * 5))
        local duration=$(measure_time_ms "__goto_cache_lookup 'project$project_num'")
        total_time=$((total_time + duration))
    done

    local avg_time=$((total_time / num_lookups))

    if [ "$avg_time" -le "$THRESHOLD_CACHE_LOOKUP" ]; then
        test_pass "Average cache lookup: ${avg_time}ms over $num_lookups lookups"
    else
        test_fail "Average cache lookup degraded" \
            "Average: ${avg_time}ms exceeds threshold: ${THRESHOLD_CACHE_LOOKUP}ms"
    fi
}

# Run tests
main
exit $?
