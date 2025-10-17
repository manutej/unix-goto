#!/bin/bash
# Test script for benchmark functionality
# Verifies that all benchmark features work correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║         UNIX-GOTO BENCHMARK FUNCTIONALITY TEST                   ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Verify benchmark files exist
echo "Test 1: Verifying benchmark files..."
echo "───────────────────────────────────────"

files=(
    "$REPO_DIR/lib/benchmark-command.sh"
    "$REPO_DIR/lib/benchmark-workspace.sh"
    "$REPO_DIR/bin/benchmark-goto"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ Found: $(basename "$file")"
    else
        echo "  ✗ Missing: $file"
        exit 1
    fi
done
echo ""

# Test 2: Verify benchmark functions are defined
echo "Test 2: Verifying benchmark functions..."
echo "─────────────────────────────────────────"

source "$REPO_DIR/lib/benchmark-command.sh"
source "$REPO_DIR/lib/benchmark-workspace.sh"

functions=(
    "__goto_benchmark"
    "__goto_benchmark_navigation"
    "__goto_benchmark_cache"
    "__goto_benchmark_parallel"
    "__goto_benchmark_report"
    "__goto_benchmark_workspace"
)

for func in "${functions[@]}"; do
    if declare -f "$func" > /dev/null; then
        echo "  ✓ Defined: $func"
    else
        echo "  ✗ Missing: $func"
        exit 1
    fi
done
echo ""

# Test 3: Verify standalone script is executable
echo "Test 3: Verifying standalone script..."
echo "───────────────────────────────────────"

if [ -x "$REPO_DIR/bin/benchmark-goto" ]; then
    echo "  ✓ benchmark-goto is executable"
else
    echo "  ✗ benchmark-goto is not executable"
    exit 1
fi

# Test help output
if "$REPO_DIR/bin/benchmark-goto" --help > /dev/null 2>&1; then
    echo "  ✓ benchmark-goto --help works"
else
    echo "  ✗ benchmark-goto --help failed"
    exit 1
fi
echo ""

# Test 4: Verify benchmark initialization
echo "Test 4: Testing benchmark initialization..."
echo "──────────────────────────────────────────"

__goto_benchmark_init

if [ -d "$HOME/.goto_benchmarks" ]; then
    echo "  ✓ Benchmark directory created: ~/.goto_benchmarks"
else
    echo "  ✗ Benchmark directory not created"
    exit 1
fi

if [ -f "$HOME/.goto_benchmarks/results.csv" ]; then
    echo "  ✓ Results file created: results.csv"
else
    echo "  ✗ Results file not created"
    exit 1
fi

# Verify CSV header
header=$(head -n 1 "$HOME/.goto_benchmarks/results.csv")
if [[ "$header" == *"timestamp"* ]] && [[ "$header" == *"benchmark_type"* ]]; then
    echo "  ✓ CSV header is valid"
else
    echo "  ✗ CSV header is invalid"
    exit 1
fi
echo ""

# Test 5: Test workspace creation
echo "Test 5: Testing workspace creation..."
echo "─────────────────────────────────────"

if __goto_benchmark_create_workspace "small" "true" > /dev/null 2>&1; then
    echo "  ✓ Small workspace created"
else
    echo "  ✗ Small workspace creation failed"
    exit 1
fi

if [ -d "$HOME/.goto_benchmark_workspace" ]; then
    echo "  ✓ Workspace directory exists"
else
    echo "  ✗ Workspace directory not found"
    exit 1
fi

# Count directories
dir_count=$(find "$HOME/.goto_benchmark_workspace" -type d | wc -l | tr -d ' ')
if [ "$dir_count" -gt 5 ]; then
    echo "  ✓ Workspace contains directories ($dir_count found)"
else
    echo "  ✗ Workspace has too few directories"
    exit 1
fi
echo ""

# Test 6: Test workspace stats
echo "Test 6: Testing workspace statistics..."
echo "───────────────────────────────────────"

if __goto_benchmark_workspace_stats > /dev/null 2>&1; then
    echo "  ✓ Workspace stats command works"
else
    echo "  ✗ Workspace stats command failed"
    exit 1
fi
echo ""

# Test 7: Test benchmark record function
echo "Test 7: Testing benchmark recording..."
echo "──────────────────────────────────────"

__goto_benchmark_record "test" "test_case_1" "100" "warm" "small" "info"

if grep -q "test,test_case_1,100,warm,small,info" "$HOME/.goto_benchmarks/results.csv"; then
    echo "  ✓ Benchmark result recorded correctly"
else
    echo "  ✗ Benchmark result not recorded"
    exit 1
fi
echo ""

# Test 8: Test statistics calculation
echo "Test 8: Testing statistics calculation..."
echo "─────────────────────────────────────────"

values=(100 150 200 180 120)
stats=$(__goto_benchmark_stats "${values[@]}")

min=$(echo "$stats" | cut -d'|' -f1)
max=$(echo "$stats" | cut -d'|' -f2)
mean=$(echo "$stats" | cut -d'|' -f3)

if [ "$min" = "100" ] && [ "$max" = "200" ] && [ "$mean" = "150" ]; then
    echo "  ✓ Statistics calculation correct (min=$min, max=$max, mean=$mean)"
else
    echo "  ✗ Statistics calculation incorrect"
    exit 1
fi
echo ""

# Test 9: Clean up workspace
echo "Test 9: Testing workspace cleanup..."
echo "────────────────────────────────────"

if __goto_benchmark_workspace_clean > /dev/null 2>&1; then
    echo "  ✓ Workspace cleanup command works"
else
    echo "  ✗ Workspace cleanup command failed"
    exit 1
fi

if [ ! -d "$HOME/.goto_benchmark_workspace" ]; then
    echo "  ✓ Workspace directory removed"
else
    echo "  ✗ Workspace directory still exists"
    exit 1
fi
echo ""

# Test 10: Verify goto integration
echo "Test 10: Testing goto integration..."
echo "────────────────────────────────────"

source "$REPO_DIR/lib/goto-function.sh"

if declare -f goto > /dev/null; then
    echo "  ✓ goto function loaded"
else
    echo "  ✗ goto function not loaded"
    exit 1
fi

# Check if benchmark subcommand is in goto
if grep -q "benchmark|bench" "$REPO_DIR/lib/goto-function.sh"; then
    echo "  ✓ benchmark subcommand integrated into goto"
else
    echo "  ✗ benchmark subcommand not found in goto"
    exit 1
fi
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    ALL TESTS PASSED ✓                            ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Benchmark functionality is working correctly!"
echo ""
echo "Try it out:"
echo "  goto benchmark --help"
echo "  benchmark-goto all"
echo ""
echo "Cleaning up test files..."
rm -rf "$HOME/.goto_benchmarks"
echo "✓ Test cleanup complete"
echo ""
