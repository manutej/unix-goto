# Phase 1: Folder Index Caching System - Test Plan

**Feature:** CET-77 - Folder Index Caching System (20-50x speedup)
**Phase:** 1.1 - Performance Foundation
**Priority:** 0 (Must Have - Highest Performance Impact)
**Target:** Reduce navigation from 2-5s to <100ms

---

## 🎯 Test Objectives

This test plan validates the folder index caching system that provides instant navigation by pre-scanning directory structures and enabling O(1) lookups.

### Success Criteria
- [ ] Cache builds in <5 seconds for 500+ folders
- [ ] Cached lookups complete in <100ms
- [ ] Auto-refresh when cache older than 24 hours
- [ ] Graceful fallback if cache missing or corrupted
- [ ] 95%+ speed improvement for cached navigation
- [ ] Cache hit rate >90% for typical usage

---

## 📋 Pre-Test Setup

### Environment Preparation
```bash
# Navigate to unix-goto directory
cd ~/Documents/LUXOR/Git_Repos/unix-goto

# Ensure latest code is sourced
source ~/.zshrc

# Check current version
goto --help | head -n 1

# Verify search paths are configured
echo "Search paths: ${GOTO_SEARCH_PATHS[@]}"

# Clean any existing cache
rm ~/.goto_index 2>/dev/null
```

### Prerequisites Checklist
- [ ] unix-goto installed and sourced
- [ ] At least 50 folders in search paths for meaningful testing
- [ ] Write permissions to ~/.goto_index
- [ ] `time` command available for performance testing
- [ ] Test directories exist: ~/Documents/LUXOR, ~/ASCIIDocs, etc.

---

## 🧪 Test Suite

### 1. Cache Building Tests

#### Test 1.1: Initial Cache Build
```bash
# Test: Build cache from scratch
goto index rebuild

# Expected output:
# "🔨 Building folder index..."
# "✓ Indexed [N] folders in [X] search paths"
# "⚡ Cache ready: ~/.goto_index"

# Verify cache file exists
ls -lh ~/.goto_index
# Expected: File exists, size > 0 bytes

# Verify cache contents (sample)
head -n 10 ~/.goto_index
# Expected: Shows folder mappings in format: folder_name=/full/path
```

**Pass Criteria:**
- ✅ Cache file created at ~/.goto_index
- ✅ Cache contains folder name → path mappings
- ✅ Build completes without errors
- ✅ Progress indication shown during build
- ✅ Summary shows folder count and search path count

#### Test 1.2: Cache Build Performance
```bash
# Test: Measure cache build time
time goto index rebuild

# Expected: Completes in <5 seconds for typical workspace
# Record: real time, user time, sys time

# Count folders in cache
wc -l ~/.goto_index
# Expected: Matches approximate folder count in search paths

# Verify cache includes folders at different depths
grep -c "^[^/]*=" ~/.goto_index  # Root level
grep -c "/" ~/.goto_index | head -n 1  # With paths
```

**Pass Criteria:**
- ✅ Build time <5 seconds for 500+ folders
- ✅ All folders indexed (manual spot check)
- ✅ Handles nested directories correctly
- ✅ No duplicate entries

#### Test 1.3: Rebuild Existing Cache
```bash
# Setup: Ensure cache exists
goto index rebuild

# Test: Rebuild when cache already exists
goto index rebuild

# Expected: Overwrites old cache
# Verify: File modification time updated
stat ~/.goto_index | grep Modify
```

**Pass Criteria:**
- ✅ Rebuilds without errors
- ✅ Cache file timestamp updated
- ✅ Warning or confirmation shown

---

### 2. Cache Status Tests

#### Test 2.1: View Cache Statistics
```bash
# Test: Show cache status
goto index status

# Expected output format:
# "📊 Folder Index Cache Status"
# "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# "Cache File:     ~/.goto_index"
# "Total Folders:  [N]"
# "Cache Size:     [X] KB"
# "Last Updated:   [timestamp]"
# "Cache Age:      [duration]"
# "Status:         ✅ Valid / ⚠️ Stale / ❌ Missing"
```

**Pass Criteria:**
- ✅ Shows cache file location
- ✅ Displays total folder count
- ✅ Shows cache file size
- ✅ Displays last update timestamp
- ✅ Calculates cache age
- ✅ Indicates cache validity status

#### Test 2.2: Status on Missing Cache
```bash
# Setup: Remove cache
rm ~/.goto_index

# Test: Check status with no cache
goto index status

# Expected:
# "❌ Cache Status: Not Found"
# "Run 'goto index rebuild' to create cache"
```

**Pass Criteria:**
- ✅ Detects missing cache
- ✅ Provides helpful message
- ✅ Suggests rebuild command

#### Test 2.3: Status on Stale Cache
```bash
# Setup: Create old cache (simulate 25+ hours old)
goto index rebuild
touch -t $(date -v-25H +%Y%m%d%H%M.%S) ~/.goto_index

# Test: Check status
goto index status

# Expected:
# "⚠️  Cache Status: Stale (25 hours old)"
# "Run 'goto index rebuild' to refresh"
```

**Pass Criteria:**
- ✅ Detects stale cache (>24 hours)
- ✅ Shows exact age
- ✅ Recommends refresh

---

### 3. Cache Lookup Tests

#### Test 3.1: Basic Cached Lookup
```bash
# Setup: Build cache with known folder
goto index rebuild

# Test: Navigate using cached lookup
goto unix-goto

# Expected:
# Fast navigation (<100ms)
# No "searching" messages
# Direct navigation to cached path
pwd
# Verify: Current directory is unix-goto
```

**Pass Criteria:**
- ✅ Navigation completes in <100ms
- ✅ Uses cached path (visible in behavior)
- ✅ No recursive search triggered
- ✅ Correct directory reached

#### Test 3.2: Cache Lookup Performance Comparison
```bash
# Test: Cold search (no cache)
rm ~/.goto_index
time goto HALCON
# Record: Cold search time

# Test: Warm search (with cache)
goto index rebuild
time goto HALCON
# Record: Cached lookup time

# Calculate speedup
# Expected: 20-50x speedup (2-5s → <100ms)
```

**Pass Criteria:**
- ✅ Cached lookup at least 20x faster
- ✅ Cached lookup <100ms
- ✅ Cold search 2-5 seconds (baseline)
- ✅ Measurable, consistent speedup

#### Test 3.3: Cache Miss Fallback
```bash
# Setup: Build cache
goto index rebuild

# Create new folder not in cache
mkdir -p /tmp/test_new_folder_12345

# Add to search paths temporarily
GOTO_SEARCH_PATHS+=("/tmp")

# Test: Navigate to uncached folder
goto test_new_folder_12345

# Expected:
# Cache lookup misses
# Falls back to recursive search
# Successfully finds folder
pwd
# Verify: In test_new_folder_12345

# Cleanup
cd ~
rmdir /tmp/test_new_folder_12345
```

**Pass Criteria:**
- ✅ Cache miss detected silently
- ✅ Fallback search works
- ✅ Folder found and navigation succeeds
- ✅ No error messages
- ✅ User experience smooth

#### Test 3.4: Multiple Matches Handling
```bash
# Setup: Create folders with same name in different paths
mkdir -p ~/Documents/LUXOR/testdup
mkdir -p ~/ASCIIDocs/testdup

# Rebuild cache
goto index rebuild

# Test: Navigate to duplicate folder name
goto testdup

# Expected:
# Uses first match (priority order)
# Or shows disambiguation prompt
pwd
# Verify: Location matches expected priority

# Cleanup
cd ~
rmdir ~/Documents/LUXOR/testdup
rmdir ~/ASCIIDocs/testdup
```

**Pass Criteria:**
- ✅ Handles duplicate folder names
- ✅ Follows priority order (first search path)
- ✅ Or provides disambiguation
- ✅ Consistent behavior

---

### 4. Cache Invalidation Tests

#### Test 4.1: Auto-Refresh on Stale Cache
```bash
# Setup: Create stale cache (>24 hours)
goto index rebuild
touch -t $(date -v-25H +%Y%m%d%H%M.%S) ~/.goto_index

# Test: Navigate with stale cache
goto HALCON

# Expected:
# "⚠️  Cache stale, rebuilding..."
# Auto-rebuild triggered
# Navigation completes after rebuild
pwd
# Verify: Successful navigation
```

**Pass Criteria:**
- ✅ Detects stale cache (>24 hours)
- ✅ Auto-rebuild triggered
- ✅ User notified of rebuild
- ✅ Navigation completes successfully

#### Test 4.2: Cache TTL Configuration
```bash
# Test: Check default TTL
goto config get cache-ttl
# Expected: 86400 (24 hours)

# Test: Set custom TTL (12 hours)
goto config set cache-ttl 43200
goto config get cache-ttl
# Expected: 43200

# Verify: Persisted in ~/.gotorc
grep cache-ttl ~/.gotorc
# Expected: GOTO_CACHE_TTL=43200

# Reset to default
goto config set cache-ttl 86400
```

**Pass Criteria:**
- ✅ Default TTL is 24 hours
- ✅ Can set custom TTL
- ✅ Configuration persists
- ✅ Auto-refresh respects TTL

#### Test 4.3: Manual Cache Clear
```bash
# Setup: Build cache
goto index rebuild

# Test: Clear cache
goto index clear

# Expected:
# "✓ Cache cleared: ~/.goto_index"

# Verify: Cache file removed
ls ~/.goto_index 2>&1
# Expected: "No such file or directory"

# Test: Navigation after clear (should fallback)
time goto HALCON
# Expected: Slower (uses search, not cache)
```

**Pass Criteria:**
- ✅ Cache file deleted
- ✅ Confirmation message shown
- ✅ Fallback search works after clear
- ✅ No errors

#### Test 4.4: Corrupted Cache Handling
```bash
# Setup: Create corrupted cache
echo "corrupted data here" > ~/.goto_index

# Test: Navigate with corrupted cache
goto HALCON

# Expected:
# Detects invalid cache format
# "⚠️  Cache corrupted, rebuilding..."
# Auto-rebuild triggered
# Navigation succeeds
```

**Pass Criteria:**
- ✅ Detects corrupted cache
- ✅ Auto-rebuild on corruption
- ✅ User notified
- ✅ Navigation recovers gracefully

---

### 5. Cache Integration Tests

#### Test 5.1: Integration with Existing goto Commands
```bash
# Setup: Build cache
goto index rebuild

# Test: All navigation methods use cache
goto HALCON          # Direct folder lookup
goto @bookmark       # Bookmark (if exists)
goto luxor           # Shortcut

# Verify: All are fast (<100ms each)
# Verify: History tracking still works
back --list
recent
```

**Pass Criteria:**
- ✅ Direct lookups use cache
- ✅ Shortcuts still work (don't use cache)
- ✅ Bookmarks still work
- ✅ History tracking unaffected
- ✅ All navigation methods consistent

#### Test 5.2: Cache with Natural Language
```bash
# Setup: Build cache
goto index rebuild

# Test: Natural language query
goto "the halcon project"

# Expected:
# Claude resolves to "HALCON"
# Cache lookup for "HALCON"
# Fast navigation
```

**Pass Criteria:**
- ✅ Natural language resolution works
- ✅ Resolved target uses cache
- ✅ Overall speed improved

#### Test 5.3: Cache Auto-Enable
```bash
# Test: Check if cache auto-enables
goto config get cache-enabled
# Expected: true (default)

# Test: Disable cache
goto config set cache-enabled false

# Test: Navigation without cache
time goto HALCON
# Expected: Slower (search-based)

# Re-enable
goto config set cache-enabled true
time goto HALCON
# Expected: Fast (cache-based)
```

**Pass Criteria:**
- ✅ Cache enabled by default
- ✅ Can disable caching
- ✅ Behavior changes appropriately
- ✅ Configuration persists

---

### 6. Edge Cases & Error Handling

#### Test 6.1: Empty Search Paths
```bash
# Setup: Temporarily empty search paths
GOTO_SEARCH_PATHS_BACKUP=("${GOTO_SEARCH_PATHS[@]}")
GOTO_SEARCH_PATHS=()

# Test: Build cache with no paths
goto index rebuild

# Expected:
# "⚠️  No search paths configured"
# Or creates empty cache

# Restore
GOTO_SEARCH_PATHS=("${GOTO_SEARCH_PATHS_BACKUP[@]}")
```

**Pass Criteria:**
- ✅ Handles empty search paths gracefully
- ✅ Helpful error message
- ✅ No crashes

#### Test 6.2: Permission Denied
```bash
# Setup: Create read-only cache location
touch ~/.goto_index
chmod 444 ~/.goto_index

# Test: Rebuild cache
goto index rebuild

# Expected:
# "❌ Error: Cannot write to ~/.goto_index"
# Suggests checking permissions

# Cleanup
chmod 644 ~/.goto_index
```

**Pass Criteria:**
- ✅ Detects permission issues
- ✅ Clear error message
- ✅ Suggests solution

#### Test 6.3: Disk Space Issues
```bash
# Note: Hard to test without actually filling disk
# Manual test if disk space constrained

# Expected behavior:
# Detects write failures
# Falls back to search-based navigation
# Warns user about disk space
```

**Pass Criteria:**
- ✅ Handles write failures
- ✅ Graceful degradation
- ✅ User notified

#### Test 6.4: Very Large Cache (10,000+ folders)
```bash
# Setup: Create test directories (if feasible)
# Or test on system with many folders

# Test: Build cache
time goto index rebuild

# Expected:
# Completes (may take longer)
# Cache file size reasonable
# Lookup performance still fast

# Test: Lookup in large cache
time goto [some-folder]
# Expected: Still <100ms
```

**Pass Criteria:**
- ✅ Handles large workspaces
- ✅ Build time scales reasonably
- ✅ Lookup time stays constant
- ✅ Memory usage acceptable

---

## 📊 Performance Benchmarks

### Benchmark Suite
```bash
# Run comprehensive performance tests
goto benchmark cache

# Expected to test:
# 1. Cold search time (no cache)
# 2. Cache build time
# 3. Warm search time (with cache)
# 4. Cache hit rate
# 5. Speedup ratio
```

### Manual Benchmark Template
```markdown
## Cache Performance Test Results

**Date:** [date]
**System:** [OS, CPU, RAM]
**Folder Count:** [N]
**Search Paths:** [count]

### Build Performance
- Cache build time: [X] seconds
- Folders indexed: [N]
- Cache file size: [X] KB

### Lookup Performance
- Cold search (no cache): [X] ms
- Warm search (with cache): [X] ms
- Speedup: [Y]x
- Target: 20-50x speedup ✅/❌

### Cache Efficiency
- Cache hit rate: [X]%
- Cache miss rate: [X]%
- Target: >90% hit rate ✅/❌

### Pass/Fail
- [ ] Build time <5s ✅/❌
- [ ] Lookup time <100ms ✅/❌
- [ ] Speedup >20x ✅/❌
- [ ] Hit rate >90% ✅/❌
```

---

## 🔄 Regression Testing

After implementing caching, verify all existing features still work:

### Regression Checklist
```markdown
- [ ] Direct shortcuts (luxor, halcon, docs, infra) - unchanged
- [ ] Direct folder matching - now uses cache
- [ ] Natural language queries - still work
- [ ] Special commands (~, zshrc, --help) - unchanged
- [ ] back command - unaffected
- [ ] recent command - unaffected
- [ ] Bookmarks - still work
- [ ] goto list - shows correct folders
- [ ] History tracking - still captures all navigations
- [ ] Error messages - remain clear and helpful
```

---

## 📝 Test Execution Log Template

```markdown
# Phase 1 Caching Tests - Execution Log

**Date:** [YYYY-MM-DD]
**Tester:** [Name]
**Branch:** [branch-name]
**Commit:** [commit-hash]

## Test Results Summary

| Test Category | Pass | Fail | Skip | Notes |
|---------------|------|------|------|-------|
| Cache Building | 3/3 | 0/3 | 0/3 | All passed |
| Cache Status | 3/3 | 0/3 | 0/3 | |
| Cache Lookup | 4/4 | 0/4 | 0/4 | |
| Cache Invalidation | 4/4 | 0/4 | 0/4 | |
| Integration | 3/3 | 0/3 | 0/3 | |
| Edge Cases | 4/4 | 0/4 | 0/4 | |
| Performance | Pass | Fail | - | |
| Regression | Pass | Fail | - | |

## Detailed Results

### Cache Building Tests
- [✅/❌] Test 1.1: Initial Cache Build
- [✅/❌] Test 1.2: Cache Build Performance
- [✅/❌] Test 1.3: Rebuild Existing Cache

[Continue for all tests...]

## Issues Found
1. [Issue description]
   - Severity: High/Medium/Low
   - Impact: [description]
   - Steps to reproduce: [steps]

## Performance Metrics
- Cache build time: [X]s (target: <5s)
- Lookup time: [X]ms (target: <100ms)
- Speedup: [Y]x (target: 20-50x)
- Hit rate: [Z]% (target: >90%)

## Recommendations
- [Any suggestions for improvements]

## Sign-off
- [ ] All critical tests passed
- [ ] Performance targets met
- [ ] No regressions detected
- [ ] Ready for merge / Needs fixes
```

---

## 🎯 Success Criteria Summary

### Must Pass
- ✅ Cache builds in <5 seconds
- ✅ Lookups complete in <100ms
- ✅ 20-50x speedup achieved
- ✅ >90% cache hit rate
- ✅ Auto-refresh on stale cache
- ✅ Graceful fallback on cache miss
- ✅ No regressions in existing features

### Nice to Have
- ✅ Handles 10,000+ folders
- ✅ Cache size reasonable (<1MB for typical workspace)
- ✅ Build progress indication
- ✅ Detailed statistics available

---

## 📚 Related Documentation

- **Implementation Plan:** IMPLEMENTATION-PLAN.md - Feature 1.1
- **Linear Issue:** CET-77 - Folder Index Caching System
- **Testing Guide:** TESTING-GUIDE.md
- **Project Status:** PROJECT-STATUS.md

---

**Maintained By:** Manu Tej + Claude Code
**Last Updated:** 2025-10-17
**Status:** Ready for implementation - tests defined before coding
