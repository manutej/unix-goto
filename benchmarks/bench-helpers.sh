#!/bin/bash
# Benchmark helpers for unix-goto
# Provides timing utilities and statistics calculations (DRY principle)

# Benchmark configuration
BENCH_WARMUP_RUNS="${BENCH_WARMUP_RUNS:-3}"
BENCH_ITERATIONS="${BENCH_ITERATIONS:-10}"
BENCH_RESULTS_DIR="${BENCH_RESULTS_DIR:-$HOME/.goto_benchmarks/results}"

# High-precision timer
bench_time_ms() {
    local start_us end_us duration_ms

    if command -v python3 &>/dev/null; then
        # Microsecond precision using Python
        start_us=$(python3 -c "import time; print(int(time.time() * 1000000))")
        "$@" >/dev/null 2>&1
        end_us=$(python3 -c "import time; print(int(time.time() * 1000000))")
        duration_ms=$(( (end_us - start_us) / 1000 ))
    else
        # Fallback to milliseconds
        start_us=$(date +%s%3N 2>/dev/null || echo "0")
        "$@" >/dev/null 2>&1
        end_us=$(date +%s%3N 2>/dev/null || echo "0")
        duration_ms=$((end_us - start_us))
    fi

    echo "$duration_ms"
}

# Calculate statistics from array of values
bench_calculate_stats() {
    local values=("$@")
    local count=${#values[@]}

    if [ $count -eq 0 ]; then
        echo "0,0,0,0,0"
        return
    fi

    # Sort values
    local sorted=($(printf '%s\n' "${values[@]}" | sort -n))

    # Calculate min, max
    local min=${sorted[0]}
    local max=${sorted[$((count - 1))]}

    # Calculate mean
    local sum=0
    for val in "${values[@]}"; do
        sum=$((sum + val))
    done
    local mean=$((sum / count))

    # Calculate median
    local median_idx=$((count / 2))
    local median=${sorted[$median_idx]}

    # Calculate standard deviation (simplified)
    local variance_sum=0
    for val in "${values[@]}"; do
        local diff=$((val - mean))
        variance_sum=$((variance_sum + diff * diff))
    done
    local variance=$((variance_sum / count))

    # Calculate sqrt with bc fallback to awk
    local stddev
    if command -v bc >/dev/null 2>&1; then
        stddev=$(echo "scale=2; sqrt($variance)" | bc 2>/dev/null)
    elif command -v awk >/dev/null 2>&1; then
        stddev=$(awk -v var="$variance" 'BEGIN { printf "%.2f", sqrt(var) }')
    else
        stddev="0"
    fi

    echo "$min,$max,$mean,$median,$stddev"
}

# Format duration for display
bench_format_duration() {
    local ms="$1"

    if [ $ms -lt 1000 ]; then
        echo "${ms}ms"
    elif [ $ms -lt 60000 ]; then
        local seconds=$(echo "scale=2; $ms / 1000" | bc)
        echo "${seconds}s"
    else
        local minutes=$(echo "scale=2; $ms / 60000" | bc)
        echo "${minutes}m"
    fi
}

# Compare two benchmarks and calculate speedup
bench_compare() {
    local baseline_ms="$1"
    local optimized_ms="$2"

    if [ $optimized_ms -eq 0 ]; then
        echo "∞"
        return
    fi

    local speedup=$(echo "scale=2; $baseline_ms / $optimized_ms" | bc)
    echo "${speedup}x"
}

# Print benchmark header
bench_header() {
    local title="$1"

    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    printf "║  %-62s  ║\n" "$title"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Print benchmark section
bench_section() {
    local title="$1"

    echo ""
    echo "$title"
    echo "─────────────────────────────────────────────────────────────────"
}

# Print benchmark result
bench_result() {
    local label="$1"
    local value="$2"
    local unit="${3:-ms}"

    printf "  %-40s %10s%s\n" "$label:" "$value" "$unit"
}

# Print comparison result with status
bench_result_compare() {
    local label="$1"
    local value="$2"
    local target="$3"
    local unit="${4:-ms}"

    local status=""
    if [ $value -le $target ]; then
        status="✓"
    else
        status="✗"
    fi

    printf "  %-40s %10s%s  [%s]\n" "$label:" "$value" "$unit" "$status"
}

# Initialize benchmark results directory
bench_init() {
    mkdir -p "$BENCH_RESULTS_DIR"

    local results_file="$BENCH_RESULTS_DIR/benchmark-results.csv"

    if [ ! -f "$results_file" ]; then
        echo "timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata" > "$results_file"
    fi
}

# Save benchmark results
bench_save_result() {
    local benchmark_name="$1"
    local operation="$2"
    local stats="$3"
    local metadata="${4:-}"

    bench_init

    local timestamp=$(date +%s)
    local results_file="$BENCH_RESULTS_DIR/benchmark-results.csv"

    echo "$timestamp,$benchmark_name,$operation,$stats,$metadata" >> "$results_file"
}

# Run warmup iterations
bench_warmup() {
    local cmd="$1"
    local warmup_runs="${2:-$BENCH_WARMUP_RUNS}"

    for i in $(seq 1 $warmup_runs); do
        eval "$cmd" >/dev/null 2>&1
    done
}

# Run benchmark iterations and collect results
bench_run() {
    local name="$1"
    local cmd="$2"
    local iterations="${3:-$BENCH_ITERATIONS}"

    local times=()

    echo "Running $iterations iterations..."

    for i in $(seq 1 $iterations); do
        local duration=$(bench_time_ms eval "$cmd")
        times+=($duration)
        printf "  Run %2d: %sms\n" "$i" "$duration"
    done

    # Calculate statistics
    local stats=$(bench_calculate_stats "${times[@]}")

    # Save results
    bench_save_result "$name" "benchmark" "$stats"

    echo ""
    echo "$stats"
}

# Print statistics from CSV format
bench_print_stats() {
    local stats="$1"
    local label="${2:-Results}"

    IFS=',' read -r min max mean median stddev <<< "$stats"

    echo "$label:"
    bench_result "Min" "$min"
    bench_result "Max" "$max"
    bench_result "Mean" "$mean"
    bench_result "Median" "$median"
    bench_result "Std Dev" "$stddev"
}

# Create test workspace with specified number of directories
bench_create_workspace() {
    local size="$1"
    local base_dir="${2:-/tmp/goto-bench-workspace}"

    rm -rf "$base_dir"
    mkdir -p "$base_dir"

    local dir_count=0

    case "$size" in
        small)
            dir_count=10
            ;;
        medium)
            dir_count=50
            ;;
        large)
            dir_count=100
            ;;
        xlarge)
            dir_count=500
            ;;
        *)
            dir_count=50
            ;;
    esac

    # Create nested directory structure
    for i in $(seq 1 $dir_count); do
        mkdir -p "$base_dir/project-$i/src/components"
        mkdir -p "$base_dir/project-$i/docs"
        mkdir -p "$base_dir/project-$i/tests"
    done

    echo "$base_dir"
}

# Clean up test workspace
bench_cleanup_workspace() {
    local base_dir="${1:-/tmp/goto-bench-workspace}"

    if [ -d "$base_dir" ]; then
        rm -rf "$base_dir"
    fi
}

# Assert benchmark meets target
bench_assert_target() {
    local actual="$1"
    local target="$2"
    local label="$3"

    if [ $actual -le $target ]; then
        echo "✓ $label: ${actual}ms (target: <${target}ms)"
        return 0
    else
        echo "✗ $label: ${actual}ms (target: <${target}ms) - FAILED"
        return 1
    fi
}
