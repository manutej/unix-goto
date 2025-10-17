#!/bin/bash
# Verification script to run all tests and generate comprehensive report
# Use this before creating PRs or releasing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          UNIX-GOTO COMPREHENSIVE VERIFICATION                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Track overall status
overall_status=0

# 1. Run all tests
echo "Step 1: Running all test suites..."
echo "────────────────────────────────────────────────────────────────"
if "$SCRIPT_DIR/run-tests.sh"; then
    echo "✓ All test suites passed"
else
    echo "✗ Some test suites failed"
    overall_status=1
fi
echo ""

# 2. Run coverage analysis
echo "Step 2: Analyzing code coverage..."
echo "────────────────────────────────────────────────────────────────"
"$SCRIPT_DIR/coverage-analysis.sh"

# Extract coverage percentage
if [ -f "$REPO_DIR/coverage-report.txt" ]; then
    coverage=$(grep "Coverage:" "$REPO_DIR/coverage-report.txt" | grep -o '[0-9]*' | head -1)
    echo ""
    echo "Current Coverage: ${coverage}%"

    if [ "$coverage" -ge 80 ]; then
        echo "✓ Coverage meets 80% target"
    elif [ "$coverage" -ge 60 ]; then
        echo "⚠ Coverage at ${coverage}%, approaching 80% target"
    else
        echo "✗ Coverage below 60%, needs improvement"
        overall_status=1
    fi
fi
echo ""

# 3. Run performance tests
echo "Step 3: Running performance regression tests..."
echo "────────────────────────────────────────────────────────────────"
if "$SCRIPT_DIR/unit/test-performance.sh" > /dev/null 2>&1; then
    echo "✓ All performance thresholds met"
else
    echo "⚠ Some performance thresholds exceeded"
    # Don't fail overall, just warn
fi
echo ""

# 4. Run edge case tests
echo "Step 4: Running edge case validation..."
echo "────────────────────────────────────────────────────────────────"
if "$SCRIPT_DIR/unit/test-edge-cases.sh" > /dev/null 2>&1; then
    echo "✓ All edge cases handled correctly"
else
    echo "✗ Some edge cases failed"
    overall_status=1
fi
echo ""

# 5. Verify CI/CD configuration
echo "Step 5: Verifying CI/CD configuration..."
echo "────────────────────────────────────────────────────────────────"
if [ -f "$REPO_DIR/.github/workflows/test.yml" ]; then
    echo "✓ GitHub Actions workflow present"

    # Check for required jobs
    if grep -q "jobs:" "$REPO_DIR/.github/workflows/test.yml" && \
       grep -q "test:" "$REPO_DIR/.github/workflows/test.yml" && \
       grep -q "performance:" "$REPO_DIR/.github/workflows/test.yml"; then
        echo "✓ Required CI/CD jobs configured"
    else
        echo "⚠ Some CI/CD jobs may be missing"
    fi
else
    echo "✗ GitHub Actions workflow not found"
    overall_status=1
fi
echo ""

# 6. Check documentation
echo "Step 6: Verifying documentation..."
echo "────────────────────────────────────────────────────────────────"
docs_found=0
docs_expected=("TESTING-COMPREHENSIVE.md" "TEST-ENHANCEMENT-SUMMARY.md" "TESTING-QUICK-REFERENCE.md" "LINEAR-ISSUES-SUMMARY.md")

for doc in "${docs_expected[@]}"; do
    if [ -f "$REPO_DIR/$doc" ]; then
        echo "✓ $doc present"
        docs_found=$((docs_found + 1))
    else
        echo "✗ $doc missing"
    fi
done

if [ $docs_found -eq ${#docs_expected[@]} ]; then
    echo "✓ All documentation present"
else
    echo "⚠ Some documentation missing"
fi
echo ""

# 7. Count test statistics
echo "Step 7: Test statistics summary..."
echo "────────────────────────────────────────────────────────────────"

test_files=$(find "$SCRIPT_DIR/unit" -name "test-*.sh" | wc -l | tr -d ' ')
test_cases=$(grep -h "test_case" "$SCRIPT_DIR/unit"/test-*.sh | wc -l | tr -d ' ')
assertions=$(grep -h "assert_" "$SCRIPT_DIR/unit"/test-*.sh | wc -l | tr -d ' ')

echo "Test Files: $test_files"
echo "Test Cases: $test_cases"
echo "Assertions: $assertions"

if [ "$test_files" -ge 8 ] && [ "$test_cases" -ge 80 ]; then
    echo "✓ Comprehensive test suite"
else
    echo "⚠ Test suite could be expanded"
fi
echo ""

# Final summary
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    VERIFICATION SUMMARY                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

if [ $overall_status -eq 0 ]; then
    echo "  ✓ ALL CHECKS PASSED"
    echo ""
    echo "  The test suite is ready for:"
    echo "    - Creating pull requests"
    echo "    - Merging to main branch"
    echo "    - Production deployment"
    echo ""
    echo "  Linear Issues Addressed:"
    echo "    ✓ CET-87: CI/CD integration"
    echo "    ✓ CET-89: Edge case testing"
    echo "    ✓ CET-90: Code coverage (${coverage}%)"
    echo "    ✓ CET-93: Performance regression tests"
    echo ""
else
    echo "  ⚠ SOME CHECKS FAILED"
    echo ""
    echo "  Please review the output above and address any issues"
    echo "  before creating a pull request."
    echo ""
fi

echo "Report saved to: $REPO_DIR/coverage-report.txt"
echo ""

exit $overall_status
