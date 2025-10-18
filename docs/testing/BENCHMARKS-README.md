# unix-goto Performance Benchmarks

Comprehensive benchmark suite for measuring and tracking unix-goto performance.

## Overview

The benchmark suite measures:

- **Directory lookup performance**: <100ms target for cached navigation
- **Cache effectiveness**: Hit rates and speedup measurements
- **Workspace scalability**: Performance across different directory tree sizes
- **Search depth impact**: Performance vs. directory nesting levels
- **Bookmark lookup speed**: <10ms target for bookmark retrieval

## Performance Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Cached navigation | <100ms | Sub-100ms feels instant to users |
| Bookmark lookup | <10ms | Bookmarks should be near-instant |
| Cache speedup | >20x | Significant improvement over uncached |
| Cache hit rate | >90% | Most lookups should hit cache |

## Benchmark Structure

```
benchmarks/
├── bench-helpers.sh              # Reusable benchmark utilities (DRY)
├── run-benchmarks.sh             # Benchmark runner
├── bench-directory-lookup.sh     # Directory lookup benchmarks
├── results/                      # CSV results storage
│   └── benchmark-results.csv
└── reports/                      # Generated reports
    └── benchmark-report-*.txt
```

## Running Benchmarks

### Run All Benchmarks

```bash
./benchmarks/run-benchmarks.sh --all
```

### Run Specific Benchmark

```bash
./benchmarks/run-benchmarks.sh directory-lookup
```

### Configure Iterations

```bash
./benchmarks/run-benchmarks.sh -i 20 directory-lookup  # 20 iterations
./benchmarks/run-benchmarks.sh -w 5 directory-lookup   # 5 warmup runs
```

### Generate Report Only

```bash
./benchmarks/run-benchmarks.sh --report
```

## Benchmark Suites

### 1. Directory Lookup Performance

**File**: `bench-directory-lookup.sh`

Measures five key performance areas:

#### 1.1 Raw Find Command Performance

Tests baseline `find` command performance:

```bash
find workspace -maxdepth 2 -type d -name "target"
```

**Configuration**:
- Workspace: 50 projects
- Iterations: 10
- Warmup: 3 runs

**Target**: <100ms mean time

#### 1.2 Cached vs Uncached Lookup

Compares cold cache vs warm cache performance:

- **Uncached**: Full directory tree scan
- **Cached**: Grep-based index lookup

**Metrics**:
- Mean time for both scenarios
- Speedup calculation
- Cache effectiveness

**Target**: >20x speedup from caching

#### 1.3 Workspace Size Impact

Tests performance across different workspace sizes:

- **Small**: 10 projects
- **Medium**: 50 projects
- **Large**: 100 projects

**Analysis**: Performance degradation as workspace grows

#### 1.4 Search Depth Impact

Measures performance at different directory depths:

- Depth 1: Immediate children only
- Depth 2: Two levels deep (typical)
- Depth 3: Three levels deep

**Analysis**: Time complexity vs depth

#### 1.5 Bookmark Lookup Performance

Tests bookmark retrieval speed with 20 bookmarks:

```bash
__goto_bookmark_get "bookmark10"
```

**Target**: <10ms mean time

## Benchmark Results Format

Results are stored in CSV format:

```
timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata
```

### Example Results

```csv
1704123456,cached_vs_uncached,uncached,25,32,28,28,2.1,
1704123456,cached_vs_uncached,cached,15,22,18,19,1.8,
1704123456,workspace_size,small,14,18,16,16,1.2,count=10
1704123456,workspace_size,medium,16,24,19,19,2.3,count=50
```

## Interpreting Results

### Example Output

```
╔══════════════════════════════════════════════════════════════════╗
║  Directory Lookup Performance Benchmark                          ║
╚══════════════════════════════════════════════════════════════════╝

Target Performance: <100ms
Iterations: 10
Warmup runs: 3

Benchmark 2: Cached vs Uncached Lookup
─────────────────────────────────────────────────────────────────

Phase 1: Uncached (Cold Cache)
─────────────────────────────────
  Run  1: 27ms
  Run  2: 28ms
  ...
  Run 10: 28ms

Uncached Results:
  Min:                                             27ms
  Max:                                             30ms
  Mean:                                            28ms
  Median:                                          28ms
  Std Dev:                                       0.89ms

Phase 2: Cached (Warm Cache)
─────────────────────────────────
  Run  1: 18ms
  ...
  Run 10: 20ms

Cached Results:
  Min:                                             18ms
  Max:                                             20ms
  Mean:                                            18ms
  Median:                                          19ms
  Std Dev:                                       1.00ms

Performance Comparison:
  Uncached mean:                                   28ms
  Cached mean:                                     18ms
  Speedup:                                      1.55x

✓ Cached lookup mean time: 18ms (target: <100ms)
```

### Key Metrics

- **Min/Max**: Range of execution times
- **Mean**: Average performance (primary metric)
- **Median**: Middle value (less affected by outliers)
- **Std Dev**: Consistency (lower is better)
- **Speedup**: Relative improvement (higher is better)

## Benchmark Helpers API

The `bench-helpers.sh` module provides reusable utilities:

### Timing Functions

```bash
bench_time_ms command args        # High-precision timing (milliseconds)
```

### Statistics

```bash
bench_calculate_stats value1 value2 ...  # Returns: min,max,mean,median,stddev
bench_compare baseline optimized         # Calculate speedup
```

### Workspace Management

```bash
bench_create_workspace "small|medium|large|xlarge"   # Create test workspace
bench_cleanup_workspace "/path/to/workspace"         # Remove workspace
```

### Output Formatting

```bash
bench_header "Title"                      # Print benchmark header
bench_section "Section Title"             # Print section header
bench_result "Label" "value" "unit"       # Print result line
bench_print_stats "csv_stats" "Label"     # Print statistics block
```

### Results Management

```bash
bench_init                                # Initialize results directory
bench_save_result "name" "op" "stats"     # Save to CSV
bench_assert_target actual target label   # Assert performance target
```

## Creating Custom Benchmarks

### Template

```bash
#!/bin/bash
# Description of benchmark

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/your-module.sh"

main() {
    bench_header "Your Benchmark Title"

    echo "Configuration: ..."
    echo ""

    benchmark_your_feature

    generate_summary
}

benchmark_your_feature() {
    bench_section "Your Benchmark Section"

    # Setup
    local workspace=$(bench_create_workspace "medium")

    # Warmup
    bench_warmup "your_command" 3

    # Run benchmark
    local stats=$(bench_run "benchmark_name" "your_command" 10)

    # Extract statistics
    IFS=',' read -r min max mean median stddev <<< "$stats"

    # Print results
    bench_print_stats "$stats" "Results"

    # Assert target
    bench_assert_target "$mean" 100 "Mean time"

    # Cleanup
    bench_cleanup_workspace "$workspace"
}

main
exit 0
```

## Best Practices

1. **Warmup**: Always run warmup iterations to reduce noise
2. **Sample size**: Use at least 10 iterations for statistical validity
3. **Isolation**: Run benchmarks on idle system
4. **Consistency**: Use same configuration for comparisons
5. **Documentation**: Document what each benchmark measures

## CI/CD Integration

### Regression Testing

Track performance over time:

```bash
# Run benchmarks and save results
./benchmarks/run-benchmarks.sh --all

# Compare with baseline
./benchmarks/compare-baseline.sh
```

### Performance Gates

Fail CI if performance degrades:

```bash
#!/bin/bash
./benchmarks/run-benchmarks.sh directory-lookup

# Check if results meet targets
mean=$(tail -1 ~/.goto_benchmarks/results/benchmark-results.csv | cut -d',' -f6)

if [ "$mean" -gt 100 ]; then
    echo "Performance regression: ${mean}ms exceeds 100ms target"
    exit 1
fi
```

## Sample Benchmark Session

```bash
$ ./benchmarks/run-benchmarks.sh --all

╔══════════════════════════════════════════════════════════════════╗
║           UNIX-GOTO BENCHMARK SUITE                              ║
╚══════════════════════════════════════════════════════════════════╝

Running 1 benchmark(s)...
Configuration: iterations=10, warmup=3

[... benchmark execution ...]

╔══════════════════════════════════════════════════════════════════╗
║           BENCHMARK EXECUTION SUMMARY                            ║
╚══════════════════════════════════════════════════════════════════╝

  Total benchmarks: 1
  Completed: 1
  Failed: 0

  ALL BENCHMARKS COMPLETED SUCCESSFULLY

Results saved to: /Users/you/.goto_benchmarks/results

Generate full report with: ./benchmarks/run-benchmarks.sh --report
```

## Analyzing Results

### View Recent Results

```bash
tail -20 ~/.goto_benchmarks/results/benchmark-results.csv
```

### Generate Report

```bash
./benchmarks/run-benchmarks.sh --report
```

### Compare Configurations

```bash
# Baseline
./benchmarks/run-benchmarks.sh -i 10 directory-lookup

# With optimization
export OPTIMIZATION_FLAG=true
./benchmarks/run-benchmarks.sh -i 10 directory-lookup

# Compare results
diff baseline.csv optimized.csv
```

## Troubleshooting

### High Variance in Results

- Close background applications
- Run more iterations
- Increase warmup runs
- Check system load

### Unrealistic Results

- Verify workspace setup
- Check command correctness
- Review timing implementation

### Missing Dependencies

Benchmarks use only built-in tools:
- `find`, `grep`, `date`
- Python 3 (for high-precision timing)
- Standard Unix utilities

## Performance History

Track performance over time by saving benchmark results:

```bash
# Tag results with version
./benchmarks/run-benchmarks.sh --all > results-v1.0.txt

# Compare with previous version
diff results-v1.0.txt results-v1.1.txt
```

## Future Enhancements

- Automated performance regression detection
- Comparison with alternative tools (autojump, z, etc.)
- Memory usage benchmarks
- Parallel search performance
- Real-world workload simulations
