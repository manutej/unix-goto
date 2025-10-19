# Testing Quick Reference

A one-page reference for unix-goto testing.

## Run Tests

```bash
# All tests
./tests/run-tests.sh

# Specific suite
./tests/run-tests.sh -p bookmark
./tests/run-tests.sh -p cache
./tests/run-tests.sh -p edge-cases
./tests/run-tests.sh -p performance

# Options
./tests/run-tests.sh -v              # Verbose
./tests/run-tests.sh -f              # Fail fast
./tests/run-tests.sh -v -f -p cache  # Combined
```

## Coverage

```bash
# Text report
./tests/coverage-analysis.sh

# HTML report (requires kcov)
./tests/generate-coverage.sh
open coverage/index.html

# Install kcov
brew install kcov                    # macOS
sudo apt-get install kcov            # Ubuntu
```

## Individual Test Files

```bash
./tests/unit/test-bookmark-command.sh      # Bookmark CRUD
./tests/unit/test-history-tracking.sh      # History management
./tests/unit/test-goto-navigation.sh       # Navigation logic
./tests/unit/test-cache-index.sh           # Cache system
./tests/unit/test-edge-cases.sh            # Error handling
./tests/unit/test-performance.sh           # Performance regression
./tests/unit/test-back-command.sh          # Directory stack
./tests/unit/test-list-command.sh          # Listing features
```

## Writing Tests

### Template

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."

source "$SCRIPT_DIR/../test-helpers.sh"
source "$REPO_DIR/lib/your-module.sh"

main() {
    test_suite "Your Test Suite Name"
    setup_test_fixture

    test_your_function

    teardown_test_fixture
    test_summary
}

test_your_function() {
    test_case "Description of what is tested"

    local result=$(your_function "input")

    assert_equal "expected" "$result" "Should match"
}

main
exit $?
```

### Assertions

```bash
assert_success "command"                    # Command succeeds
assert_failure "command"                    # Command fails
assert_equal "expected" "actual"            # Values equal
assert_contains "haystack" "needle"         # Contains substring
assert_file_exists "/path/to/file"          # File exists
assert_dir_exists "/path/to/dir"            # Directory exists
assert_file_not_exists "/path"              # File not exists
assert_file_contains "/file" "text"         # File contains text
assert_line_count "/file" 10                # Line count matches
```

## CI/CD

### Local Testing

```bash
# Test like CI would
docker run -it --rm -v "$(pwd):/repo" ubuntu:latest bash
cd /repo && ./tests/run-tests.sh
```

### Workflow

- **Location**: `.github/workflows/test.yml`
- **Triggers**: PR, push, daily, manual
- **Jobs**: test, performance, edge-cases, security, integration
- **Matrix**: Ubuntu + macOS

## Performance Thresholds

| Operation | Threshold |
|-----------|-----------|
| Cache lookup | 50ms |
| Bookmark get | 50ms |
| History track | 30ms |
| Cache build | 5s |

## Coverage Targets

- **Overall**: 80%
- **Critical paths**: 100%
- **Current**: 60%

## Common Issues

### Permission errors
```bash
chmod +x tests/unit/*.sh
```

### Tests fail on CI but not locally
```bash
# Test in Docker
docker run -it ubuntu:latest
```

### Coverage report empty
```bash
kcov --version  # Check version >= 38
brew reinstall kcov
```

## Files

```
tests/
├── run-tests.sh              # Main runner
├── test-helpers.sh           # Assertions
├── coverage-analysis.sh      # Coverage tool
├── generate-coverage.sh      # HTML coverage
└── unit/
    ├── test-bookmark-command.sh
    ├── test-history-tracking.sh
    ├── test-goto-navigation.sh
    ├── test-cache-index.sh
    ├── test-edge-cases.sh
    ├── test-performance.sh
    ├── test-back-command.sh
    └── test-list-command.sh

.github/
└── workflows/
    └── test.yml              # CI/CD pipeline
```

## Documentation

- **Comprehensive**: `TESTING-COMPREHENSIVE.md`
- **Summary**: `TEST-ENHANCEMENT-SUMMARY.md`
- **Quick Ref**: `TESTING-QUICK-REFERENCE.md` (this file)

## Test Statistics

- **Test Files**: 8
- **Test Cases**: 92
- **Assertions**: 58
- **Coverage**: 60%
- **Lines of Test Code**: ~1,836

## Before Commit

```bash
# Run full suite
./tests/run-tests.sh

# Check coverage
./tests/coverage-analysis.sh

# Verify no regressions
./tests/unit/test-performance.sh
```

## Need Help?

See `TESTING-COMPREHENSIVE.md` for detailed documentation.

---

**Quick Start**: `./tests/run-tests.sh`
