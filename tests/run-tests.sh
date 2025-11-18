#!/bin/bash
# Automated test suite for unix-goto
# Can be run without external dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test environment setup
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$TEST_DIR")"
TEST_HOME="/tmp/unix-goto-test-$$"

echo "Setting up test environment..."
mkdir -p "$TEST_HOME"
export HOME="$TEST_HOME"

# Create test directory structure
mkdir -p "$TEST_HOME/ASCIIDocs"
mkdir -p "$TEST_HOME/ASCIIDocs/GAI-3101"
mkdir -p "$TEST_HOME/ASCIIDocs/GAI-3101/docs"
mkdir -p "$TEST_HOME/ASCIIDocs/WA3590"
mkdir -p "$TEST_HOME/Documents/LUXOR"
mkdir -p "$TEST_HOME/Documents/LUXOR/PROJECTS/HALCON"
mkdir -p "$TEST_HOME/Documents/LUXOR/Git_Repos/unix-goto"
mkdir -p "$TEST_HOME/Documents/LUXOR/Git_Repos/unix-goto/lib"

# Source the library files
source "$REPO_ROOT/lib/history-tracking.sh"
source "$REPO_ROOT/lib/back-command.sh"
source "$REPO_ROOT/lib/recent-command.sh"
source "$REPO_ROOT/lib/bookmark-command.sh"
source "$REPO_ROOT/lib/list-command.sh"
source "$REPO_ROOT/lib/goto-function.sh"

# Test helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$expected" = "$actual" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Assertion failed}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $message"
        echo "  Expected to contain: $needle"
        echo "  Actual: $haystack"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ -f "$file" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

assert_dir_equals() {
    local expected="$1"
    local message="${2:-Should be in directory: $expected}"

    assert_equals "$expected" "$PWD" "$message"
}

# Test suite
echo ""
echo "=== Running unix-goto Test Suite ==="
echo ""

# Test 1: Bookmark functionality
echo "--- Bookmark Tests ---"

# Test add bookmark
bookmark add test1 "$TEST_HOME/ASCIIDocs"
assert_file_exists "$TEST_HOME/.goto_bookmarks" "Bookmark file created"

# Test list bookmark
output=$(bookmark list 2>&1)
assert_contains "$output" "test1" "Bookmark appears in list"

# Test goto bookmark
goto @test1 > /dev/null 2>&1
assert_dir_equals "$TEST_HOME/ASCIIDocs" "Navigate to bookmark with @"

# Test remove bookmark
bookmark rm test1 > /dev/null 2>&1
output=$(bookmark list 2>&1)
assert_contains "$output" "No bookmarks yet" "Bookmark removed successfully"

echo ""

# Test 2: Direct navigation
echo "--- Direct Navigation Tests ---"

# Test shortcut navigation (would need to be in actual shell)
# Skipping as it requires actual directory structure

echo ""

# Test 3: Multi-level navigation
echo "--- Multi-Level Navigation Tests ---"

# Create a more complex structure for testing
mkdir -p "$TEST_HOME/ASCIIDocs/project1/src/components"

# Note: Full testing requires being in a shell environment
# These are structural tests only

echo -e "${YELLOW}ℹ${NC} Multi-level navigation requires interactive shell testing"
echo -e "${YELLOW}ℹ${NC} See TESTING-GUIDE.md for manual testing procedures"

echo ""

# Test 4: History tracking
echo "--- History Tracking Tests ---"

# Push some directories to stack
__goto_stack_push "$TEST_HOME"
__goto_stack_push "$TEST_HOME/ASCIIDocs"
assert_file_exists "$TEST_HOME/.goto_stack" "Navigation stack created"

# Check stack contents
stack_size=$(wc -l < "$TEST_HOME/.goto_stack")
assert_equals "2" "$stack_size" "Stack has correct number of entries"

# Clear stack
back --clear > /dev/null 2>&1

echo ""

# Test 5: Recent folders
echo "--- Recent Folders Tests ---"

# Track some navigation
__goto_track "$TEST_HOME/ASCIIDocs"
__goto_track "$TEST_HOME/Documents/LUXOR"
assert_file_exists "$TEST_HOME/.goto_history" "History file created"

# Check history
history_size=$(wc -l < "$TEST_HOME/.goto_history")
[[ $history_size -ge 2 ]] && echo -e "${GREEN}✓${NC} History has entries" || echo -e "${RED}✗${NC} History missing entries"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
[[ $history_size -ge 2 ]] && PASSED_TESTS=$((PASSED_TESTS + 1)) || FAILED_TESTS=$((FAILED_TESTS + 1))

echo ""

# Test 6: Error handling
echo "--- Error Handling Tests ---"

# Test non-existent bookmark
output=$(goto @nonexistent 2>&1)
assert_contains "$output" "not found" "Error message for non-existent bookmark"

# Test bookmark add without name
output=$(bookmark add 2>&1)
assert_contains "$output" "required" "Error message for missing bookmark name"

echo ""

# Test 7: Code quality checks
echo "--- Code Quality Tests ---"

# Check for proper quoting in main files
grep -n '[^"]$[A-Z_]*[^"]' "$REPO_ROOT/lib/goto-function.sh" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓${NC} Variables properly quoted in goto-function.sh"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠${NC} Some variables may need quoting in goto-function.sh"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Check for use of local keyword
grep -q "local " "$REPO_ROOT/lib/goto-function.sh"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Functions use local variables"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}✗${NC} Functions should use local variables"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Check for set -e in scripts that should have it
grep -q "set -e" "$REPO_ROOT/install.sh"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} install.sh uses set -e"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${YELLOW}⚠${NC} install.sh should use set -e"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo ""

# Cleanup
echo "Cleaning up test environment..."
rm -rf "$TEST_HOME"

# Summary
echo "==================================="
echo "Test Summary:"
echo "  Total:  $TOTAL_TESTS"
echo -e "  ${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "  ${RED}Failed: $FAILED_TESTS${NC}"
echo "==================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
