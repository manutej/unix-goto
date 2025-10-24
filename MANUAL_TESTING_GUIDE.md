# Manual Testing Guide - Bug Fixes (CET-97, CET-98, CET-99)

This guide provides step-by-step instructions for manually testing the bug fixes for unix-goto navigation issues.

## Prerequisites

1. Navigate to the unix-goto repository:
   ```bash
   cd ~/Documents/LUXOR/Git_Repos/unix-goto
   ```

2. Source the latest goto.sh to load all fixes:
   ```bash
   source ./goto.sh
   ```

## Test Suite

### Test 1: CET-99 - Partial/Fuzzy Matching ✓

**Issue**: Searching for "goto" didn't find "unix-goto" even though it contains the search term.

**Test Steps**:

```bash
# Test partial matching - search for "goto"
goto goto
```

**Expected Output**:
```
⚠️  Multiple folders named 'goto' found in cache:

  1) /path/to/unix-goto-development
  2) /path/to/unix-goto-plan
  3) /path/to/unix-goto

Please be more specific or use the full path
```

**Success Criteria**:
- ✅ Finds all directories containing "goto" in their name
- ✅ Displays numbered list of matches
- ✅ Shows helpful guidance for specifying path

**Additional Test**:
```bash
# Search for "unix" - should find both "unix-goto" and "project-unix"
goto unix
```

**Expected**: Multiple matches including all directories with "unix" in the name.

---

### Test 2: CET-98 - Multi-Word Directory Names ✓

**Issue**: When passing multiple words to goto, only the first word was used and subsequent words were silently ignored.

**Test Steps**:

```bash
# Test multi-word detection
goto unix goto
```

**Expected Output**:
```
⚠️  Multiple arguments detected: 'unix goto'

For multi-word directory names, use hyphens or quotes:
  ✓ goto unix-goto
  ✓ goto 'unix goto'  (if directory name has spaces)

Did you mean: goto unix-goto ?
```

**Success Criteria**:
- ✅ Detects multiple arguments
- ✅ Shows clear error message
- ✅ Suggests hyphenated version
- ✅ Provides usage examples

**Follow-up Test**:
```bash
# Try the suggested command
goto unix-goto
```

**Expected**: Successfully navigates to unix-goto directory.

---

### Test 3: CET-97 - Navigation Error Handling ✓

**Issue**: Navigation to non-existent directories failed but stayed in current directory without clear error.

**Test Steps**:

```bash
# Save current directory
pwd

# Try to navigate to non-existent directory
goto nonexistent-folder-xyz-123

# Check we're still in the same directory
pwd
```

**Expected Output**:
```
🔍 Searching in subdirectories (cache miss)...
🔍 No exact match, trying partial match...
❌ Project not found: nonexistent-folder-xyz-123
Try 'goto list --folders' to see available folders
```

**Success Criteria**:
- ✅ Shows clear error message
- ✅ Does NOT change directory
- ✅ Tries both exact and partial matching
- ✅ Provides helpful suggestion

---

### Test 4: Special Commands Not Broken ✓

**Test that multi-argument commands still work correctly.**

**Test Steps**:

```bash
# Test goto list with options
goto list --folders

# Test goto index commands
goto index status

# Test goto benchmark
goto benchmark
```

**Success Criteria**:
- ✅ All special commands work with their arguments
- ✅ No interference from multi-word validation
- ✅ Commands execute as expected

---

## Regression Testing

### Test Cache Functionality

```bash
# Rebuild cache
goto index rebuild

# Check cache status
goto index status

# Navigate using cache (should be fast)
goto unix-goto
```

**Expected**: Cache operations work normally, no regressions.

### Test Bookmark Navigation

```bash
# Navigate to bookmark
goto @work

# Create a bookmark (if supported)
bookmark add test-bookmark
```

**Expected**: Bookmark operations work normally.

### Test Multi-Level Paths

```bash
# Test multi-level navigation
goto Git_Repos/unix-goto
```

**Expected**: Multi-level paths still work correctly.

---

## Quick Test Summary

Run these commands in sequence for a quick smoke test:

```bash
# 1. Load the script
cd ~/Documents/LUXOR/Git_Repos/unix-goto && source ./goto.sh

# 2. Test partial matching
goto goto

# 3. Test multi-word validation
goto unix goto

# 4. Test suggested command works
goto unix-goto && pwd

# 5. Test error handling
goto nonexistent-folder-xyz-123

# 6. Test special commands
goto list --folders
goto index status
```

**All tests should pass** - you should see helpful error messages and proper navigation behavior.

---

## Automated Tests

For comprehensive automated testing, run:

```bash
# Run bug fix tests specifically
bash tests/unit/test-bug-fixes.sh

# Run all navigation tests
bash tests/unit/test-goto-navigation.sh

# Run full test suite
bash tests/run-tests.sh
```

**Expected**: All tests pass with 0 failures.

---

## Files Changed

This PR includes fixes to the following files:

1. **lib/goto-function.sh**
   - Lines 199-212: Multi-word argument validation
   - Lines 275-296: Partial matching in recursive search

2. **lib/cache-index.sh**
   - Lines 168-188: Partial matching in cache lookup

3. **tests/unit/test-bug-fixes.sh** (NEW)
   - Comprehensive automated tests for all three bug fixes
   - 13 test assertions covering all scenarios

---

## Troubleshooting

### Issue: "goto: command not found"
**Solution**: Source the goto.sh script:
```bash
source ~/Documents/LUXOR/Git_Repos/unix-goto/goto.sh
```

### Issue: Cache showing old results
**Solution**: Rebuild the cache:
```bash
goto index rebuild
```

### Issue: Tests failing
**Solution**: Ensure you're in the unix-goto directory and have sourced the script:
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
source ./goto.sh
bash tests/unit/test-bug-fixes.sh
```

---

## Verification Checklist

Before approving this PR, verify:

- [ ] Partial matching finds directories containing search term (CET-99)
- [ ] Multi-word arguments show helpful error with suggestions (CET-98)
- [ ] Non-existent directories show proper error without navigation (CET-97)
- [ ] Special commands (list, index, benchmark) still work with their arguments
- [ ] Cache operations work correctly
- [ ] Bookmark navigation works correctly
- [ ] Multi-level paths work correctly
- [ ] All automated tests pass (13 assertions)
- [ ] No regressions in existing functionality

---

## Additional Notes

### Design Decisions

1. **Partial Matching Priority**: Exact matches are tried first, then partial matches. This ensures precise navigation when possible while providing fuzzy matching as a fallback.

2. **Multi-Word Validation Placement**: Validation occurs AFTER special command handling to ensure commands like `goto list --folders` continue to work with multiple arguments.

3. **User Guidance**: All error messages include helpful suggestions and examples to educate users on correct usage.

### Performance Impact

- Partial matching has minimal performance impact (only runs on cache miss)
- Cache lookup remains O(1) for exact matches
- Partial matching in cache uses grep which is fast even with 1000+ directories

### Future Enhancements

Consider these potential improvements:
- Levenshtein distance for typo tolerance (CET-84)
- Automatic hyphenation option for multi-word inputs
- Interactive selection when multiple matches found
- Tab completion support (CET-80)
