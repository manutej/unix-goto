#!/bin/bash
# unix-goto test helpers - DRY principle applied
# Reusable test utilities and assertions

# Test framework state
TEST_COUNT=0
TEST_PASSED=0
TEST_FAILED=0
TEST_CURRENT=""

# Color codes for output
if [ -t 1 ]; then
    COLOR_RED='\033[0;31m'
    COLOR_GREEN='\033[0;32m'
    COLOR_YELLOW='\033[1;33m'
    COLOR_BLUE='\033[0;34m'
    COLOR_RESET='\033[0m'
else
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_BLUE=''
    COLOR_RESET=''
fi

# Test fixture management
FIXTURE_DIR=""

# Initialize test fixture directory
setup_test_fixture() {
    FIXTURE_DIR=$(mktemp -d -t goto-test.XXXXXX)
    export GOTO_BOOKMARKS_FILE="$FIXTURE_DIR/.goto_bookmarks"
    export GOTO_HISTORY_FILE="$FIXTURE_DIR/.goto_history"
    export GOTO_BENCHMARK_DIR="$FIXTURE_DIR/.goto_benchmarks"
}

# Clean up test fixtures
teardown_test_fixture() {
    if [ -n "$FIXTURE_DIR" ] && [ -d "$FIXTURE_DIR" ]; then
        rm -rf "$FIXTURE_DIR"
    fi
}

# Create test directory structure
create_test_dirs() {
    local base_dir="$1"
    shift

    for dir in "$@"; do
        mkdir -p "$base_dir/$dir"
    done
}

# Assertion: command succeeds
assert_success() {
    local cmd="$1"
    local msg="${2:-Command should succeed}"

    if eval "$cmd" >/dev/null 2>&1; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Command failed: $cmd"
        return 1
    fi
}

# Assertion: command fails
assert_failure() {
    local cmd="$1"
    local msg="${2:-Command should fail}"

    if ! eval "$cmd" >/dev/null 2>&1; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Command succeeded unexpectedly: $cmd"
        return 1
    fi
}

# Assertion: strings are equal
assert_equal() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Values should be equal}"

    if [ "$expected" = "$actual" ]; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Expected: '$expected', Got: '$actual'"
        return 1
    fi
}

# Assertion: string contains substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local msg="${3:-String should contain substring}"

    if [[ "$haystack" == *"$needle"* ]]; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Expected to find '$needle' in '$haystack'"
        return 1
    fi
}

# Assertion: file exists
assert_file_exists() {
    local file="$1"
    local msg="${2:-File should exist}"

    if [ -f "$file" ]; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "File not found: $file"
        return 1
    fi
}

# Assertion: directory exists
assert_dir_exists() {
    local dir="$1"
    local msg="${2:-Directory should exist}"

    if [ -d "$dir" ]; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Directory not found: $dir"
        return 1
    fi
}

# Assertion: file does not exist
assert_file_not_exists() {
    local file="$1"
    local msg="${2:-File should not exist}"

    if [ ! -f "$file" ]; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "File exists but shouldn't: $file"
        return 1
    fi
}

# Assertion: file contains text
assert_file_contains() {
    local file="$1"
    local text="$2"
    local msg="${3:-File should contain text}"

    if [ -f "$file" ] && grep -q "$text" "$file"; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Text '$text' not found in $file"
        return 1
    fi
}

# Assertion: line count
assert_line_count() {
    local file="$1"
    local expected="$2"
    local msg="${3:-File should have expected line count}"

    if [ ! -f "$file" ]; then
        test_fail "$msg" "File not found: $file"
        return 1
    fi

    local actual=$(wc -l < "$file" | tr -d ' ')

    if [ "$actual" -eq "$expected" ]; then
        test_pass "$msg"
        return 0
    else
        test_fail "$msg" "Expected $expected lines, got $actual"
        return 1
    fi
}

# Record test pass
test_pass() {
    local msg="$1"
    TEST_PASSED=$((TEST_PASSED + 1))
    echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} $msg"
}

# Record test failure
test_fail() {
    local msg="$1"
    local detail="${2:-}"
    TEST_FAILED=$((TEST_FAILED + 1))
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} $msg"
    if [ -n "$detail" ]; then
        echo -e "    ${COLOR_YELLOW}→${COLOR_RESET} $detail"
    fi
}

# Start a test suite
test_suite() {
    local name="$1"
    echo ""
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_BLUE}  $name${COLOR_RESET}"
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
}

# Start a test case
test_case() {
    local name="$1"
    TEST_CURRENT="$name"
    TEST_COUNT=$((TEST_COUNT + 1))
    echo ""
    echo -e "${COLOR_YELLOW}Test $TEST_COUNT: $name${COLOR_RESET}"
    echo "───────────────────────────────────────────────────────────"
}

# Print test summary
test_summary() {
    local total=$((TEST_PASSED + TEST_FAILED))

    echo ""
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_BLUE}  TEST SUMMARY${COLOR_RESET}"
    echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
    echo "  Total assertions: $total"
    echo -e "  ${COLOR_GREEN}Passed: $TEST_PASSED${COLOR_RESET}"
    echo -e "  ${COLOR_RED}Failed: $TEST_FAILED${COLOR_RESET}"
    echo ""

    if [ $TEST_FAILED -eq 0 ]; then
        echo -e "${COLOR_GREEN}  ALL TESTS PASSED${COLOR_RESET}"
        echo ""
        return 0
    else
        echo -e "${COLOR_RED}  TESTS FAILED${COLOR_RESET}"
        echo ""
        return 1
    fi
}

# Measure execution time in milliseconds
time_ms() {
    local start end

    if command -v python3 &>/dev/null; then
        start=$(python3 -c "import time; print(int(time.time() * 1000))")
        "$@"
        end=$(python3 -c "import time; print(int(time.time() * 1000))")
        echo $((end - start))
    else
        # Fallback to second precision
        start=$(date +%s)
        "$@"
        end=$(date +%s)
        echo $(((end - start) * 1000))
    fi
}

# Mock function - replace command output
mock_command() {
    local cmd_name="$1"
    local output="$2"

    eval "${cmd_name}() { echo '$output'; }"
}

# Stub function - replace command with no-op
stub_command() {
    local cmd_name="$1"

    eval "${cmd_name}() { :; }"
}
