#!/bin/bash
# Code Coverage Analysis Script
# Analyzes test coverage and identifies gaps in the unix-goto codebase

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."
LIB_DIR="$REPO_DIR/lib"

# Coverage report file
COVERAGE_REPORT="$REPO_DIR/coverage-report.txt"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              UNIX-GOTO CODE COVERAGE ANALYSIS                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Function to analyze a single file
analyze_file() {
    local file="$1"
    local file_name=$(basename "$file")

    # Count total functions
    local total_functions=$(grep -c "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*()[[:space:]]*{" "$file" || echo "0")

    # Count total lines (excluding comments and blank lines)
    local total_lines=$(grep -v "^[[:space:]]*#" "$file" | grep -v "^[[:space:]]*$" | wc -l | tr -d ' ')

    echo "$file_name: $total_functions functions, $total_lines LOC"
}

# Analyze all library files
echo "Analyzing library files..."
echo "────────────────────────────────────────────────────────────────"
echo ""

total_files=0
total_functions=0
total_lines=0

for lib_file in "$LIB_DIR"/*.sh; do
    if [ -f "$lib_file" ]; then
        analyze_file "$lib_file"

        # Count functions
        funcs=$(grep -c "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*()[[:space:]]*{" "$lib_file" || echo "0")
        total_functions=$((total_functions + funcs))

        # Count lines
        lines=$(grep -v "^[[:space:]]*#" "$lib_file" | grep -v "^[[:space:]]*$" | wc -l | tr -d ' ')
        total_lines=$((total_lines + lines))

        total_files=$((total_files + 1))
    fi
done

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "Total: $total_files files, $total_functions functions, $total_lines LOC"
echo ""

# Analyze test coverage
echo ""
echo "Analyzing test coverage..."
echo "────────────────────────────────────────────────────────────────"
echo ""

total_test_files=0
total_test_cases=0
total_assertions=0

for test_file in "$SCRIPT_DIR/unit"/test-*.sh; do
    if [ -f "$test_file" ]; then
        test_name=$(basename "$test_file")

        # Count test cases
        test_cases=$(grep -c "test_case" "$test_file" || echo "0")

        # Count assertions
        assertions=$(grep -c "assert_" "$test_file" || echo "0")

        echo "$test_name: $test_cases test cases, $assertions assertions"

        total_test_files=$((total_test_files + 1))
        total_test_cases=$((total_test_cases + test_cases))
        total_assertions=$((total_assertions + assertions))
    fi
done

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "Total: $total_test_files test files, $total_test_cases test cases, $total_assertions assertions"
echo ""

# Calculate coverage estimates
echo ""
echo "Coverage Estimates..."
echo "────────────────────────────────────────────────────────────────"
echo ""

# Estimate function coverage
function_coverage=0
if [ $total_functions -gt 0 ]; then
    function_coverage=$((total_test_cases * 100 / total_functions))
fi

echo "Test Cases per Function: $total_test_cases / $total_functions"
echo "Estimated Function Coverage: ~${function_coverage}%"
echo ""

# Identify modules without dedicated tests
echo "Modules requiring additional test coverage:"
echo ""

# Check which lib files have corresponding tests
for lib_file in "$LIB_DIR"/*.sh; do
    if [ -f "$lib_file" ]; then
        lib_name=$(basename "$lib_file" .sh)

        # Look for corresponding test file
        if ! ls "$SCRIPT_DIR/unit"/test-*"$lib_name"*.sh >/dev/null 2>&1; then
            # Check if functions from this file are tested elsewhere
            funcs_in_lib=$(grep "^[[:space:]]*__goto_[a-zA-Z_][a-zA-Z0-9_]*()[[:space:]]*{" "$lib_file" | sed 's/()[[:space:]]*{.*//' | sed 's/^[[:space:]]*//')

            if [ -n "$funcs_in_lib" ]; then
                tested=false
                while IFS= read -r func_name; do
                    if grep -q "$func_name" "$SCRIPT_DIR/unit"/test-*.sh 2>/dev/null; then
                        tested=true
                        break
                    fi
                done <<< "$funcs_in_lib"

                if ! $tested; then
                    echo "  - $lib_name (no dedicated test coverage)"
                fi
            fi
        fi
    fi
done

echo ""

# Identify specific functions not covered
echo "Functions potentially lacking coverage:"
echo ""

checked_functions=0
uncovered_count=0

for lib_file in "$LIB_DIR"/*.sh; do
    if [ -f "$lib_file" ]; then
        lib_name=$(basename "$lib_file" .sh)

        # Extract function names
        while IFS= read -r func_line; do
            func_name=$(echo "$func_line" | sed 's/()[[:space:]]*{.*//' | sed 's/^[[:space:]]*//')

            if [ -n "$func_name" ]; then
                checked_functions=$((checked_functions + 1))

                # Check if function is called in any test
                if ! grep -q "$func_name" "$SCRIPT_DIR/unit"/test-*.sh 2>/dev/null; then
                    echo "  - $func_name (in $lib_name)"
                    uncovered_count=$((uncovered_count + 1))
                fi
            fi
        done < <(grep "^[[:space:]]*__goto_[a-zA-Z_][a-zA-Z0-9_]*()[[:space:]]*{" "$lib_file")
    fi
done

if [ $uncovered_count -eq 0 ]; then
    echo "  All major functions appear to have test coverage!"
fi

echo ""

# Calculate overall coverage score
if [ $checked_functions -gt 0 ]; then
    covered_functions=$((checked_functions - uncovered_count))
    coverage_percentage=$((covered_functions * 100 / checked_functions))

    echo "────────────────────────────────────────────────────────────────"
    echo "OVERALL COVERAGE SCORE"
    echo "────────────────────────────────────────────────────────────────"
    echo ""
    echo "  Checked Functions: $checked_functions"
    echo "  Covered Functions: $covered_functions"
    echo "  Uncovered Functions: $uncovered_count"
    echo "  Coverage Percentage: ${coverage_percentage}%"
    echo ""

    if [ $coverage_percentage -ge 80 ]; then
        echo "  Status: ✓ EXCELLENT (>= 80%)"
    elif [ $coverage_percentage -ge 60 ]; then
        echo "  Status: ⚠ GOOD (>= 60%)"
    else
        echo "  Status: ✗ NEEDS IMPROVEMENT (< 60%)"
    fi
    echo ""
fi

# Save report
{
    echo "Unix-goto Code Coverage Report"
    echo "Generated: $(date)"
    echo ""
    echo "Summary:"
    echo "  Library Files: $total_files"
    echo "  Functions: $total_functions"
    echo "  Lines of Code: $total_lines"
    echo "  Test Files: $total_test_files"
    echo "  Test Cases: $total_test_cases"
    echo "  Assertions: $total_assertions"
    echo "  Coverage: ${coverage_percentage}%"
} > "$COVERAGE_REPORT"

echo "Coverage report saved to: $COVERAGE_REPORT"
echo ""
