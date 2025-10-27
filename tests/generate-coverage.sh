#!/bin/bash
# Generate HTML coverage report using kcov (if available)
# Falls back to custom coverage analysis if kcov is not installed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."
COVERAGE_DIR="$REPO_DIR/coverage"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              UNIX-GOTO COVERAGE REPORT GENERATOR                 ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Check if kcov is available
if command -v kcov &> /dev/null; then
    echo "Using kcov for detailed coverage analysis..."
    echo ""

    # Create coverage directory
    mkdir -p "$COVERAGE_DIR"

    # Run each test file with kcov
    echo "Running tests with coverage instrumentation..."
    echo "────────────────────────────────────────────────────────────────"
    echo ""

    for test_file in "$SCRIPT_DIR/unit"/test-*.sh; do
        if [ -f "$test_file" ]; then
            test_name=$(basename "$test_file" .sh)
            echo "  Processing: $test_name"

            # Run with kcov
            kcov --exclude-pattern=/usr,/tmp \
                 --bash-dont-parse-binary-dir \
                 "$COVERAGE_DIR/$test_name" \
                 "$test_file" > /dev/null 2>&1

            if [ $? -eq 0 ]; then
                echo "    ✓ Coverage collected"
            else
                echo "    ⚠ Warning: coverage collection had issues"
            fi
        fi
    done

    echo ""
    echo "────────────────────────────────────────────────────────────────"
    echo ""

    # Merge coverage reports
    if [ -d "$COVERAGE_DIR" ]; then
        echo "Merging coverage reports..."

        # kcov automatically merges reports in the same directory
        # The merged report is in the parent coverage directory

        if [ -f "$COVERAGE_DIR/index.html" ]; then
            echo "✓ HTML coverage report generated"
            echo ""
            echo "View coverage report:"
            echo "  open $COVERAGE_DIR/index.html"
            echo ""
        else
            echo "⚠ HTML report not found, check kcov output"
        fi

        # Extract coverage percentage from kcov output
        if [ -f "$COVERAGE_DIR/kcov-merged/coverage.json" ]; then
            echo "Coverage summary:"
            echo "  Report: $COVERAGE_DIR/kcov-merged/index.html"
        fi
    fi

else
    echo "kcov not found - using custom coverage analysis"
    echo ""
    echo "For HTML coverage reports, install kcov:"
    echo "  macOS: brew install kcov"
    echo "  Ubuntu: sudo apt-get install kcov"
    echo ""
    echo "────────────────────────────────────────────────────────────────"
    echo ""

    # Fall back to custom analysis
    "$SCRIPT_DIR/coverage-analysis.sh"
fi

# Generate badge-friendly coverage data
generate_coverage_badge() {
    local coverage_pct="$1"

    local color="red"
    if [ "$coverage_pct" -ge 80 ]; then
        color="brightgreen"
    elif [ "$coverage_pct" -ge 60 ]; then
        color="yellow"
    elif [ "$coverage_pct" -ge 40 ]; then
        color="orange"
    fi

    echo ""
    echo "Coverage Badge:"
    echo "  ![Coverage](https://img.shields.io/badge/coverage-${coverage_pct}%25-${color})"
    echo ""
}

# Extract coverage from report and generate badge
if [ -f "$REPO_DIR/coverage-report.txt" ]; then
    coverage=$(grep "Coverage:" "$REPO_DIR/coverage-report.txt" | grep -o '[0-9]*' | head -1)

    if [ -n "$coverage" ]; then
        generate_coverage_badge "$coverage"
    fi
fi

echo "Coverage analysis complete"
echo ""
