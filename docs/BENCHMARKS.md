# unix-goto Performance Benchmarks

**Version:** 0.4.0
**Last Updated:** 2025-10-17
**Feature:** Performance Benchmark Suite (Feature 3.3)

---

## Overview

The unix-goto benchmark suite provides comprehensive performance testing for navigation, caching, and search operations. It measures real-world performance across different workspace sizes and provides actionable insights for optimization.

## Quick Start

```bash
# Run all benchmarks
goto benchmark all

# Run specific benchmarks
goto benchmark navigation
goto benchmark cache
goto benchmark parallel

# Generate report
goto benchmark report

# Standalone execution (no shell reload needed)
benchmark-goto all
```

---

## Performance Targets

Based on IMPLEMENTATION-PLAN.md Feature 3.3 specifications:

| Metric | Target | Purpose |
|--------|--------|---------|
| **Navigation (cached)** | <100ms | Instant folder navigation |
| **Cache hit rate** | >90% | Minimize filesystem scans |
| **Speedup ratio** | 20-50x | Cached vs uncached performance |
| **Cache build time** | <5s | Fast index creation for 500+ folders |

---

## Benchmark Commands

### 1. Navigation Benchmark

Tests folder lookup performance with and without caching.

```bash
# Basic usage
goto benchmark navigation

# Specify target and iterations
goto benchmark navigation unix-goto 10

# Standalone
benchmark-goto navigation unix-goto 10
```

**What it measures:**
- Uncached navigation time (cold start, filesystem scan)
- Cached navigation time (warm start, hash lookup)
- Speedup ratio (uncached/cached)
- Consistency across multiple runs

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║            NAVIGATION PERFORMANCE BENCHMARK                      ║
╚══════════════════════════════════════════════════════════════════╝

Phase 1: Uncached Navigation (Cold Start)
─────────────────────────────────────────────
  Run 1: 1250ms
  Run 2: 1180ms
  Run 3: 1220ms
  ...

Uncached Results:
  Min:    1180ms
  Max:    1250ms
  Mean:   1217ms
  Median: 1220ms

Phase 2: Cached Navigation (Warm Start - Simulated)
────────────────────────────────────────────────────
  Run 1: 45ms
  Run 2: 38ms
  Run 3: 42ms
  ...

Cached Results:
  Min:    38ms
  Max:    45ms
  Mean:   42ms
  Median: 42ms

Performance Improvement:
  Speedup: 28x faster with cache
  Target:  20-50x (as per specifications)
  Status:  ✓ MEETS TARGET

Target: Navigation time <100ms
Status: ✓ MEETS TARGET (42ms)
```

---

### 2. Cache Performance Benchmark

Tests cache building and hit rate performance.

```bash
# Default (typical workspace)
goto benchmark cache

# Specify workspace size
goto benchmark cache small    # 10 folders
goto benchmark cache typical  # 50 folders (default)
goto benchmark cache large    # 200+ folders

# With custom iterations
goto benchmark cache typical 15

# Standalone
benchmark-goto cache large 10
```

**What it measures:**
- Cache build time across different workspace sizes
- Cache hit rate simulation
- Cache efficiency metrics

**Workspace Sizes:**
- **Small:** 10 folders, 2 levels deep
- **Typical:** 50 folders, 3 levels deep (default)
- **Large:** 200+ folders, 4 levels deep

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║              CACHE PERFORMANCE BENCHMARK                         ║
╚══════════════════════════════════════════════════════════════════╝

Workspace Size: typical
Iterations: 10

Test Configuration:
  Workspace type: typical
  Folder count:   50

Phase 1: Cache Build Time
──────────────────────────
  Run 1: 3250ms
  Run 2: 3180ms
  Run 3: 3220ms
  ...

Cache Build Statistics:
  Min:    3180ms
  Max:    3250ms
  Mean:   3217ms
  Median: 3220ms

Phase 2: Cache Hit Rate Test
─────────────────────────────
Performing 100 lookups...

Cache Hit Rate Results:
  Total lookups: 100
  Cache hits:    92
  Hit rate:      92%
  Target:        >90%
  Status:        ✓ MEETS TARGET
```

---

### 3. Parallel Search Benchmark

Compares sequential vs parallel directory search performance.

```bash
# Default iterations
goto benchmark parallel

# Custom iterations
goto benchmark parallel 15

# Standalone
benchmark-goto parallel 10
```

**What it measures:**
- Sequential search time (one path at a time)
- Parallel search time (all paths concurrently)
- Speedup from parallelization

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║           PARALLEL SEARCH PERFORMANCE BENCHMARK                  ║
╚══════════════════════════════════════════════════════════════════╝

Iterations: 10

Search Paths:
  - /Users/manu/ASCIIDocs
  - /Users/manu/Documents/LUXOR
  - /Users/manu/Documents/LUXOR/PROJECTS

Phase 1: Sequential Search
───────────────────────────
  Run 1: 2500ms
  Run 2: 2450ms
  Run 3: 2480ms
  ...

Sequential Search Statistics:
  Min:    2450ms
  Max:    2500ms
  Mean:   2477ms
  Median: 2480ms

Phase 2: Parallel Search (Background Jobs)
────────────────────────────────────────────
  Run 1: 1200ms
  Run 2: 1150ms
  Run 3: 1180ms
  ...

Parallel Search Statistics:
  Min:    1150ms
  Max:    1200ms
  Mean:   1177ms
  Median: 1180ms

Performance Comparison:
  Sequential: 2477ms
  Parallel:   1177ms
  Speedup:    2.10x
  Status:     ✓ PARALLEL IS FASTER
```

---

### 4. Benchmark Report

Generates comprehensive summary of all benchmark results.

```bash
# Generate report
goto benchmark report

# Standalone
benchmark-goto report
```

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║           UNIX-GOTO PERFORMANCE BENCHMARK REPORT                 ║
╚══════════════════════════════════════════════════════════════════╝

System Information:
  OS:           Darwin 23.1.0
  Shell:        /bin/zsh
  Date:         2025-10-17 14:35:22
  Total Runs:   45

Navigation Benchmarks:
──────────────────────
  Uncached (cold):  1217ms
  Cached (warm):    42ms
  Speedup:          28x

Cache Benchmarks:
─────────────────
  Build time:       3217ms
  Hit rate:         92%
  Target:           >90%

Parallel Search Benchmarks:
────────────────────────────
  Sequential:       2477ms
  Parallel:         1177ms
  Speedup:          2.10x

Raw data available at: /Users/manu/.goto_benchmarks/results.csv
```

---

### 5. Test Workspace Management

Create controlled test environments for consistent benchmarking.

```bash
# Create test workspace
goto benchmark workspace create typical

# Show workspace statistics
goto benchmark workspace stats

# Clean up workspace
goto benchmark workspace clean
```

**Workspace Types:**

| Type | Folders | Depth | Use Case |
|------|---------|-------|----------|
| `small` | 10 | 2 levels | Quick tests, CI/CD |
| `typical` | 50 | 3 levels | Standard workspace simulation |
| `large` | 200+ | 4 levels | Stress testing, optimization |

**Output:**
```
Creating typical benchmark workspace...
  Location: /Users/manu/.goto_benchmark_workspace
  Folders:  50
  Depth:    3 levels

Generating folder structure...

✓ Workspace created successfully
  Total folders: 50
  Max depth:     3

Benchmark Workspace Statistics:
────────────────────────────────
  Location: /Users/manu/.goto_benchmark_workspace

  Total directories: 50
  Total files:       75
  Maximum depth:     3
  Disk usage:        256K
```

---

## Complete Benchmark Suite

Run all benchmarks in sequence with a single command:

```bash
# Via goto
goto benchmark all

# Standalone
benchmark-goto all
```

**Process:**
1. Navigation benchmark (5 iterations)
2. Cache performance benchmark (5 iterations)
3. Parallel search benchmark (5 iterations)
4. Generate comprehensive report

**Execution Time:** ~2-5 minutes depending on workspace size

---

## Configuration

### Environment Variables

```bash
# Number of benchmark iterations (default: 10)
export GOTO_BENCHMARK_ITERATIONS=15

# Warmup iterations before measurement (default: 3)
export GOTO_BENCHMARK_WARMUP=5

# Results storage location
export GOTO_BENCHMARK_DIR="$HOME/.goto_benchmarks"
```

### Custom Targets

Edit benchmark targets in `lib/benchmark-command.sh`:

```bash
# Navigation benchmark target folder
__goto_benchmark_navigation "your-folder" 10

# Cache benchmark workspace
__goto_benchmark_cache "large" 10

# Parallel search iterations
__goto_benchmark_parallel 15
```

---

## Results Storage

All benchmark results are stored in CSV format for analysis:

**Location:** `~/.goto_benchmarks/results.csv`

**Format:**
```csv
timestamp,benchmark_type,test_case,duration_ms,cache_status,workspace_size,additional_info
1697558122,navigation,uncached_run_1,1250,cold,typical,unix-goto
1697558123,navigation,cached_run_1,42,warm,typical,unix-goto
1697558124,cache,build_run_1,3217,cold,typical,folder_count=50
1697558125,cache,hit_rate,92,warm,typical,hits=92/total=100
1697558126,parallel,sequential_run_1,2477,cold,typical,paths=3
1697558127,parallel,parallel_run_1,1177,cold,typical,paths=3
```

**Analysis:**
- Import into Excel/Google Sheets for visualization
- Use `awk`, `grep`, or `cut` for command-line analysis
- Track performance trends over time
- Compare before/after optimization changes

---

## Interpretation Guide

### Navigation Benchmarks

**Good Performance:**
- Cached mean <100ms ✓
- Speedup >20x ✓
- Low variance (max-min <50ms) ✓

**Needs Optimization:**
- Cached mean >100ms ⚠
- Speedup <20x ⚠
- High variance (inconsistent performance) ⚠

### Cache Benchmarks

**Good Performance:**
- Hit rate >90% ✓
- Build time <5s for typical workspace ✓

**Needs Optimization:**
- Hit rate <90% ⚠ (cache invalidation issues)
- Build time >5s ⚠ (slow filesystem scans)

### Parallel Search

**Good Performance:**
- Speedup >1.5x ✓
- Lower variance than sequential ✓

**Needs Optimization:**
- Speedup <1.5x ⚠ (overhead costs)
- Parallel slower than sequential ⚠ (too few paths)

---

## Best Practices

### 1. Consistent Testing Environment

```bash
# Close unnecessary applications
# Clear system caches if needed
sudo purge  # macOS only

# Run multiple times and average
for i in {1..3}; do
    benchmark-goto all
done
```

### 2. Baseline Measurement

```bash
# Establish baseline before changes
benchmark-goto all > baseline.txt

# Make optimization changes
# ...

# Re-benchmark and compare
benchmark-goto all > optimized.txt
diff baseline.txt optimized.txt
```

### 3. Workspace-Specific Testing

```bash
# Test with realistic workspace
goto benchmark workspace create typical
goto benchmark navigation

# Test stress scenarios
goto benchmark workspace create large
goto benchmark cache large
```

### 4. CI/CD Integration

```bash
#!/bin/bash
# .github/workflows/benchmark.yml

# Run benchmarks on PR
benchmark-goto all

# Parse results
hit_rate=$(grep "hit_rate" ~/.goto_benchmarks/results.csv | tail -1 | cut -d',' -f4)

# Validate targets
if [ "$hit_rate" -lt 90 ]; then
    echo "Cache hit rate below target: ${hit_rate}%"
    exit 1
fi
```

---

## Troubleshooting

### Benchmark Results Inconsistent

**Cause:** Background processes, disk I/O contention
**Solution:**
```bash
# Increase iterations for better averaging
GOTO_BENCHMARK_ITERATIONS=20 benchmark-goto navigation

# Run during low system load
# Close browsers, Docker, etc.
```

### Cache Build Time Excessive

**Cause:** Large workspace, network mounts, slow disk
**Solution:**
```bash
# Profile with verbose output
time find $HOME/Documents/LUXOR -maxdepth 3 -type d

# Reduce search depth
GOTO_SEARCH_DEPTH=2 benchmark-goto cache

# Exclude slow paths
```

### Parallel Search Not Faster

**Cause:** Few search paths, overhead costs
**Solution:**
```bash
# Parallel benefits increase with more paths
# Add more search paths in ~/.gotorc
GOTO_SEARCH_PATHS=(
    "$HOME/path1"
    "$HOME/path2"
    "$HOME/path3"
    "$HOME/path4"
)
```

---

## Development

### Adding New Benchmarks

1. **Define benchmark function** in `lib/benchmark-command.sh`:
```bash
__goto_benchmark_fuzzy() {
    local iterations="${1:-$GOTO_BENCHMARK_ITERATIONS}"

    echo "Fuzzy Matching Benchmark"
    # Benchmark logic here

    __goto_benchmark_record "fuzzy" "test_case" "$duration_ms" "status" "workspace"
}
```

2. **Add to dispatcher**:
```bash
__goto_benchmark() {
    case "$subcommand" in
        fuzzy)
            __goto_benchmark_fuzzy "$@"
            ;;
        # ... existing cases
    esac
}
```

3. **Update documentation** (this file)

4. **Add to test suite**:
```bash
benchmark-goto fuzzy 10
```

---

## Resources

- **Source Code:** `/lib/benchmark-command.sh`
- **Workspace Utilities:** `/lib/benchmark-workspace.sh`
- **Standalone Script:** `/bin/benchmark-goto`
- **Results Storage:** `~/.goto_benchmarks/results.csv`
- **Implementation Plan:** `IMPLEMENTATION-PLAN.md` (Feature 3.3)

---

## Changelog

### v0.4.0 - 2025-10-17
- Initial benchmark suite implementation
- Navigation performance testing (uncached vs cached)
- Cache performance testing (build time, hit rate)
- Parallel search performance testing
- Test workspace generation
- Comprehensive reporting
- Standalone executable script
- CSV result storage

---

**Maintained By:** Manu Tej + Claude Code
**License:** MIT
**Repository:** https://github.com/manutej/unix-goto
