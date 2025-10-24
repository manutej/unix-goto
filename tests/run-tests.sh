#!/bin/bash
# Test runner for unix-goto
# Runs all unit and integration tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

# Configuration
VERBOSE=0
STOP_ON_FAIL=0
TEST_PATTERN=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -f|--fail-fast)
            STOP_ON_FAIL=1
            shift
            ;;
        -p|--pattern)
            TEST_PATTERN="$2"
            shift 2
            ;;
        -h|--help)
            echo "unix-goto test runner"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose       Verbose output"
            echo "  -f, --fail-fast     Stop on first failure"
            echo "  -p, --pattern GLOB  Run only tests matching pattern"
            echo "  -h, --help          Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                          # Run all tests"
            echo "  $0 -v                       # Verbose mode"
            echo "  $0 -p bookmark              # Run only bookmark tests"
            echo "  $0 -f                       # Stop on first failure"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Find test files
find_tests() {
    local pattern="${1:-*}"

    find "$SCRIPT_DIR/unit" -name "test-${pattern}*.sh" -type f 2>/dev/null | sort
}

# Run a single test file
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)

    echo ""
    echo "=========================================="
    echo "Running: $test_name"
    echo "=========================================="

    if [ $VERBOSE -eq 1 ]; then
        bash "$test_file"
    else
        bash "$test_file" 2>&1
    fi

    return $?
}

# Main execution
main() {
    local test_files=()
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    # Find test files
    if [ -n "$TEST_PATTERN" ]; then
        while IFS= read -r file; do
            test_files+=("$file")
        done < <(find_tests "$TEST_PATTERN")
    else
        while IFS= read -r file; do
            test_files+=("$file")
        done < <(find_tests)
    fi

    if [ ${#test_files[@]} -eq 0 ]; then
        echo "No tests found matching pattern: ${TEST_PATTERN:-*}"
        exit 1
    fi

    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║             UNIX-GOTO TEST SUITE                                 ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Found ${#test_files[@]} test suite(s)"
    echo ""

    # Run each test file
    for test_file in "${test_files[@]}"; do
        total_tests=$((total_tests + 1))

        if run_test "$test_file"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_tests=$((failed_tests + 1))

            if [ $STOP_ON_FAIL -eq 1 ]; then
                echo ""
                echo "Stopping due to test failure (--fail-fast enabled)"
                break
            fi
        fi
    done

    # Print overall summary
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║             OVERALL TEST SUMMARY                                 ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Total test suites: $total_tests"
    echo "  Passed: $passed_tests"
    echo "  Failed: $failed_tests"
    echo ""

    if [ $failed_tests -eq 0 ]; then
        echo "  ALL TEST SUITES PASSED"
        echo ""
        return 0
    else
        echo "  SOME TEST SUITES FAILED"
        echo ""
        return 1
    fi
}

# Run main
main
exit $?
