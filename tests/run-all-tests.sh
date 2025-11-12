#!/bin/bash
# Master test runner for unix-goto
# Runs all test suites and generates comprehensive report

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$TEST_DIR")"

# Overall test tracking
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0
START_TIME=$(date +%s)

echo ""
echo "=========================================="
echo "   unix-goto Test Suite Runner"
echo "   Version: v0.4.0"
echo "=========================================="
echo ""
echo "Repository: $REPO_ROOT"
echo "Test Directory: $TEST_DIR"
echo ""

# Function to run a test suite
run_test_suite() {
    local test_file="$1"
    local test_name="$2"

    TOTAL_SUITES=$((TOTAL_SUITES + 1))

    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Running: $test_name${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    if [ ! -f "$test_file" ]; then
        echo -e "${RED}✗ Test file not found: $test_file${NC}"
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi

    if [ ! -x "$test_file" ]; then
        chmod +x "$test_file"
    fi

    # Run the test suite
    if bash "$test_file"; then
        echo ""
        echo -e "${GREEN}✓ $test_name: PASSED${NC}"
        PASSED_SUITES=$((PASSED_SUITES + 1))
        return 0
    else
        echo ""
        echo -e "${RED}✗ $test_name: FAILED${NC}"
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi
}

# Run all test suites
echo "Starting test execution..."
echo ""

# Test Suite 1: Basic Tests
run_test_suite "$TEST_DIR/test-basic.sh" "Basic Tests (Syntax & Structure)"

# Test Suite 2: Fuzzy Matching Tests
run_test_suite "$TEST_DIR/test-fuzzy-matching.sh" "Fuzzy Matching Tests (Comprehensive)"

# Test Suite 3: Original run-tests (if different from test-basic)
if [ -f "$TEST_DIR/run-tests.sh" ] && [ "$TEST_DIR/run-tests.sh" != "$TEST_DIR/test-basic.sh" ]; then
    # Only run if it's not the same as this file
    if [ "$TEST_DIR/run-tests.sh" != "$TEST_DIR/run-all-tests.sh" ]; then
        run_test_suite "$TEST_DIR/run-tests.sh" "Integration Tests"
    fi
fi

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Final Summary
echo ""
echo ""
echo "=========================================="
echo "   Final Test Summary"
echo "=========================================="
echo ""
echo "Total Test Suites: $TOTAL_SUITES"
echo -e "${GREEN}Passed:            $PASSED_SUITES${NC}"

if [ $FAILED_SUITES -gt 0 ]; then
    echo -e "${RED}Failed:            $FAILED_SUITES${NC}"
else
    echo "Failed:            $FAILED_SUITES"
fi

if [ $MINUTES -gt 0 ]; then
    echo "Duration:          ${MINUTES}m ${SECONDS}s"
else
    echo "Duration:          ${SECONDS}s"
fi

echo ""

# Performance check
if [ $DURATION -gt 120 ]; then
    echo -e "${YELLOW}⚠ Warning: Tests took longer than 2 minutes${NC}"
    echo "  Success criteria: Tests should complete in < 2 minutes"
    echo ""
fi

# Exit with appropriate code
if [ $FAILED_SUITES -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   ✓ ALL TEST SUITES PASSED${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Ready for release! 🚀"
    echo ""
    exit 0
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}   ✗ SOME TEST SUITES FAILED${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo "Please fix failing tests before release."
    echo ""
    exit 1
fi
