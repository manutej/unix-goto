#!/bin/bash
# Directory lookup performance benchmark
# Measures navigation performance under various conditions
# Target: <100ms for cached lookups

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

# Load benchmark helpers
source "$SCRIPT_DIR/bench-helpers.sh"

# Load unix-goto functions
source "$REPO_DIR/lib/goto-function.sh"
source "$REPO_DIR/lib/bookmark-command.sh"

# Configuration
BENCHMARK_TARGET_MS=100

main() {
    bench_header "Directory Lookup Performance Benchmark"

    echo "Target Performance: <${BENCHMARK_TARGET_MS}ms"
    echo "Iterations: $BENCH_ITERATIONS"
    echo "Warmup runs: $BENCH_WARMUP_RUNS"
    echo ""

    # Run benchmark suites
    benchmark_find_command
    benchmark_cached_vs_uncached
    benchmark_workspace_sizes
    benchmark_depth_levels
    benchmark_bookmark_lookup

    # Generate summary
    generate_summary
}

# Benchmark 1: Raw find command performance
benchmark_find_command() {
    bench_section "Benchmark 1: Raw find Command Performance"

    local workspace=$(bench_create_workspace "medium")
    local target_dir="project-25"

    echo "Workspace: $workspace (50 projects)"
    echo "Target: $target_dir"
    echo ""

    # Warmup
    echo "Warming up..."
    bench_warmup "find '$workspace' -maxdepth 2 -type d -name '$target_dir'" 3

    # Run benchmark
    local stats=$(bench_run "find_command" "find '$workspace' -maxdepth 2 -type d -name '$target_dir'")

    IFS=',' read -r min max mean median stddev <<< "$stats"

    echo ""
    bench_print_stats "$stats" "Find Command Results"
    echo ""

    bench_assert_target "$mean" "$BENCHMARK_TARGET_MS" "Find command mean time"

    bench_cleanup_workspace "$workspace"
}

# Benchmark 2: Cached vs Uncached lookup
benchmark_cached_vs_uncached() {
    bench_section "Benchmark 2: Cached vs Uncached Lookup"

    local workspace=$(bench_create_workspace "medium")
    local target_dir="project-30"

    echo "Workspace: $workspace (50 projects)"
    echo ""

    # Uncached lookup
    echo "Phase 1: Uncached (Cold Cache)"
    echo "─────────────────────────────────"

    local uncached_times=()
    for i in $(seq 1 $BENCH_ITERATIONS); do
        # Clear cache before each run
        rm -f /tmp/goto-cache-test 2>/dev/null

        local duration=$(bench_time_ms find "$workspace" -maxdepth 2 -type d -name "$target_dir")
        uncached_times+=($duration)
        printf "  Run %2d: %sms\n" "$i" "$duration"
    done

    local uncached_stats=$(bench_calculate_stats "${uncached_times[@]}")
    IFS=',' read -r unc_min unc_max unc_mean unc_median unc_stddev <<< "$uncached_stats"

    echo ""
    bench_print_stats "$uncached_stats" "Uncached Results"

    # Cached lookup (simulate with grep on pre-built index)
    echo ""
    echo "Phase 2: Cached (Warm Cache)"
    echo "─────────────────────────────────"

    # Build a simple cache file
    find "$workspace" -maxdepth 2 -type d > /tmp/goto-cache-test

    local cached_times=()
    for i in $(seq 1 $BENCH_ITERATIONS); do
        local duration=$(bench_time_ms grep -m1 "$target_dir" /tmp/goto-cache-test)
        cached_times+=($duration)
        printf "  Run %2d: %sms\n" "$i" "$duration"
    done

    local cached_stats=$(bench_calculate_stats "${cached_times[@]}")
    IFS=',' read -r cac_min cac_max cac_mean cac_median cac_stddev <<< "$cached_stats"

    echo ""
    bench_print_stats "$cached_stats" "Cached Results"

    # Calculate speedup
    echo ""
    echo "Performance Comparison:"
    bench_result "Uncached mean" "$unc_mean"
    bench_result "Cached mean" "$cac_mean"

    local speedup=$(bench_compare "$unc_mean" "$cac_mean")
    bench_result "Speedup" "$speedup" ""

    echo ""
    bench_assert_target "$cac_mean" "$BENCHMARK_TARGET_MS" "Cached lookup mean time"

    # Save results
    bench_save_result "cached_vs_uncached" "uncached" "$uncached_stats"
    bench_save_result "cached_vs_uncached" "cached" "$cached_stats"

    rm -f /tmp/goto-cache-test
    bench_cleanup_workspace "$workspace"
}

# Benchmark 3: Different workspace sizes
benchmark_workspace_sizes() {
    bench_section "Benchmark 3: Workspace Size Impact"

    local sizes=("small:10" "medium:50" "large:100")

    for size_spec in "${sizes[@]}"; do
        IFS=':' read -r size_name size_count <<< "$size_spec"

        echo ""
        echo "Testing $size_name workspace ($size_count projects)"
        echo "───────────────────────────────────────────"

        local workspace=$(bench_create_workspace "$size_name")
        local target="project-5"

        # Build cache
        find "$workspace" -maxdepth 2 -type d > /tmp/goto-cache-size-test

        local times=()
        for i in $(seq 1 5); do
            local duration=$(bench_time_ms grep -m1 "$target" /tmp/goto-cache-size-test)
            times+=($duration)
        done

        local stats=$(bench_calculate_stats "${times[@]}")
        IFS=',' read -r min max mean median stddev <<< "$stats"

        bench_result "Min" "$min"
        bench_result "Max" "$max"
        bench_result "Mean" "$mean"
        bench_result "Median" "$median"

        bench_assert_target "$mean" "$BENCHMARK_TARGET_MS" "$size_name workspace"

        bench_save_result "workspace_size" "$size_name" "$stats" "count=$size_count"

        rm -f /tmp/goto-cache-size-test
        bench_cleanup_workspace "$workspace"
    done
}

# Benchmark 4: Search depth levels
benchmark_depth_levels() {
    bench_section "Benchmark 4: Search Depth Impact"

    local workspace=$(bench_create_workspace "medium")

    for depth in 1 2 3; do
        echo ""
        echo "Testing depth level $depth"
        echo "───────────────────────────────"

        local times=()
        for i in $(seq 1 5); do
            local duration=$(bench_time_ms find "$workspace" -maxdepth "$depth" -type d -name "project-*")
            times+=($duration)
        done

        local stats=$(bench_calculate_stats "${times[@]}")
        IFS=',' read -r min max mean median stddev <<< "$stats"

        bench_result "Mean" "$mean"
        bench_result "Median" "$median"

        bench_save_result "search_depth" "depth_$depth" "$stats"
    done

    bench_cleanup_workspace "$workspace"
}

# Benchmark 5: Bookmark lookup performance
benchmark_bookmark_lookup() {
    bench_section "Benchmark 5: Bookmark Lookup Performance"

    # Set up test bookmarks
    export GOTO_BOOKMARKS_FILE="/tmp/goto-bench-bookmarks"
    > "$GOTO_BOOKMARKS_FILE"

    # Create test bookmarks
    for i in $(seq 1 20); do
        echo "bookmark$i|/tmp/test/path-$i|$(date +%s)" >> "$GOTO_BOOKMARKS_FILE"
    done

    echo "Testing bookmark retrieval (20 bookmarks)"
    echo ""

    # Benchmark bookmark get
    local times=()
    for i in $(seq 1 $BENCH_ITERATIONS); do
        local duration=$(bench_time_ms __goto_bookmark_get "bookmark10")
        times+=($duration)
    done

    local stats=$(bench_calculate_stats "${times[@]}")
    IFS=',' read -r min max mean median stddev <<< "$stats"

    bench_print_stats "$stats" "Bookmark Lookup Results"

    echo ""
    bench_assert_target "$mean" 10 "Bookmark lookup mean time (target: <10ms)"

    bench_save_result "bookmark_lookup" "get" "$stats" "count=20"

    rm -f "$GOTO_BOOKMARKS_FILE"
}

# Generate summary report
generate_summary() {
    bench_section "BENCHMARK SUMMARY"

    local results_file="$BENCH_RESULTS_DIR/benchmark-results.csv"

    if [ ! -f "$results_file" ]; then
        echo "No results file found"
        return
    fi

    echo ""
    echo "All benchmark results saved to:"
    echo "  $results_file"
    echo ""

    # Show recent results
    echo "Recent Results:"
    echo ""
    tail -5 "$results_file" | while IFS=',' read -r timestamp name operation min max mean median stddev metadata; do
        if [ "$timestamp" != "timestamp" ]; then
            printf "  %-25s %-15s Mean: %4sms\n" "$name" "$operation" "$mean"
        fi
    done

    echo ""
    echo "Target Performance: <${BENCHMARK_TARGET_MS}ms for cached lookups"
    echo ""
}

# Run main
main
exit 0
