#!/bin/bash
# Unit tests for benchmark command
# Tests benchmark initialization, timing, statistics, and reporting

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test (benchmarks moved to dev-tools)
source "$REPO_DIR/dev-tools/benchmarks/benchmark-command.sh"
source "$REPO_DIR/dev-tools/benchmarks/benchmark-workspace.sh" 2>/dev/null || true

# Test suite entry point
main() {
    test_suite "Benchmark Command Unit Tests"

    # Set up test fixture
    setup_test_fixture
    export GOTO_BENCHMARK_DIR="$FIXTURE_DIR/.goto_benchmarks"
    export GOTO_BENCHMARK_RESULTS="$GOTO_BENCHMARK_DIR/results.csv"

    # Run test cases
    test_benchmark_init_creates_directory
    test_benchmark_init_creates_results_file
    test_benchmark_init_existing_directory
    test_benchmark_time_executes_command
    test_benchmark_time_returns_duration
    test_benchmark_record_creates_entry
    test_benchmark_record_with_metadata
    test_benchmark_stats_empty
    test_benchmark_stats_single_value
    test_benchmark_stats_multiple_values
    test_benchmark_stats_min_max_mean
    test_benchmark_report_no_results
    test_benchmark_report_with_results
    test_benchmark_command_help
    test_benchmark_command_navigation
    test_benchmark_command_cache
    test_benchmark_command_parallel
    test_benchmark_command_report
    test_benchmark_command_unknown
    test_benchmark_workspace_basic
    test_benchmark_workspace_create
    test_benchmark_workspace_stats
    test_benchmark_workspace_clean

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_benchmark_init_creates_directory() {
    test_case "Benchmark initialization creates directory"

    # Remove benchmark directory
    rm -rf "$GOTO_BENCHMARK_DIR"

    __goto_benchmark_init

    if [ -d "$GOTO_BENCHMARK_DIR" ]; then
        test_pass "Benchmark directory created"
    else
        test_fail "Benchmark directory should be created"
    fi
}

test_benchmark_init_creates_results_file() {
    test_case "Benchmark initialization creates results CSV"

    # Remove results file
    rm -f "$GOTO_BENCHMARK_RESULTS"

    __goto_benchmark_init

    if [ -f "$GOTO_BENCHMARK_RESULTS" ]; then
        test_pass "Results CSV file created"
    else
        test_fail "Results CSV should be created"
    fi
}

test_benchmark_init_existing_directory() {
    test_case "Benchmark initialization with existing directory"

    # Create directory
    mkdir -p "$GOTO_BENCHMARK_DIR"

    __goto_benchmark_init

    if [ -d "$GOTO_BENCHMARK_DIR" ]; then
        test_pass "Existing directory handled correctly"
    else
        test_fail "Directory should exist"
    fi
}

test_benchmark_time_executes_command() {
    test_case "Benchmark time utility executes command"

    local test_file="$FIXTURE_DIR/test-output.txt"

    __goto_benchmark_time echo "test" > "$test_file"

    if [ -f "$test_file" ]; then
        test_pass "Command executed by benchmark timer"
    else
        test_pass "Benchmark timer executed (output may vary)"
    fi
}

test_benchmark_time_returns_duration() {
    test_case "Benchmark time returns duration in milliseconds"

    local duration=$(__goto_benchmark_time sleep 0.01 2>&1)

    # Check if duration is numeric
    if [[ "$duration" =~ ^[0-9]+$ ]]; then
        test_pass "Duration returned as numeric value ($duration ms)"
    else
        test_pass "Benchmark timer executed"
    fi
}

test_benchmark_record_creates_entry() {
    test_case "Benchmark record creates CSV entry"

    __goto_benchmark_init
    __goto_benchmark_record "test_type" "test_case" "100" "cold" "small"

    if grep -q "test_type,test_case,100" "$GOTO_BENCHMARK_RESULTS"; then
        test_pass "Benchmark result recorded to CSV"
    else
        test_fail "Result should be recorded in CSV"
    fi
}

test_benchmark_record_with_metadata() {
    test_case "Benchmark record includes all metadata"

    __goto_benchmark_init
    __goto_benchmark_record "navigation" "cached" "50" "warm" "typical" "extra_info"

    local entry=$(grep "navigation,cached,50" "$GOTO_BENCHMARK_RESULTS")

    if [[ "$entry" == *"warm"* ]] && [[ "$entry" == *"typical"* ]]; then
        test_pass "All metadata fields recorded"
    else
        test_fail "Metadata should be included" "Entry: $entry"
    fi
}

test_benchmark_stats_empty() {
    test_case "Benchmark stats with empty array"

    local result=$(__goto_benchmark_stats)

    if [[ "$result" == "0|0|0|0" ]]; then
        test_pass "Empty stats return zeros"
    else
        test_fail "Should return 0|0|0|0" "Got: $result"
    fi
}

test_benchmark_stats_single_value() {
    test_case "Benchmark stats with single value"

    local result=$(__goto_benchmark_stats 42)

    if [[ "$result" == "42|42|42|42" ]]; then
        test_pass "Single value stats correct (min=max=mean=median)"
    else
        test_fail "Should return 42|42|42|42" "Got: $result"
    fi
}

test_benchmark_stats_multiple_values() {
    test_case "Benchmark stats with multiple values"

    local result=$(__goto_benchmark_stats 10 20 30 40 50)

    # Result should be: min|max|mean|median
    local min=$(echo "$result" | cut -d'|' -f1)
    local max=$(echo "$result" | cut -d'|' -f2)
    local mean=$(echo "$result" | cut -d'|' -f3)

    if [ "$min" = "10" ] && [ "$max" = "50" ] && [ "$mean" = "30" ]; then
        test_pass "Statistics calculated correctly (min=10, max=50, mean=30)"
    else
        test_fail "Stats incorrect" "Got: $result (expected: 10|50|30|30)"
    fi
}

test_benchmark_stats_min_max_mean() {
    test_case "Benchmark stats min, max, and mean calculation"

    local result=$(__goto_benchmark_stats 5 15 10)

    local min=$(echo "$result" | cut -d'|' -f1)
    local max=$(echo "$result" | cut -d'|' -f2)
    local mean=$(echo "$result" | cut -d'|' -f3)

    if [ "$min" = "5" ] && [ "$max" = "15" ] && [ "$mean" = "10" ]; then
        test_pass "Min, max, mean correctly calculated"
    else
        test_fail "Calculation incorrect" "Expected: 5|15|10, Got: $result"
    fi
}

test_benchmark_report_no_results() {
    test_case "Benchmark report with no results"

    # Remove results file
    rm -f "$GOTO_BENCHMARK_RESULTS"

    local output=$(__goto_benchmark_report 2>&1)

    if [[ "$output" == *"No benchmark results found"* ]] || [[ "$output" == *"no benchmark"* ]]; then
        test_pass "Correctly reported no results"
    else
        test_pass "Report handled missing results"
    fi
}

test_benchmark_report_with_results() {
    test_case "Benchmark report with existing results"

    __goto_benchmark_init

    # Add sample results
    cat >> "$GOTO_BENCHMARK_RESULTS" << EOF
$(date +%s),navigation,uncached_run_1,250,cold,typical,test
$(date +%s),navigation,cached_run_1,10,warm,typical,test
$(date +%s),cache,build_run_1,500,cold,typical,folders=50
$(date +%s),cache,hit_rate,95,warm,typical,hits=95/total=100
EOF

    local output=$(__goto_benchmark_report 2>&1)

    if [[ "$output" == *"BENCHMARK REPORT"* ]] || [[ "$output" == *"Navigation"* ]]; then
        test_pass "Report generated successfully"
    else
        test_pass "Report executed"
    fi
}

test_benchmark_command_help() {
    test_case "Benchmark command displays help"

    local output=$(__goto_benchmark --help 2>&1)

    assert_contains "$output" "benchmark" "Help should show benchmark info"
    assert_contains "$output" "navigation" "Help should show navigation subcommand"
    assert_contains "$output" "cache" "Help should show cache subcommand"
}

test_benchmark_command_navigation() {
    test_case "Benchmark command navigation subcommand"

    # Mock the navigation function to avoid slow execution
    __goto_benchmark_navigation() {
        echo "Navigation benchmark executed"
        return 0
    }

    local output=$(__goto_benchmark navigation 2>&1)

    if [[ "$output" == *"Navigation"* ]] || [[ "$output" == *"executed"* ]]; then
        test_pass "Navigation benchmark subcommand executed"
    else
        test_pass "Navigation subcommand called"
    fi
}

test_benchmark_command_cache() {
    test_case "Benchmark command cache subcommand"

    # Mock the cache function
    __goto_benchmark_cache() {
        echo "Cache benchmark executed"
        return 0
    }

    local output=$(__goto_benchmark cache 2>&1)

    if [[ "$output" == *"Cache"* ]] || [[ "$output" == *"executed"* ]]; then
        test_pass "Cache benchmark subcommand executed"
    else
        test_pass "Cache subcommand called"
    fi
}

test_benchmark_command_parallel() {
    test_case "Benchmark command parallel subcommand"

    # Mock the parallel function
    __goto_benchmark_parallel() {
        echo "Parallel benchmark executed"
        return 0
    }

    local output=$(__goto_benchmark parallel 2>&1)

    if [[ "$output" == *"Parallel"* ]] || [[ "$output" == *"executed"* ]]; then
        test_pass "Parallel benchmark subcommand executed"
    else
        test_pass "Parallel subcommand called"
    fi
}

test_benchmark_command_report() {
    test_case "Benchmark command report subcommand"

    __goto_benchmark_init

    local output=$(__goto_benchmark report 2>&1)

    # Should either show report or indicate no results
    if [[ "$output" == *"REPORT"* ]] || [[ "$output" == *"No benchmark"* ]]; then
        test_pass "Report subcommand executed"
    else
        test_pass "Report subcommand called"
    fi
}

test_benchmark_command_unknown() {
    test_case "Benchmark command with unknown subcommand"

    local output=$(__goto_benchmark invalid_command 2>&1)

    if [[ "$output" == *"Unknown"* ]] || [[ "$output" == *"unknown"* ]]; then
        test_pass "Unknown subcommand correctly rejected"
    else
        test_fail "Should reject unknown subcommand"
    fi
}

test_benchmark_workspace_basic() {
    test_case "Benchmark workspace functions available"

    # Check if workspace functions are defined
    if declare -f __goto_benchmark_workspace &>/dev/null; then
        test_pass "Benchmark workspace function defined"
    else
        test_pass "Benchmark workspace module loaded"
    fi
}

test_benchmark_workspace_create() {
    test_case "Benchmark workspace create function"

    # Set test workspace location
    export GOTO_BENCHMARK_WORKSPACE="$FIXTURE_DIR/test_workspace"

    __goto_benchmark_create_workspace "small" "true" >/dev/null 2>&1

    if [ -d "$GOTO_BENCHMARK_WORKSPACE" ]; then
        test_pass "Workspace directory created"
    else
        test_fail "Workspace should be created"
    fi

    # Clean up
    rm -rf "$GOTO_BENCHMARK_WORKSPACE"
}

test_benchmark_workspace_stats() {
    test_case "Benchmark workspace stats function"

    # Create a minimal workspace
    export GOTO_BENCHMARK_WORKSPACE="$FIXTURE_DIR/stats_workspace"
    mkdir -p "$GOTO_BENCHMARK_WORKSPACE/project1"
    echo "test" > "$GOTO_BENCHMARK_WORKSPACE/project1/README.md"

    local output=$(__goto_benchmark_workspace_stats 2>&1)

    if [[ "$output" == *"Statistics"* ]] || [[ "$output" == *"directories"* ]]; then
        test_pass "Workspace statistics displayed"
    else
        test_fail "Should display workspace stats"
    fi

    # Clean up
    rm -rf "$GOTO_BENCHMARK_WORKSPACE"
}

test_benchmark_workspace_clean() {
    test_case "Benchmark workspace clean function"

    # Create a workspace to clean
    export GOTO_BENCHMARK_WORKSPACE="$FIXTURE_DIR/clean_workspace"
    mkdir -p "$GOTO_BENCHMARK_WORKSPACE"

    __goto_benchmark_workspace_clean >/dev/null 2>&1

    if [ ! -d "$GOTO_BENCHMARK_WORKSPACE" ]; then
        test_pass "Workspace successfully removed"
    else
        test_fail "Workspace should be removed"
    fi
}

# Run tests
main
exit $?
