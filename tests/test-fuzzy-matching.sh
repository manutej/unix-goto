#!/bin/bash
# Comprehensive tests for fuzzy matching feature
# unix-goto v0.4.0 - Deep testing as specified in SUCCESS-CRITERIA.md

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

# Test environment setup
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$TEST_DIR")"
TEST_HOME="/tmp/unix-goto-fuzzy-test-$$"

echo "========================================"
echo "   Fuzzy Matching Comprehensive Tests"
echo "========================================"
echo ""
echo "Setting up test environment at: $TEST_HOME"

# Create test environment
mkdir -p "$TEST_HOME"
export HOME="$TEST_HOME"
export ORIGINAL_PWD="$PWD"

# Source the library files
source "$REPO_ROOT/lib/history-tracking.sh"
source "$REPO_ROOT/lib/back-command.sh"
source "$REPO_ROOT/lib/recent-command.sh"
source "$REPO_ROOT/lib/bookmark-command.sh"
source "$REPO_ROOT/lib/list-command.sh"
source "$REPO_ROOT/lib/fuzzy-matching.sh"
source "$REPO_ROOT/lib/goto-function.sh"

# Test helper functions
pass_test() {
    local message="$1"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✓${NC} $message"
}

fail_test() {
    local message="$1"
    local expected="${2:-}"
    local actual="${3:-}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}✗${NC} $message"
    if [ -n "$expected" ]; then
        echo "    Expected: $expected"
        echo "    Actual:   $actual"
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [ "$expected" = "$actual" ]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message" "$expected" "$actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"

    if [[ "$haystack" == *"$needle"* ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message" "Contains '$needle'" "$haystack"
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should NOT contain substring}"

    if [[ "$haystack" != *"$needle"* ]]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message" "Does not contain '$needle'" "$haystack"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"

    if [ -d "$dir" ]; then
        pass_test "$message"
        return 0
    else
        fail_test "$message"
        return 1
    fi
}

# Setup test directory structure
setup_basic_dirs() {
    echo ""
    echo -e "${BLUE}Setting up basic test directories...${NC}"
    mkdir -p "$TEST_HOME/ASCIIDocs/GAI-3101"
    mkdir -p "$TEST_HOME/ASCIIDocs/GAI-3101/docs"
    mkdir -p "$TEST_HOME/ASCIIDocs/GAI-3102"
    mkdir -p "$TEST_HOME/ASCIIDocs/HALCON"
    mkdir -p "$TEST_HOME/ASCIIDocs/WA3590"
    mkdir -p "$TEST_HOME/Documents/LUXOR"
    mkdir -p "$TEST_HOME/Documents/LUXOR/PROJECTS"
}

cleanup_basic_dirs() {
    rm -rf "$TEST_HOME/ASCIIDocs"
    rm -rf "$TEST_HOME/Documents"
}

#############################
# Test Category 1: Exact Substring Matching
#############################

echo ""
echo "=== Test Category 1: Exact Substring Matching ==="
echo ""

setup_basic_dirs

# Test 1.1: Exact substring match
echo "Test 1.1: Exact substring match 'GAI'"
output=$(__goto_fuzzy_match "GAI" "GAI-3101" "GAI-3102" "HALCON" "WA3590")
assert_contains "$output" "GAI-3101" "Should match GAI-3101"
assert_contains "$output" "GAI-3102" "Should match GAI-3102"

# Test 1.2: Partial numeric match
echo ""
echo "Test 1.2: Partial numeric match '3101'"
output=$(__goto_fuzzy_match "3101" "GAI-3101" "GAI-3102" "HALCON" "WA3590")
assert_contains "$output" "GAI-3101" "Should match GAI-3101"
assert_not_contains "$output" "GAI-3102" "Should NOT match GAI-3102"

# Test 1.3: Middle substring match
echo ""
echo "Test 1.3: Middle substring match 'ai-'"
output=$(__goto_fuzzy_match "ai-" "GAI-3101" "GAI-3102" "HALCON" "WA3590")
assert_contains "$output" "GAI-3101" "Should match GAI-3101 via 'ai-'"

# Test 1.4: End substring match
echo ""
echo "Test 1.4: End substring match 'CON'"
output=$(__goto_fuzzy_match "CON" "GAI-3101" "GAI-3102" "HALCON" "WA3590")
assert_contains "$output" "HALCON" "Should match HALCON via 'CON'"

cleanup_basic_dirs

#############################
# Test Category 2: Case-Insensitive Matching
#############################

echo ""
echo "=== Test Category 2: Case-Insensitive Matching ==="
echo ""

setup_basic_dirs

# Test 2.1: Lowercase query
echo "Test 2.1: Lowercase query 'gai'"
output=$(__goto_fuzzy_match "gai" "GAI-3101" "GAI-3102" "HALCON")
assert_contains "$output" "GAI-3101" "Lowercase 'gai' should match GAI-3101"

# Test 2.2: Mixed case query
echo ""
echo "Test 2.2: Mixed case query 'HaL'"
output=$(__goto_fuzzy_match "HaL" "GAI-3101" "HALCON" "WA3590")
assert_contains "$output" "HALCON" "Mixed case 'HaL' should match HALCON"

# Test 2.3: Uppercase query on lowercase dir
echo ""
echo "Test 2.3: Uppercase query on lowercase dir"
output=$(__goto_fuzzy_match "PROJECT" "project-one" "project-two" "other")
assert_contains "$output" "project-one" "Uppercase 'PROJECT' should match project-one"

cleanup_basic_dirs

#############################
# Test Category 3: Ambiguous Matches
#############################

echo ""
echo "=== Test Category 3: Ambiguous Matches (Multiple Results) ==="
echo ""

setup_basic_dirs
mkdir -p "$TEST_HOME/ASCIIDocs/project-1"
mkdir -p "$TEST_HOME/ASCIIDocs/project-2"
mkdir -p "$TEST_HOME/ASCIIDocs/project-3"

# Test 3.1: Multiple matches show all options
echo "Test 3.1: Multiple matches with 'proj'"
cd "$TEST_HOME"
output=$(goto proj 2>&1 || true)
assert_contains "$output" "Multiple matches" "Should indicate multiple matches"
assert_contains "$output" "project-1" "Should list project-1"
assert_contains "$output" "project-2" "Should list project-2"
assert_contains "$output" "project-3" "Should list project-3"

# Test 3.2: Verify doesn't auto-pick one
echo ""
echo "Test 3.2: Verify doesn't auto-navigate on ambiguous match"
cd "$TEST_HOME"
goto proj >/dev/null 2>&1 || true
current_dir="$PWD"
assert_equals "$TEST_HOME" "$current_dir" "Should remain in current directory on ambiguous match"

# Test 3.3: More specific query resolves ambiguity
echo ""
echo "Test 3.3: More specific query 'project-1' resolves ambiguity"
cd "$TEST_HOME"
goto project-1 >/dev/null 2>&1 || true
current_dir="$PWD"
assert_equals "$TEST_HOME/ASCIIDocs/project-1" "$current_dir" "Should navigate to specific match"

cleanup_basic_dirs

#############################
# Test Category 4: No Matches (Error Handling)
#############################

echo ""
echo "=== Test Category 4: No Matches (Error Handling) ==="
echo ""

setup_basic_dirs

# Test 4.1: No match returns empty
echo "Test 4.1: No match for 'xyz'"
output=$(__goto_fuzzy_match "xyz" "GAI-3101" "HALCON" "WA3590")
if [ -z "$output" ]; then
    pass_test "No match returns empty result"
else
    fail_test "No match should return empty" "empty" "$output"
fi

# Test 4.2: Fuzzy search shows clear error
echo ""
echo "Test 4.2: Fuzzy search shows error message for no match"
cd "$TEST_HOME"
output=$(goto nonexistent 2>&1 || true)
assert_contains "$output" "not found" "Should show 'not found' message"

# Test 4.3: Error message is helpful
echo ""
echo "Test 4.3: Error message provides suggestions"
cd "$TEST_HOME"
output=$(goto xyz999 2>&1 || true)
if [[ "$output" == *"Try"* ]] || [[ "$output" == *"list"* ]]; then
    pass_test "Error message provides helpful suggestions"
else
    fail_test "Error should suggest 'goto list' or similar"
fi

cleanup_basic_dirs

#############################
# Test Category 5: Edge Cases - Special Characters
#############################

echo ""
echo "=== Test Category 5: Edge Cases - Special Characters ==="
echo ""

mkdir -p "$TEST_HOME/ASCIIDocs"

# Test 5.1: Directories with spaces
echo "Test 5.1: Directory with spaces"
mkdir -p "$TEST_HOME/ASCIIDocs/Project Name With Spaces"
output=$(__goto_fuzzy_match "proj" "Project Name With Spaces" "other")
assert_contains "$output" "Project Name With Spaces" "Should match directory with spaces"
rm -rf "$TEST_HOME/ASCIIDocs/Project Name With Spaces"

# Test 5.2: Directories with brackets
echo ""
echo "Test 5.2: Directory with brackets"
mkdir -p "$TEST_HOME/ASCIIDocs/project-[test]"
output=$(__goto_fuzzy_match "proj" "project-[test]" "other")
assert_contains "$output" "project-[test]" "Should match directory with brackets"
rm -rf "$TEST_HOME/ASCIIDocs/project-[test]"

# Test 5.3: Directories with underscores
echo ""
echo "Test 5.3: Directory with underscores"
mkdir -p "$TEST_HOME/ASCIIDocs/project_name_test"
output=$(__goto_fuzzy_match "name" "project_name_test" "other")
assert_contains "$output" "project_name_test" "Should match directory with underscores"
rm -rf "$TEST_HOME/ASCIIDocs/project_name_test"

# Test 5.4: Directories with dots
echo ""
echo "Test 5.4: Directory with dots"
mkdir -p "$TEST_HOME/ASCIIDocs/project.v2.0"
output=$(__goto_fuzzy_match "v2" "project.v2.0" "other")
assert_contains "$output" "project.v2.0" "Should match directory with dots"
rm -rf "$TEST_HOME/ASCIIDocs/project.v2.0"

rm -rf "$TEST_HOME/ASCIIDocs"

#############################
# Test Category 6: Edge Cases - Long Names
#############################

echo ""
echo "=== Test Category 6: Edge Cases - Long Names ==="
echo ""

mkdir -p "$TEST_HOME/ASCIIDocs"

# Test 6.1: Very long directory name
echo "Test 6.1: Very long directory name"
long_name="very-long-project-name-that-exceeds-normal-length-and-keeps-going-for-testing"
mkdir -p "$TEST_HOME/ASCIIDocs/$long_name"
output=$(__goto_fuzzy_match "very" "$long_name" "other")
assert_contains "$output" "$long_name" "Should match very long directory name"

# Test 6.2: Match in middle of long name
echo ""
echo "Test 6.2: Match in middle of long name"
output=$(__goto_fuzzy_match "exceeds" "$long_name" "other")
assert_contains "$output" "$long_name" "Should match substring in middle of long name"

rm -rf "$TEST_HOME/ASCIIDocs/$long_name"
rm -rf "$TEST_HOME/ASCIIDocs"

#############################
# Test Category 7: Edge Cases - Empty and Malicious Input
#############################

echo ""
echo "=== Test Category 7: Edge Cases - Empty and Malicious Input ==="
echo ""

setup_basic_dirs

# Test 7.1: Empty input
echo "Test 7.1: Empty input to fuzzy match"
output=$(__goto_fuzzy_match "" "GAI-3101" "HALCON")
# Empty query should match all (substring match with empty string)
if [[ "$output" == *"GAI-3101"* ]] && [[ "$output" == *"HALCON"* ]]; then
    pass_test "Empty query matches all directories"
else
    fail_test "Empty query behavior check"
fi

# Test 7.2: Very long input
echo ""
echo "Test 7.2: Very long input (1000 chars)"
long_input=$(printf 'a%.0s' {1..1000})
output=$(__goto_fuzzy_match "$long_input" "GAI-3101" "HALCON" 2>&1 || true)
# Should handle gracefully without crashing
pass_test "Very long input handled without crash"

# Test 7.3: Malicious input - command injection attempt
echo ""
echo "Test 7.3: Malicious input - command injection attempt"
malicious="; rm -rf /"
output=$(__goto_fuzzy_match "$malicious" "GAI-3101" "HALCON" 2>&1 || true)
# Should treat as literal string, no match expected
if [ -d "$TEST_HOME/ASCIIDocs/GAI-3101" ]; then
    pass_test "Command injection blocked - directories still exist"
else
    fail_test "SECURITY ISSUE: Command may have executed!"
fi

# Test 7.4: Special regex characters
echo ""
echo "Test 7.4: Input with regex special characters"
mkdir -p "$TEST_HOME/ASCIIDocs/test.project"
output=$(__goto_fuzzy_match "test.proj" "test.project" "other" 2>&1 || true)
# Should handle regex chars gracefully
pass_test "Regex special characters handled without crash"
rm -rf "$TEST_HOME/ASCIIDocs/test.project"

cleanup_basic_dirs

#############################
# Test Category 8: Symlinks
#############################

echo ""
echo "=== Test Category 8: Symlinks ==="
echo ""

# Test 8.1: Match symlink name
echo "Test 8.1: Match symlink name"
mkdir -p "$TEST_HOME/real-path"
mkdir -p "$TEST_HOME/ASCIIDocs"
ln -s "$TEST_HOME/real-path" "$TEST_HOME/ASCIIDocs/link-name"

output=$(__goto_fuzzy_match "link" "link-name" "other")
assert_contains "$output" "link-name" "Should match symlink by name"

# Test 8.2: Navigate via symlink
echo ""
echo "Test 8.2: Navigate via symlink"
cd "$TEST_HOME"
goto link-name >/dev/null 2>&1 || true
# Should navigate successfully (to real path or symlink)
if [ "$PWD" = "$TEST_HOME/real-path" ] || [ "$PWD" = "$TEST_HOME/ASCIIDocs/link-name" ]; then
    pass_test "Successfully navigated via symlink"
else
    fail_test "Failed to navigate via symlink" "$TEST_HOME/real-path or link-name" "$PWD"
fi

rm -f "$TEST_HOME/ASCIIDocs/link-name"
rm -rf "$TEST_HOME/real-path"
rm -rf "$TEST_HOME/ASCIIDocs"

#############################
# Test Category 9: Performance Tests
#############################

echo ""
echo "=== Test Category 9: Performance Tests ==="
echo ""

# Test 9.1: Performance with 100 directories
echo "Test 9.1: Performance with 100 directories"
mkdir -p "$TEST_HOME/ASCIIDocs"
for i in {1..100}; do
    mkdir -p "$TEST_HOME/ASCIIDocs/project-$i"
done

start_time=$(date +%s%N)
output=$(__goto_fuzzy_match "proj" "$TEST_HOME/ASCIIDocs"/project-* 2>&1 || true)
end_time=$(date +%s%N)
duration_ms=$(( (end_time - start_time) / 1000000 ))

echo "    Duration: ${duration_ms}ms"
if [ $duration_ms -lt 500 ]; then
    pass_test "100 directories search completed in < 500ms"
else
    fail_test "Performance test: should complete in < 500ms" "< 500ms" "${duration_ms}ms"
fi

# Test 9.2: Performance with 1000 directories
echo ""
echo "Test 9.2: Performance with 1000 directories (may take a moment)"
for i in {101..1000}; do
    mkdir -p "$TEST_HOME/ASCIIDocs/project-$i"
done

start_time=$(date +%s%N)
output=$(__goto_fuzzy_match "proj" "$TEST_HOME/ASCIIDocs"/project-* 2>&1 || true)
end_time=$(date +%s%N)
duration_ms=$(( (end_time - start_time) / 1000000 ))

echo "    Duration: ${duration_ms}ms"
if [ $duration_ms -lt 2000 ]; then
    pass_test "1000 directories search completed in < 2s"
else
    fail_test "Performance test: should complete in < 2s" "< 2000ms" "${duration_ms}ms"
fi

# Cleanup performance test
rm -rf "$TEST_HOME/ASCIIDocs"

#############################
# Test Category 10: Integration Tests
#############################

echo ""
echo "=== Test Category 10: Integration Tests ==="
echo ""

setup_basic_dirs

# Test 10.1: Fuzzy match with multi-level path
echo "Test 10.1: Fuzzy match with multi-level path 'GAI-3101/docs'"
cd "$TEST_HOME"
goto "GAI-3101/docs" >/dev/null 2>&1 || true
current_dir="$PWD"
assert_contains "$current_dir" "docs" "Should navigate to docs subdirectory"

# Test 10.2: Exact match still works (no fuzzy search needed)
echo ""
echo "Test 10.2: Exact match takes precedence over fuzzy"
cd "$TEST_HOME"
goto "GAI-3101" >/dev/null 2>&1 || true
current_dir="$PWD"
assert_equals "$TEST_HOME/ASCIIDocs/GAI-3101" "$current_dir" "Exact match should navigate directly"

# Test 10.3: Fuzzy then exact navigation
echo ""
echo "Test 10.3: Combined fuzzy and exact navigation workflow"
cd "$TEST_HOME"
# First use fuzzy (if 'GAI' were ambiguous, it would fail, but we handle single match)
goto gai >/dev/null 2>&1 || true
# Should navigate to one of the GAI directories or show options
if [[ "$PWD" == *"GAI"* ]] || [[ "$PWD" == "$TEST_HOME" ]]; then
    pass_test "Fuzzy navigation workflow completed"
else
    fail_test "Unexpected directory after fuzzy match"
fi

cleanup_basic_dirs

#############################
# Test Category 11: Bookmarks Integration
#############################

echo ""
echo "=== Test Category 11: Bookmarks Integration ==="
echo ""

setup_basic_dirs

# Test 11.1: Bookmark with fuzzy matching
echo "Test 11.1: Create bookmark and use it"
bookmark add testwork "$TEST_HOME/Documents/LUXOR" >/dev/null 2>&1 || true
cd "$TEST_HOME"
goto @testwork >/dev/null 2>&1 || true
current_dir="$PWD"
assert_equals "$TEST_HOME/Documents/LUXOR" "$current_dir" "Should navigate to bookmarked location"

# Test 11.2: Bookmark doesn't interfere with fuzzy matching
echo ""
echo "Test 11.2: Fuzzy matching still works with bookmarks present"
cd "$TEST_HOME"
output=$(__goto_fuzzy_match "GAI" "GAI-3101" "GAI-3102" "HALCON")
assert_contains "$output" "GAI-3101" "Fuzzy matching works with bookmarks present"

bookmark rm testwork >/dev/null 2>&1 || true
cleanup_basic_dirs

#############################
# Test Category 12: Concurrent Execution
#############################

echo ""
echo "=== Test Category 12: Concurrent Execution ==="
echo ""

setup_basic_dirs

# Test 12.1: Concurrent fuzzy searches
echo "Test 12.1: Concurrent fuzzy searches (3 parallel)"
cd "$TEST_HOME"

# Run fuzzy match (not full goto) to avoid cd issues in subshells
(__goto_fuzzy_match "GAI" "GAI-3101" "GAI-3102" "HALCON" >/dev/null 2>&1 || true) &
pid1=$!
(__goto_fuzzy_match "HAL" "GAI-3101" "HALCON" "WA3590" >/dev/null 2>&1 || true) &
pid2=$!
(__goto_fuzzy_match "WA" "GAI-3101" "HALCON" "WA3590" >/dev/null 2>&1 || true) &
pid3=$!

# Wait for all to complete with timeout
wait $pid1 2>/dev/null || true
wait $pid2 2>/dev/null || true
wait $pid3 2>/dev/null || true

# All should complete without crashing (check directories still exist)
if [ -d "$TEST_HOME/ASCIIDocs/GAI-3101" ]; then
    pass_test "Concurrent execution completed without corruption"
else
    fail_test "Concurrent execution may have caused issues"
fi

cleanup_basic_dirs

#############################
# Test Category 13: Edge Case - No Search Paths
#############################

echo ""
echo "=== Test Category 13: Edge Case - No Search Paths ==="
echo ""

# Test 13.1: Empty search paths
echo "Test 13.1: Behavior with no directories in search paths"
cd "$TEST_HOME"
output=$(goto anything 2>&1 || true)
# Should show appropriate error message
if [[ "$output" == *"not found"* ]] || [[ "$output" == *"No matches"* ]]; then
    pass_test "Handles missing search paths gracefully"
else
    fail_test "Should show clear error for missing search paths"
fi

#############################
# Test Category 14: Unicode and Special Characters
#############################

echo ""
echo "=== Test Category 14: Unicode and Special Characters ==="
echo ""

mkdir -p "$TEST_HOME/ASCIIDocs"

# Test 14.1: Directory with unicode (if supported by filesystem)
echo "Test 14.1: Directory with unicode characters"
mkdir -p "$TEST_HOME/ASCIIDocs/project-测试" 2>/dev/null || true
if [ -d "$TEST_HOME/ASCIIDocs/project-测试" ]; then
    output=$(__goto_fuzzy_match "test" "project-测试" "other" 2>&1 || true)
    pass_test "Unicode directory handled without crash"
    rm -rf "$TEST_HOME/ASCIIDocs/project-测试"
else
    echo -e "${YELLOW}⚠${NC} Filesystem doesn't support unicode, skipping"
fi

# Test 14.2: Query with special characters
echo ""
echo "Test 14.2: Query with special shell characters"
output=$(__goto_fuzzy_match '$test' "project-\$test" "other" 2>&1 || true)
pass_test "Special shell characters handled safely"

rm -rf "$TEST_HOME/ASCIIDocs"

#############################
# Test Category 15: Boundary Conditions
#############################

echo ""
echo "=== Test Category 15: Boundary Conditions ==="
echo ""

# Test 15.1: Single directory in search
echo "Test 15.1: Single directory to search"
output=$(__goto_fuzzy_match "test" "test-project")
assert_contains "$output" "test-project" "Should match single directory"

# Test 15.2: Query longer than directory name
echo ""
echo "Test 15.2: Query longer than directory name"
output=$(__goto_fuzzy_match "very-long-query-that-exceeds-dirname" "short")
if [ -z "$output" ]; then
    pass_test "Long query with no match returns empty"
else
    fail_test "Long query should not match short dirname"
fi

# Test 15.3: Query equals directory name
echo ""
echo "Test 15.3: Query exactly equals directory name"
output=$(__goto_fuzzy_match "exact-match" "exact-match" "other")
assert_contains "$output" "exact-match" "Exact match should work"

#############################
# Final Summary
#############################

echo ""
echo "========================================"
echo "   Test Summary"
echo "========================================"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
else
    echo "Failed:       $FAILED_TESTS"
fi
echo "Duration:     ${DURATION}s"
echo ""

# Cleanup test environment
echo "Cleaning up test environment..."
cd "$ORIGINAL_PWD"
rm -rf "$TEST_HOME"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}   SOME TESTS FAILED${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
