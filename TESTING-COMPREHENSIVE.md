# Comprehensive Testing Guide

This document provides complete information about the unix-goto test suite, including edge case testing, coverage reporting, and CI/CD integration.

## Table of Contents

1. [Test Suite Overview](#test-suite-overview)
2. [Running Tests](#running-tests)
3. [Test Coverage](#test-coverage)
4. [Edge Case Testing](#edge-case-testing)
5. [Performance Testing](#performance-testing)
6. [CI/CD Integration](#cicd-integration)
7. [Writing New Tests](#writing-new-tests)
8. [Troubleshooting](#troubleshooting)

## Test Suite Overview

The unix-goto test suite consists of **8 test files** with **78+ test cases** and **48+ assertions**, providing comprehensive coverage of:

- **Core functionality**: Navigation, bookmarks, history tracking
- **Cache system**: Index building, lookup, validation
- **Edge cases**: Error handling, boundary conditions, security
- **Performance**: Regression testing with defined thresholds
- **Integration**: Multi-module interactions

### Test Files

| File | Test Cases | Purpose |
|------|------------|---------|
| `test-bookmark-command.sh` | 13 | Bookmark CRUD operations |
| `test-history-tracking.sh` | 8 | Directory history management |
| `test-goto-navigation.sh` | 7 | Core navigation logic |
| `test-cache-index.sh` | 15 | Cache system functionality |
| `test-edge-cases.sh` | 28 | Error handling and boundary conditions |
| `test-performance.sh` | 7 | Performance regression tests |
| `test-back-command.sh` | 8 | Directory stack operations |
| `test-list-command.sh` | 6 | Directory listing features |

### Coverage Metrics

- **Total Functions**: 44
- **Covered Functions**: 18-25 (with new tests)
- **Target Coverage**: 80%
- **Current Coverage**: 43-65% (improving with new tests)

## Running Tests

### Run All Tests

```bash
# From repository root
./tests/run-tests.sh
```

### Run Specific Test Suite

```bash
# Run only bookmark tests
./tests/run-tests.sh -p bookmark

# Run only cache tests
./tests/run-tests.sh -p cache

# Run only edge case tests
./tests/run-tests.sh -p edge-cases

# Run only performance tests
./tests/run-tests.sh -p performance
```

### Run with Options

```bash
# Verbose output
./tests/run-tests.sh -v

# Stop on first failure
./tests/run-tests.sh -f

# Combine options
./tests/run-tests.sh -v -f -p bookmark
```

## Test Coverage

### Generate Coverage Report

```bash
# Basic coverage analysis
./tests/coverage-analysis.sh

# Generate HTML coverage report (requires kcov)
./tests/generate-coverage.sh
```

### Install kcov (for HTML reports)

```bash
# macOS
brew install kcov

# Ubuntu/Debian
sudo apt-get install kcov

# From source
git clone https://github.com/SimonKagstrom/kcov.git
cd kcov
mkdir build && cd build
cmake ..
make
sudo make install
```

### Coverage Output

The coverage analysis produces:

1. **Console output**: Summary of coverage statistics
2. **coverage-report.txt**: Detailed text report
3. **coverage/index.html**: Interactive HTML report (with kcov)

### Coverage Targets

- **Overall Coverage**: >= 80%
- **Critical Functions**: 100% (navigation, bookmarks, cache lookup)
- **Edge Cases**: Comprehensive error handling coverage
- **Performance**: All critical paths benchmarked

## Edge Case Testing

The edge case test suite (`test-edge-cases.sh`) covers:

### Invalid Input Handling

- Empty bookmark names
- Names with spaces or special characters
- Very long names (256+ characters)
- Null/empty path inputs
- Whitespace-only paths

### Permission and Filesystem Issues

- Directories without read permission
- Directories without execute permission
- Broken symlinks
- Circular symlinks
- Unicode characters in paths
- Paths with spaces

### Boundary Conditions

- Extremely long paths (approaching filesystem limits)
- History overflow (beyond max limit)
- Empty history/bookmark files
- Corrupted data files
- Cache with stale entries

### Concurrent Operations

- Simultaneous bookmark writes
- History tracking race conditions
- Cache rebuilds during lookups

### Security Testing

- Path injection attempts (dollar signs, backticks)
- Command injection prevention
- Newline handling in paths
- Quote handling

### Running Edge Case Tests

```bash
./tests/unit/test-edge-cases.sh
```

## Performance Testing

### Performance Thresholds

The performance test suite defines the following thresholds:

| Operation | Threshold | Warning Level |
|-----------|-----------|---------------|
| Cache lookup | 50ms | < 20ms ideal |
| Bookmark retrieval | 50ms | < 30ms ideal |
| History tracking | 30ms | < 10ms ideal |
| Cache build | 5000ms | < 3000ms ideal |

### Running Performance Tests

```bash
./tests/unit/test-performance.sh
```

### Performance Regression Detection

The CI/CD pipeline automatically:

1. Runs performance tests on every PR
2. Compares against baseline thresholds
3. Fails if thresholds are exceeded
4. Generates performance trend reports

### Monitoring Performance

```bash
# Run benchmarks (more comprehensive than tests)
./benchmarks/run-benchmarks.sh

# Compare performance over time
git log --all --grep="Performance" --oneline
```

## CI/CD Integration

### GitHub Actions Workflow

The test suite is integrated into GitHub Actions (`test.yml`):

```yaml
- Unit tests on Ubuntu and macOS
- Performance regression tests
- Edge case validation
- Security checks (ShellCheck)
- Coverage reporting
- Integration tests
```

### Automated Triggers

Tests run automatically on:

- **Pull Requests**: All PRs to main/master/develop
- **Pushes**: Direct commits to protected branches
- **Schedule**: Daily at 2 AM UTC
- **Manual**: Via workflow_dispatch

### CI/CD Jobs

1. **test**: Main test suite (matrix: Ubuntu + macOS)
2. **performance**: Performance regression tests
3. **edge-cases**: Edge case validation
4. **security**: ShellCheck and security scanning
5. **integration**: End-to-end installation test
6. **summary**: Aggregate results and reports

### Status Checks

Required checks for PR merge:

- All unit tests pass (Ubuntu)
- All unit tests pass (macOS)
- Performance tests pass
- Edge case tests pass
- Security checks pass

### Coverage Badges

Add to README.md:

```markdown
![Tests](https://github.com/YOUR_USERNAME/unix-goto/actions/workflows/test.yml/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-80%25-brightgreen)
```

## Writing New Tests

### Test Structure

```bash
#!/bin/bash
# Description of what this test file covers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load modules under test
source "$REPO_DIR/lib/module-name.sh"

# Test suite entry point
main() {
    test_suite "Test Suite Name"

    # Set up test fixture
    setup_test_fixture

    # Run test cases
    test_case_1
    test_case_2

    # Clean up
    teardown_test_fixture

    # Print summary
    test_summary
}

test_case_1() {
    test_case "Description of what this test validates"

    # Arrange
    local test_data="setup"

    # Act
    local result=$(function_under_test "$test_data")

    # Assert
    assert_equal "expected" "$result" "Result should match expected value"
}

# Run tests
main
exit $?
```

### Available Assertions

```bash
assert_success "command"                    # Command succeeds
assert_failure "command"                    # Command fails
assert_equal "expected" "actual"            # Values are equal
assert_contains "haystack" "needle"         # String contains substring
assert_file_exists "/path/to/file"          # File exists
assert_dir_exists "/path/to/dir"            # Directory exists
assert_file_not_exists "/path/to/file"      # File does not exist
assert_file_contains "/file" "text"         # File contains text
assert_line_count "/file" 10                # File has exact line count
```

### Test Naming Conventions

- Test files: `test-<module-name>.sh`
- Test functions: `test_<specific_behavior>`
- Use descriptive names: `test_bookmark_add_with_spaces` not `test_1`

### Best Practices

1. **Isolation**: Each test should be independent
2. **Cleanup**: Always clean up fixtures
3. **Descriptive**: Clear test case descriptions
4. **Fast**: Keep tests under 1 second each
5. **Deterministic**: No random behavior or flaky tests
6. **Edge cases**: Test both happy path and error conditions

## Troubleshooting

### Tests Fail on CI but Pass Locally

**Cause**: Different environment (macOS vs Linux)

**Solution**: Run tests in Docker container matching CI environment

```bash
docker run -it --rm -v "$(pwd):/repo" ubuntu:latest bash
cd /repo
./tests/run-tests.sh
```

### Permission Errors in Tests

**Cause**: Test fixtures not cleaned up properly

**Solution**: Ensure teardown is called

```bash
# Add to test
trap teardown_test_fixture EXIT
```

### Performance Tests Fail Intermittently

**Cause**: System load affects timing

**Solution**: Adjust thresholds or run multiple times

```bash
# Run 3 times and take average
for i in {1..3}; do ./tests/unit/test-performance.sh; done
```

### Coverage Report Empty

**Cause**: kcov not installed or wrong version

**Solution**: Check kcov installation

```bash
kcov --version
# Should be >= 38

# Reinstall if needed
brew reinstall kcov
```

### Tests Hang or Timeout

**Cause**: Infinite loop or blocking operation

**Solution**: Add timeout to test runner

```bash
timeout 300 ./tests/run-tests.sh
```

## Quick Reference

```bash
# Run all tests
./tests/run-tests.sh

# Run specific suite
./tests/run-tests.sh -p edge-cases

# Generate coverage report
./tests/coverage-analysis.sh

# Generate HTML coverage
./tests/generate-coverage.sh

# Run performance tests
./tests/unit/test-performance.sh

# Check what's not covered
./tests/coverage-analysis.sh | grep "potentially lacking"
```

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure tests pass locally
3. Check coverage: `./tests/coverage-analysis.sh`
4. Add edge case tests for error conditions
5. Update performance tests if adding performance-critical code
6. Run full suite before submitting PR

## Resources

- [Test Helpers Reference](tests/test-helpers.sh)
- [Coverage Analysis](tests/coverage-analysis.sh)
- [CI/CD Configuration](.github/workflows/test.yml)
- [Performance Benchmarks](benchmarks/run-benchmarks.sh)

---

**Last Updated**: 2025-10-17
**Test Suite Version**: 2.0
**Coverage Target**: 80%
