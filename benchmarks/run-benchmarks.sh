#!/bin/bash
# Benchmark runner for unix-goto
# Runs all performance benchmarks and generates reports

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

# Load helpers
source "$SCRIPT_DIR/bench-helpers.sh"

# Configuration
RUN_ALL=0
GENERATE_REPORT=0
BENCHMARK_LIST=()

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            RUN_ALL=1
            shift
            ;;
        -r|--report)
            GENERATE_REPORT=1
            shift
            ;;
        -i|--iterations)
            BENCH_ITERATIONS="$2"
            shift 2
            ;;
        -w|--warmup)
            BENCH_WARMUP_RUNS="$2"
            shift 2
            ;;
        -h|--help)
            echo "unix-goto benchmark runner"
            echo ""
            echo "Usage: $0 [options] [benchmarks...]"
            echo ""
            echo "Options:"
            echo "  -a, --all                Run all benchmarks"
            echo "  -r, --report             Generate report only (no benchmarks)"
            echo "  -i, --iterations N       Number of iterations (default: 10)"
            echo "  -w, --warmup N           Number of warmup runs (default: 3)"
            echo "  -h, --help               Show this help"
            echo ""
            echo "Available benchmarks:"
            echo "  directory-lookup         Directory lookup performance"
            echo "  cache-performance        Cache hit rate and build time"
            echo "  comparison               Compare with native cd"
            echo ""
            echo "Examples:"
            echo "  $0 --all                           # Run all benchmarks"
            echo "  $0 directory-lookup                # Run specific benchmark"
            echo "  $0 -i 20 directory-lookup          # 20 iterations"
            echo "  $0 --report                        # Generate report only"
            exit 0
            ;;
        *)
            BENCHMARK_LIST+=("$1")
            shift
            ;;
    esac
done

# Export configuration
export BENCH_ITERATIONS
export BENCH_WARMUP_RUNS

# Find available benchmarks
find_benchmarks() {
    find "$SCRIPT_DIR" -name "bench-*.sh" -type f ! -name "bench-helpers.sh" | sort
}

# Run a single benchmark
run_benchmark() {
    local bench_file="$1"
    local bench_name=$(basename "$bench_file" .sh | sed 's/^bench-//')

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Running: $bench_name"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    bash "$bench_file"
    return $?
}

# Generate comprehensive report
generate_comprehensive_report() {
    bench_header "COMPREHENSIVE BENCHMARK REPORT"

    local results_file="$BENCH_RESULTS_DIR/benchmark-results.csv"

    if [ ! -f "$results_file" ]; then
        echo "No benchmark results found."
        echo "Run benchmarks first with: $0 --all"
        return 1
    fi

    # System information
    echo "System Information:"
    echo "─────────────────────────────────────────────────────────────"
    bench_result "OS" "$(uname -s)" ""
    bench_result "Version" "$(uname -r)" ""
    bench_result "Shell" "$SHELL" ""
    bench_result "Date" "$(date '+%Y-%m-%d %H:%M:%S')" ""
    echo ""

    # Configuration
    echo "Benchmark Configuration:"
    echo "─────────────────────────────────────────────────────────────"
    bench_result "Iterations" "$BENCH_ITERATIONS" ""
    bench_result "Warmup runs" "$BENCH_WARMUP_RUNS" ""
    bench_result "Results directory" "$BENCH_RESULTS_DIR" ""
    echo ""

    # Performance targets
    echo "Performance Targets:"
    echo "─────────────────────────────────────────────────────────────"
    bench_result "Cached navigation" "<100ms" ""
    bench_result "Bookmark lookup" "<10ms" ""
    bench_result "Cache speedup" ">20x" ""
    echo ""

    # Summary by benchmark type
    echo "Results by Benchmark Type:"
    echo "─────────────────────────────────────────────────────────────"

    local current_benchmark=""
    tail -n +2 "$results_file" | while IFS=',' read -r timestamp name operation min max mean median stddev metadata; do
        if [ "$name" != "$current_benchmark" ]; then
            echo ""
            echo "$name:"
            current_benchmark="$name"
        fi

        printf "  %-20s Min: %4sms  Max: %4sms  Mean: %4sms  Median: %4sms\n" \
            "$operation" "$min" "$max" "$mean" "$median"
    done

    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "Full results: $results_file"
    echo ""

    # Save report
    local report_file="$BENCH_RESULTS_DIR/../reports/benchmark-report-$(date +%Y%m%d-%H%M%S).txt"
    mkdir -p "$(dirname "$report_file")"

    generate_comprehensive_report > "$report_file" 2>&1

    echo "Report saved to: $report_file"
}

# Main execution
main() {
    bench_init

    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           UNIX-GOTO BENCHMARK SUITE                              ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""

    # Report only mode
    if [ $GENERATE_REPORT -eq 1 ]; then
        generate_comprehensive_report
        return 0
    fi

    # Collect benchmarks to run
    local benchmarks_to_run=()

    if [ $RUN_ALL -eq 1 ]; then
        while IFS= read -r bench_file; do
            benchmarks_to_run+=("$bench_file")
        done < <(find_benchmarks)
    elif [ ${#BENCHMARK_LIST[@]} -gt 0 ]; then
        for bench_name in "${BENCHMARK_LIST[@]}"; do
            local bench_file="$SCRIPT_DIR/bench-${bench_name}.sh"
            if [ -f "$bench_file" ]; then
                benchmarks_to_run+=("$bench_file")
            else
                echo "Warning: Benchmark not found: $bench_name"
            fi
        done
    else
        echo "No benchmarks specified."
        echo "Use --all to run all benchmarks, or specify benchmark names."
        echo "Use --help for more information."
        exit 1
    fi

    # Run benchmarks
    local total=${#benchmarks_to_run[@]}
    local passed=0
    local failed=0

    echo "Running $total benchmark(s)..."
    echo "Configuration: iterations=$BENCH_ITERATIONS, warmup=$BENCH_WARMUP_RUNS"
    echo ""

    for bench_file in "${benchmarks_to_run[@]}"; do
        if run_benchmark "$bench_file"; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
    done

    # Final summary
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           BENCHMARK EXECUTION SUMMARY                            ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Total benchmarks: $total"
    echo "  Completed: $passed"
    echo "  Failed: $failed"
    echo ""

    if [ $failed -eq 0 ]; then
        echo "  ALL BENCHMARKS COMPLETED SUCCESSFULLY"
    else
        echo "  SOME BENCHMARKS FAILED"
    fi

    echo ""
    echo "Results saved to: $BENCH_RESULTS_DIR"
    echo ""
    echo "Generate full report with: $0 --report"
    echo ""
}

# Run main
main
exit $?
