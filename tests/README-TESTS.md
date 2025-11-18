# unix-goto Test Suite

Quick reference for running tests in the unix-goto project.

## Quick Start

```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific test suites
./tests/test-basic.sh          # Basic syntax and structure tests
./tests/test-fuzzy-matching.sh # Fuzzy matching comprehensive tests
./tests/run-tests.sh           # Integration tests
```

## Test Suites

### 1. Basic Tests (`test-basic.sh`)
- Syntax validation
- File structure checks
- Code quality checks
- ~30 seconds execution time

### 2. Fuzzy Matching Tests (`test-fuzzy-matching.sh`)
- **44 comprehensive test cases**
- 15 test categories
- Edge cases and security tests
- Performance validation
- ~12 seconds execution time

### 3. Integration Tests (`run-tests.sh`)
- Bookmark functionality
- Navigation history
- Multi-level navigation
- ~15 seconds execution time

## Test Coverage Summary

| Suite | Tests | Categories | Status |
|-------|-------|------------|--------|
| Basic | 20+ | 8 | ✅ PASSING |
| Fuzzy Matching | **44** | **15** | ✅ PASSING |
| Integration | 15+ | 7 | ✅ PASSING |
| **Total** | **79+** | **30** | ✅ **PASSING** |

## Fuzzy Matching Test Categories

1. ✅ Exact Substring Matching (4 tests)
2. ✅ Case-Insensitive Matching (3 tests)
3. ✅ Ambiguous Matches (5 tests)
4. ✅ No Matches - Error Handling (3 tests)
5. ✅ Edge Cases - Special Characters (4 tests)
6. ✅ Edge Cases - Long Names (2 tests)
7. ✅ Edge Cases - Empty and Malicious Input (4 tests)
8. ✅ Symlinks (2 tests)
9. ✅ Performance Tests (2 tests)
10. ✅ Integration Tests (3 tests)
11. ✅ Bookmarks Integration (2 tests)
12. ✅ Concurrent Execution (1 test)
13. ✅ Edge Case - No Search Paths (1 test)
14. ✅ Unicode and Special Characters (2 tests)
15. ✅ Boundary Conditions (3 tests)

## Performance Results

| Test | Requirement | Actual | Status |
|------|-------------|--------|--------|
| 100 directories | < 500ms | 14-18ms | ✅ 25-35x faster |
| 1000 directories | < 2s | 39-59ms | ✅ 33-50x faster |

## Test Output

### Successful Run
```
========================================
   unix-goto Test Suite Runner
   Version: v0.4.0
========================================

Running: Basic Tests (Syntax & Structure)
✓ Basic Tests (Syntax & Structure): PASSED

Running: Fuzzy Matching Tests (Comprehensive)
✓ Fuzzy Matching Tests (Comprehensive): PASSED

Running: Integration Tests
✓ Integration Tests: PASSED

========================================
   Final Test Summary
========================================

Total Test Suites: 3
Passed:            3
Failed:            0
Duration:          27s

========================================
   ✓ ALL TEST SUITES PASSED
========================================

Ready for release! 🚀
```

## Adding New Tests

### To add a fuzzy matching test:

1. Edit `tests/test-fuzzy-matching.sh`
2. Add test in appropriate category or create new category
3. Follow the test pattern:
```bash
echo "Test X.Y: Description"
# Setup
mkdir -p "$TEST_HOME/test-dirs"

# Execute
output=$(command_to_test)

# Verify
assert_contains "$output" "expected" "Test description"

# Cleanup
rm -rf "$TEST_HOME/test-dirs"
```

### Helper Functions Available:
- `pass_test "message"` - Mark test as passed
- `fail_test "message" "expected" "actual"` - Mark test as failed
- `assert_equals "expected" "actual" "message"` - Assert equality
- `assert_contains "haystack" "needle" "message"` - Assert substring
- `assert_not_contains "haystack" "needle" "message"` - Assert NOT substring
- `assert_dir_exists "path" "message"` - Assert directory exists

## CI/CD Integration

Tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Tests
  run: ./tests/run-all-tests.sh

- name: Check Exit Code
  run: |
    if [ $? -eq 0 ]; then
      echo "All tests passed"
    else
      echo "Tests failed"
      exit 1
    fi
```

## Troubleshooting

### Tests Hanging
- Check for infinite loops in navigation
- Ensure cleanup functions are called
- Use timeout: `timeout 60 ./tests/test-fuzzy-matching.sh`

### Tests Failing
- Run with verbose output: `bash -x ./tests/test-fuzzy-matching.sh`
- Check test environment: `echo $TEST_HOME`
- Verify library files are sourced correctly

### Permission Errors
- Ensure test files are executable: `chmod +x tests/*.sh`
- Check tmp directory permissions: `ls -la /tmp/unix-goto-*`

## Documentation

- **Test Coverage Report:** `tests/TEST-COVERAGE-FUZZY.md`
- **Success Criteria:** `SUCCESS-CRITERIA.md`
- **Contributing Guide:** `CONTRIBUTING.md`

## Contact

For test-related questions or improvements, see CONTRIBUTING.md.

---

*Last Updated: 2025-11-12*
*Test Suite Version: v0.4.0*
