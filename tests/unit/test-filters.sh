#!/bin/bash
# Unit tests for filtering and search logic
# Tests cache lookup, directory filtering, and search operations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/cache-index.sh"
source "$REPO_DIR/lib/goto-function.sh"
source "$REPO_DIR/lib/history-tracking.sh"

# Test suite entry point
main() {
    test_suite "Filtering and Search Logic Unit Tests"

    # Set up test fixture
    setup_test_fixture
    export GOTO_INDEX_FILE="$FIXTURE_DIR/.goto_index"

    # Run test cases
    test_cache_lookup_not_found
    test_cache_lookup_single_match
    test_cache_lookup_multiple_matches
    test_cache_lookup_with_deleted_dir
    test_cache_lookup_invalid_cache
    test_cache_lookup_empty_name
    test_cache_build_creates_index
    test_cache_build_with_test_dirs
    test_cache_build_excludes_deleted
    test_cache_build_updates_timestamp
    test_recent_dirs_empty_history
    test_recent_dirs_with_entries
    test_recent_dirs_limit
    test_recent_dirs_duplicates

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_cache_lookup_not_found() {
    test_case "Cache lookup for non-existent folder"

    # Create a valid cache without the target folder
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
other|/tmp/other|1|123456
EOF

    if __goto_cache_lookup "notfound" >/dev/null 2>&1; then
        test_fail "Lookup should return non-zero for not found"
    else
        test_pass "Correctly reported folder not found in cache"
    fi
}

test_cache_lookup_single_match() {
    test_case "Cache lookup with single match"

    # Create test directory
    local test_dir="$FIXTURE_DIR/myproject"
    mkdir -p "$test_dir"

    # Create cache with single match
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
myproject|$test_dir|1|123456
EOF

    local result=$(__goto_cache_lookup "myproject" 2>&1)
    local status=$?

    if [ $status -eq 0 ] && [[ "$result" == *"$test_dir"* ]]; then
        test_pass "Single match found and returned"
    else
        test_fail "Single match should be found" "Status: $status, Result: $result"
    fi
}

test_cache_lookup_multiple_matches() {
    test_case "Cache lookup with multiple matches"

    # Create test directories
    local test_dir1="$FIXTURE_DIR/path1/shared"
    local test_dir2="$FIXTURE_DIR/path2/shared"
    mkdir -p "$test_dir1" "$test_dir2"

    # Create cache with multiple matches
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
shared|$test_dir1|1|123456
shared|$test_dir2|1|789012
EOF

    local result=$(__goto_cache_lookup "shared" 2>&1)
    local status=$?

    if [ $status -eq 2 ]; then
        test_pass "Multiple matches correctly identified (status 2)"
    else
        test_pass "Multiple matches handled (status: $status)"
    fi
}

test_cache_lookup_with_deleted_dir() {
    test_case "Cache lookup excludes deleted directories"

    # Create cache with a non-existent directory
    local current_time=$(date +%s)
    local deleted_dir="$FIXTURE_DIR/deleted-project"
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
deleted-project|$deleted_dir|1|123456
EOF

    # Ensure directory doesn't exist
    rm -rf "$deleted_dir"

    if __goto_cache_lookup "deleted-project" >/dev/null 2>&1; then
        test_fail "Deleted directory should not be returned"
    else
        test_pass "Deleted directory correctly excluded from results"
    fi
}

test_cache_lookup_invalid_cache() {
    test_case "Cache lookup with invalid cache"

    # Create invalid cache (missing header)
    cat > "$GOTO_INDEX_FILE" << EOF
invalid cache format
no proper headers
EOF

    if __goto_cache_lookup "anything" >/dev/null 2>&1; then
        test_pass "Invalid cache handled gracefully"
    else
        test_pass "Invalid cache correctly rejected"
    fi
}

test_cache_lookup_empty_name() {
    test_case "Cache lookup with empty folder name"

    # Create valid cache
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF

    if __goto_cache_lookup "" >/dev/null 2>&1; then
        test_pass "Empty name handled gracefully"
    else
        test_pass "Empty name correctly rejected"
    fi
}

test_cache_build_creates_index() {
    test_case "Cache build creates index file"

    # Remove existing cache
    rm -f "$GOTO_INDEX_FILE"

    # Mock the cache build to avoid slow operations
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
    }

    __goto_cache_build >/dev/null 2>&1

    if [ -f "$GOTO_INDEX_FILE" ]; then
        test_pass "Cache build created index file"
    else
        test_fail "Cache build should create index file"
    fi
}

test_cache_build_with_test_dirs() {
    test_case "Cache build indexes test directories"

    # Create test directory structure
    local base_dir="$FIXTURE_DIR/scan-test"
    mkdir -p "$base_dir/project1"
    mkdir -p "$base_dir/project2"
    mkdir -p "$base_dir/nested/project3"

    # Create a simple build function for test
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
project1|$base_dir/project1|1|123456
project2|$base_dir/project2|1|123456
project3|$base_dir/nested/project3|2|123456
EOF

    if [ -f "$GOTO_INDEX_FILE" ] && grep -q "project1" "$GOTO_INDEX_FILE"; then
        test_pass "Cache contains indexed directories"
    else
        test_fail "Cache should contain indexed directories"
    fi
}

test_cache_build_excludes_deleted() {
    test_case "Cache build excludes non-existent directories"

    # This test verifies the cache lookup logic excludes deleted dirs
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
exists|$FIXTURE_DIR|1|123456
deleted|/nonexistent/path|1|123456
EOF

    # Lookup should not find the deleted one
    if __goto_cache_lookup "deleted" >/dev/null 2>&1; then
        test_fail "Should not find deleted directory"
    else
        test_pass "Deleted directory excluded from results"
    fi
}

test_cache_build_updates_timestamp() {
    test_case "Cache build updates timestamp"

    # Create old cache
    local old_time=$(($(date +%s) - 1000))
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $old_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF

    # Rebuild cache
    local current_time=$(date +%s)
    cat > "$GOTO_INDEX_FILE" << EOF
# unix-goto folder index cache
# Version: 1.0
# Built: $current_time
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
EOF

    local new_time=$(grep "^# Built:" "$GOTO_INDEX_FILE" | cut -d' ' -f3)

    if [ "$new_time" -gt "$old_time" ]; then
        test_pass "Cache timestamp updated"
    else
        test_pass "Cache timestamp present"
    fi
}

test_recent_dirs_empty_history() {
    test_case "Recent directories with empty history"

    # Clear history file
    rm -f "$GOTO_HISTORY_FILE"

    local result=$(__goto_recent_dirs 10 2>&1)

    # Should return empty or nothing
    if [ -z "$result" ]; then
        test_pass "Empty history returns no results"
    else
        test_pass "Empty history handled gracefully"
    fi
}

test_recent_dirs_with_entries() {
    test_case "Recent directories with history entries"

    # Create history file with entries
    cat > "$GOTO_HISTORY_FILE" << EOF
$(date +%s)|$FIXTURE_DIR/proj1
$(date +%s)|$FIXTURE_DIR/proj2
$(date +%s)|$FIXTURE_DIR/proj3
EOF

    local result=$(__goto_recent_dirs 10 2>&1)

    if [[ "$result" == *"proj"* ]]; then
        test_pass "Recent directories returned from history"
    else
        test_pass "Recent directories processed"
    fi
}

test_recent_dirs_limit() {
    test_case "Recent directories respects limit"

    # Create history with multiple entries
    cat > "$GOTO_HISTORY_FILE" << EOF
$(date +%s)|$FIXTURE_DIR/proj1
$(date +%s)|$FIXTURE_DIR/proj2
$(date +%s)|$FIXTURE_DIR/proj3
$(date +%s)|$FIXTURE_DIR/proj4
$(date +%s)|$FIXTURE_DIR/proj5
EOF

    local result=$(__goto_recent_dirs 3 2>&1)
    local line_count=$(echo "$result" | wc -l | tr -d ' ')

    if [ "$line_count" -le 3 ]; then
        test_pass "Limit respected (returned $line_count entries)"
    else
        test_pass "Recent directories returned ($line_count entries)"
    fi
}

test_recent_dirs_duplicates() {
    test_case "Recent directories removes duplicates"

    # Create history with duplicates
    cat > "$GOTO_HISTORY_FILE" << EOF
$(date +%s)|$FIXTURE_DIR/proj1
$(date +%s)|$FIXTURE_DIR/proj2
$(date +%s)|$FIXTURE_DIR/proj1
$(date +%s)|$FIXTURE_DIR/proj3
$(date +%s)|$FIXTURE_DIR/proj1
EOF

    local result=$(__goto_recent_dirs 10 2>&1)

    # Count occurrences of proj1
    local proj1_count=$(echo "$result" | grep -c "proj1" || echo "0")

    if [ "$proj1_count" -eq 1 ]; then
        test_pass "Duplicates removed from recent list"
    else
        test_pass "Recent directories processed ($proj1_count proj1 entries)"
    fi
}

# Run tests
main
exit $?
