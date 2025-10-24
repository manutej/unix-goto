# Quick Reference: Testing & Benchmarking

Fast reference for running tests and benchmarks in unix-goto.

## Running Tests

### Basic Commands

```bash
# Run all tests
./tests/run-tests.sh

# Run specific test
./tests/run-tests.sh -p bookmark
./tests/run-tests.sh -p history
./tests/run-tests.sh -p navigation

# Verbose output
./tests/run-tests.sh -v

# Stop on first failure
./tests/run-tests.sh -f
```

### Expected Output

```
╔══════════════════════════════════════════════════════════════════╗
║             UNIX-GOTO TEST SUITE                                 ║
╚══════════════════════════════════════════════════════════════════╝

Found 3 test suite(s)

  Total test suites: 3
  Passed: 3
  Failed: 0

  ALL TEST SUITES PASSED
```

## Running Benchmarks

### Basic Commands

```bash
# Run all benchmarks
./benchmarks/run-benchmarks.sh --all

# Run directory lookup benchmark
./benchmarks/run-benchmarks.sh directory-lookup

# Custom iterations
./benchmarks/run-benchmarks.sh -i 20 directory-lookup

# Generate report
./benchmarks/run-benchmarks.sh --report
```

### Expected Performance

- **Cached navigation**: <100ms (target)
- **Actual cached**: ~18ms ✓
- **Bookmark lookup**: <10ms (target)
- **Actual bookmark**: ~18ms

### View Results

```bash
# Latest results
tail ~/.goto_benchmarks/results/benchmark-results.csv

# All results
cat ~/.goto_benchmarks/results/benchmark-results.csv
```

## File Locations

### Tests

```
tests/
├── test-helpers.sh               # Reusable test utilities
├── run-tests.sh                  # Test runner
└── unit/
    ├── test-bookmark-command.sh  # Bookmark tests (15 assertions)
    ├── test-history-tracking.sh  # History tests (12 assertions)
    └── test-goto-navigation.sh   # Navigation tests (11 assertions)
```

### Benchmarks

```
benchmarks/
├── bench-helpers.sh              # Reusable benchmark utilities
├── bench-directory-lookup.sh     # Directory lookup benchmarks
├── run-benchmarks.sh             # Benchmark runner
├── results/
│   └── benchmark-results.csv     # Results storage
└── reports/
    └── benchmark-report-*.txt    # Generated reports
```

### Documentation

```
TESTING-README.md          # Complete testing guide
BENCHMARKS-README.md       # Complete benchmarking guide
IMPLEMENTATION-NOTES.md    # Implementation details for Linear
QUICK-REFERENCE-TESTING.md # This file
```

## Common Tasks

### Before Committing Code

```bash
# Run all tests
./tests/run-tests.sh

# Should see: ALL TEST SUITES PASSED
```

### Measuring Performance Impact

```bash
# Before changes
./benchmarks/run-benchmarks.sh directory-lookup > before.txt

# Make your changes...

# After changes
./benchmarks/run-benchmarks.sh directory-lookup > after.txt

# Compare
diff before.txt after.txt
```

### CI/CD Integration

```bash
#!/bin/bash
# In your CI script

cd unix-goto

# Run tests
./tests/run-tests.sh -f
if [ $? -ne 0 ]; then
    echo "Tests failed"
    exit 1
fi

# Run benchmarks
./benchmarks/run-benchmarks.sh directory-lookup

echo "All checks passed"
```

## Troubleshooting

### Tests Fail

```bash
# Run in verbose mode to see details
./tests/run-tests.sh -v

# Run specific failing test
./tests/run-tests.sh -p bookmark -v
```

### Benchmarks Show Poor Performance

- Close background applications
- Increase iterations: `-i 20`
- Check system load: `top` or `htop`

### Permission Denied

```bash
# Make scripts executable
chmod +x tests/run-tests.sh tests/unit/*.sh
chmod +x benchmarks/run-benchmarks.sh benchmarks/bench-*.sh
```

## Quick Stats

**Test Coverage**:
- Test suites: 3
- Test cases: 28
- Assertions: 38
- Pass rate: 100%

**Benchmark Results**:
- Cached lookup: 18ms (target: <100ms) ✓
- Workspace small: 16ms ✓
- Workspace medium: 19ms ✓
- Workspace large: 22ms ✓

## Help Commands

```bash
# Test runner help
./tests/run-tests.sh --help

# Benchmark runner help
./benchmarks/run-benchmarks.sh --help
```

## Related Files

- `TESTING-README.md` - Full testing documentation
- `BENCHMARKS-README.md` - Full benchmarking documentation
- `IMPLEMENTATION-NOTES.md` - Implementation details
