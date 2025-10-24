# unix-goto Testing Guide

This document describes the testing infrastructure for unix-goto, following pragmatic programming principles.

## Overview

The testing suite is built following these principles:

- **DRY**: Reusable test helpers eliminate code duplication
- **KISS**: Simple, self-contained tests without external dependencies
- **SOLID**: Each test has a single responsibility
- **Craft**: High-quality, maintainable test code

## Test Structure

```
tests/
├── test-helpers.sh           # Reusable test utilities (DRY)
├── run-tests.sh              # Test runner
├── unit/                     # Unit tests for individual modules
│   ├── test-bookmark-command.sh
│   ├── test-history-tracking.sh
│   └── test-goto-navigation.sh
├── integration/              # Integration tests (future)
└── fixtures/                 # Test data (auto-generated)
```

## Running Tests

### Run All Tests

```bash
./tests/run-tests.sh
```

### Run Specific Test Suite

```bash
./tests/run-tests.sh -p bookmark
./tests/run-tests.sh -p history
./tests/run-tests.sh -p navigation
```

### Verbose Mode

```bash
./tests/run-tests.sh -v
```

### Fail Fast (Stop on First Failure)

```bash
./tests/run-tests.sh -f
```

## Test Coverage

### Bookmark Command (`test-bookmark-command.sh`)

Tests the bookmark management functionality:

- Bookmark file initialization
- Adding bookmarks (current and explicit paths)
- Duplicate prevention
- Invalid path handling
- Bookmark removal
- Path retrieval
- Listing bookmarks
- Navigation to bookmarks
- Stale bookmark handling

**Assertions**: 15 tests covering all bookmark operations

### History Tracking (`test-history-tracking.sh`)

Tests navigation history and recent directory tracking:

- Single directory tracking
- Multiple directory tracking
- History size limits
- History retrieval
- Recent directories (empty and populated)
- Uniqueness (no duplicates)
- Limit enforcement

**Assertions**: 12 tests covering history management

### Goto Navigation (`test-goto-navigation.sh`)

Tests core navigation logic:

- Navigation helper function
- Help flag display
- Empty input handling
- Home shortcut
- Multi-level path parsing
- Direct folder matching
- Nonexistent folder handling

**Assertions**: 11 tests covering navigation flows

## Test Helpers API

The `test-helpers.sh` module provides reusable testing utilities:

### Fixture Management

```bash
setup_test_fixture          # Create temporary test directory
teardown_test_fixture       # Clean up test directory
create_test_dirs base dir1 dir2  # Create test directories
```

### Assertions

```bash
assert_success "command"               # Command must succeed
assert_failure "command"               # Command must fail
assert_equal "expected" "actual"       # Strings must match
assert_contains "haystack" "needle"    # String contains substring
assert_file_exists "/path/to/file"     # File exists
assert_dir_exists "/path/to/dir"       # Directory exists
assert_file_contains "file" "text"     # File contains text
assert_line_count "file" 10            # File has N lines
```

### Test Organization

```bash
test_suite "Suite Name"                # Start test suite
test_case "Test description"           # Start test case
test_summary                           # Print results
```

### Utilities

```bash
time_ms command args                   # Measure execution time
mock_command "cmd" "output"            # Mock command output
stub_command "cmd"                     # Stub command (no-op)
```

## Writing New Tests

### Template

```bash
#!/bin/bash
# Description of what this test suite covers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

# Load test helpers
source "$SCRIPT_DIR/../test-helpers.sh"

# Load module under test
source "$REPO_DIR/lib/your-module.sh"

main() {
    test_suite "Your Test Suite Name"

    setup_test_fixture

    # Add your test cases
    test_your_feature

    teardown_test_fixture

    test_summary
}

test_your_feature() {
    test_case "Description of what you're testing"

    # Setup
    local test_data="value"

    # Execute
    local result=$(your_function "$test_data")

    # Assert
    assert_equal "expected" "$result" "Result should match expected"
}

main
exit $?
```

### Best Practices

1. **One assertion per test**: Each test case should verify one thing
2. **Descriptive names**: Test case names should explain what's being tested
3. **Clean fixtures**: Always use `setup_test_fixture` and `teardown_test_fixture`
4. **Isolated tests**: Tests should not depend on each other
5. **Clear messages**: Provide descriptive assertion messages

## Example Test Session

```bash
$ ./tests/run-tests.sh

╔══════════════════════════════════════════════════════════════════╗
║             UNIX-GOTO TEST SUITE                                 ║
╚══════════════════════════════════════════════════════════════════╝

Found 3 test suite(s)

==========================================
Running: test-bookmark-command
==========================================

═══════════════════════════════════════════════════════════
  Bookmark Command Unit Tests
═══════════════════════════════════════════════════════════

Test 1: Bookmark file initialization
───────────────────────────────────────────────────────────
  ✓ Bookmark file should be created

[... more tests ...]

═══════════════════════════════════════════════════════════
  TEST SUMMARY
═══════════════════════════════════════════════════════════

  Total assertions: 15
  Passed: 15
  Failed: 0

  ALL TESTS PASSED

╔══════════════════════════════════════════════════════════════════╗
║             OVERALL TEST SUMMARY                                 ║
╚══════════════════════════════════════════════════════════════════╝

  Total test suites: 3
  Passed: 3
  Failed: 0

  ALL TEST SUITES PASSED
```

## Continuous Integration

The test suite is designed to run in CI/CD pipelines:

```bash
# In your CI script
cd unix-goto
./tests/run-tests.sh -f  # Fail fast for quick feedback
exit $?
```

## Troubleshooting

### Tests Fail in CI but Pass Locally

- Check shell version (`bash --version`)
- Verify temporary directory permissions
- Check for environment-specific tools

### Fixtures Not Cleaned Up

Run manual cleanup:

```bash
rm -rf /tmp/goto-test.*
```

### Permission Errors

Ensure test scripts are executable:

```bash
chmod +x tests/run-tests.sh tests/unit/*.sh
```

## Test Metrics

Current test coverage:

- **Total test suites**: 3
- **Total assertions**: 38
- **Code coverage**: Core modules (bookmarks, history, navigation)
- **Execution time**: ~2-3 seconds for full suite

## Future Enhancements

- Integration tests for end-to-end workflows
- Performance regression tests
- Fuzzing for edge cases
- Code coverage reporting
