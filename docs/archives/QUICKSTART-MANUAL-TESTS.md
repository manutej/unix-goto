# Quickstart Manual Tests - CET-85 Performance Benchmarks

**Date:** 2025-10-17
**Feature:** Performance Benchmark Suite (Feature 3.3)
**Linear Issue:** CET-85
**Branch:** feature/phase3-smart-search
**Commit:** 05123dd

---

## Prerequisites

1. **Install/source unix-goto:**
   ```bash
   cd /Users/manu/Documents/LUXOR/Git_Repos/unix-goto
   source lib/goto-function.sh
   ```

2. **Verify installation:**
   ```bash
   goto --help | grep benchmark
   # Should show: benchmark - Run performance benchmarks
   ```

---

## Test 1: Help & Documentation (2 min)

### Test the help system
```bash
# Main help
goto benchmark --help

# Standalone help
benchmark-goto --help
```

**Expected:** Comprehensive help output showing all commands and options

**Verification:**
- [ ] Help displays benchmark commands
- [ ] Usage examples are clear
- [ ] All options documented

---

## Test 2: Workspace Management (3 min)

### Create test workspaces
```bash
# Create small workspace
goto benchmark workspace create small

# Create typical workspace
goto benchmark workspace create typical

# Create large workspace
goto benchmark workspace create large
```

**Expected:** Each command creates workspace in `~/.goto_benchmarks/test_workspace_*`

**Verification:**
- [ ] Small workspace: ~10 folders, 2 levels deep
- [ ] Typical workspace: ~50 folders, 3 levels deep
- [ ] Large workspace: ~200+ folders, 4 levels deep

### Check workspace stats
```bash
goto benchmark workspace stats small
goto benchmark workspace stats typical
goto benchmark workspace stats large
```

**Expected:** Statistics showing folder count, max depth, total size

**Verification:**
- [ ] Folder counts match expectations
- [ ] Depth levels are correct
- [ ] Stats display properly

### List all workspaces
```bash
goto benchmark workspace list
```

**Expected:** Shows all created workspaces

**Verification:**
- [ ] All 3 workspaces listed
- [ ] Sizes displayed correctly

---

## Test 3: Navigation Benchmarks (5 min)

### Basic navigation benchmark
```bash
# Create small workspace first if not done
goto benchmark workspace create small

# Run navigation benchmark
goto benchmark navigation test_workspace_small 10
```

**Expected:**
- Runs 10 iterations
- Shows progress
- Reports average time, min, max, stddev
- Records results to CSV

**Verification:**
- [ ] Progress indicators display
- [ ] Timing results make sense (ms range)
- [ ] Results saved to `~/.goto_benchmarks/results.csv`
- [ ] CSV file has new entry

### Quick test with fewer iterations
```bash
goto benchmark navigation test_workspace_typical 5
```

**Expected:** Faster completion, similar output format

**Verification:**
- [ ] Completes in reasonable time
- [ ] Results consistent with workspace size

---

## Test 4: Cache Benchmarks (5 min)

### Create typical workspace
```bash
goto benchmark workspace create typical
```

### Run cache benchmark
```bash
goto benchmark cache typical
```

**Expected:**
- Creates cache file
- Runs cache lookup tests
- Shows cache hit rate
- Reports build time and lookup times

**Verification:**
- [ ] Cache file created
- [ ] Cache hit rate >90%
- [ ] Build time <5s for typical workspace
- [ ] Lookup times <100ms
- [ ] Results recorded

### Verify cache file
```bash
ls -lh ~/.goto_benchmarks/cache/test_workspace_typical_index
```

**Expected:** Cache file exists and has reasonable size

**Verification:**
- [ ] Cache file present
- [ ] File size makes sense for workspace

---

## Test 5: Parallel Search Benchmark (3 min)

### Run parallel comparison
```bash
# Ensure workspace exists
goto benchmark workspace create typical

# Run parallel benchmark
goto benchmark parallel
```

**Expected:**
- Tests sequential search
- Tests parallel search (3 search paths)
- Compares timings
- Shows speedup ratio

**Verification:**
- [ ] Sequential timing reported
- [ ] Parallel timing reported
- [ ] Speedup ratio calculated
- [ ] Parallel is faster (ideally ~1.5-2x)
- [ ] Results saved

---

## Test 6: Comprehensive Report (2 min)

### Generate full report
```bash
goto benchmark report
```

**Expected:**
- System information
- All benchmark results summary
- Performance targets validation
- Recommendations

**Verification:**
- [ ] System info accurate
- [ ] All completed benchmarks listed
- [ ] Target validation (✓ or ✗) shown
- [ ] Report is comprehensive

### Check results file
```bash
cat ~/.goto_benchmarks/results.csv
```

**Expected:** CSV with all test results

**Verification:**
- [ ] Proper CSV format
- [ ] All test runs recorded
- [ ] Timestamps correct
- [ ] Metrics make sense

---

## Test 7: Standalone Script (2 min)

### Run standalone commands
```bash
# Help
benchmark-goto --help

# All benchmarks at once
benchmark-goto all

# Individual benchmarks
benchmark-goto navigation test_workspace_small 5
benchmark-goto cache typical
benchmark-goto parallel
benchmark-goto report
```

**Expected:** Same functionality as integrated goto commands

**Verification:**
- [ ] All commands work identically
- [ ] Same output format
- [ ] Same results recorded

---

## Test 8: Cleanup (1 min)

### Clean individual workspace
```bash
goto benchmark workspace cleanup small
```

**Expected:** Removes small workspace

**Verification:**
- [ ] Workspace directory deleted
- [ ] Other workspaces still present

### Clean all workspaces
```bash
goto benchmark workspace cleanup all
```

**Expected:** Removes all test workspaces

**Verification:**
- [ ] All workspace directories removed
- [ ] Results file still present
- [ ] Cache files cleaned up

---

## Test 9: End-to-End Workflow (5 min)

### Complete benchmark run
```bash
# Clean start
goto benchmark workspace cleanup all

# Create workspaces
goto benchmark workspace create small
goto benchmark workspace create typical
goto benchmark workspace create large

# Run all benchmarks
goto benchmark navigation test_workspace_small 10
goto benchmark navigation test_workspace_typical 10
goto benchmark navigation test_workspace_large 5

goto benchmark cache typical
goto benchmark cache large

goto benchmark parallel

# Generate report
goto benchmark report

# View results
cat ~/.goto_benchmarks/results.csv
```

**Expected:** Complete benchmark suite execution with all results

**Verification:**
- [ ] All benchmarks complete successfully
- [ ] Results are consistent
- [ ] No errors or warnings
- [ ] Report shows all tests
- [ ] Performance targets evaluated

---

## Test 10: Error Handling (2 min)

### Test invalid inputs
```bash
# Non-existent workspace
goto benchmark navigation nonexistent 10

# Invalid iteration count
goto benchmark navigation test_workspace_small abc

# Missing workspace for cache
goto benchmark cache nonexistent
```

**Expected:** Clear error messages, graceful handling

**Verification:**
- [ ] Error messages are helpful
- [ ] No crashes or unexpected behavior
- [ ] Suggests corrective actions

---

## Performance Validation

### Expected Performance Targets

| Metric | Target | Test Command |
|--------|--------|--------------|
| Navigation (cached) | <100ms | `goto benchmark navigation <workspace> 100` |
| Cache hit rate | >90% | `goto benchmark cache typical` |
| Speedup ratio | 20-50x | Compare cached vs uncached in report |
| Cache build time | <5s | `goto benchmark cache large` |
| Parallel speedup | ~1.5-2x | `goto benchmark parallel` |

### Validation Steps

1. **Run comprehensive benchmarks:**
   ```bash
   goto benchmark workspace create typical
   goto benchmark navigation test_workspace_typical 100
   goto benchmark cache typical
   goto benchmark parallel
   goto benchmark report
   ```

2. **Review results in report**
3. **Check CSV for detailed metrics**
4. **Verify targets met:**
   - [ ] Navigation <100ms average
   - [ ] Cache hit rate >90%
   - [ ] Speedup ratio in 20-50x range
   - [ ] Cache build <5s
   - [ ] Parallel search shows improvement

---

## Troubleshooting

### Issue: Benchmarks are very slow
**Solution:**
- Reduce iterations for testing: `goto benchmark navigation <workspace> 5`
- Use smaller workspace: `goto benchmark workspace create small`

### Issue: Cache file not created
**Solution:**
- Check permissions in `~/.goto_benchmarks/cache/`
- Verify workspace exists: `goto benchmark workspace list`

### Issue: Results not recorded
**Solution:**
- Check `~/.goto_benchmarks/results.csv` exists
- Verify write permissions
- Re-initialize: `goto benchmark report` (creates missing files)

### Issue: Command not found
**Solution:**
- Re-source goto function: `source lib/goto-function.sh`
- Check installation: `./install.sh`

---

## Tag Team Testing Checklist

When working with another developer/tester:

**Person A - Setup & Basic Tests:**
- [ ] Run Tests 1-3 (Help, Workspace, Navigation)
- [ ] Verify results file creation
- [ ] Check workspace directory structure

**Person B - Advanced Tests:**
- [ ] Run Tests 4-6 (Cache, Parallel, Report)
- [ ] Validate performance targets
- [ ] Review comprehensive report

**Both - Cross-Validation:**
- [ ] Compare results.csv entries
- [ ] Verify consistent timings
- [ ] Run end-to-end workflow together
- [ ] Test error handling scenarios

**Sign-off:**
- [ ] All tests passing for Person A
- [ ] All tests passing for Person B
- [ ] Results are consistent
- [ ] Documentation is clear
- [ ] Ready for merge/deployment

---

## Automated Test Verification

Before manual testing, run the automated test suite:

```bash
bash test-benchmark.sh
```

**Expected:** All 10 automated tests pass (✓)

This validates:
- File existence
- Function definitions
- Script executability
- Basic functionality
- Integration with goto

**If automated tests fail, fix issues before manual testing.**

---

## Test Results Log

### Test Run 1 - Initial Implementation
**Date:** 2025-10-17
**Tester:** Claude (Automated)
**Result:** ✅ ALL TESTS PASSED (10/10)

**Notes:**
- All benchmark files present
- All functions defined correctly
- Standalone script executable
- Initialization works
- Workspace management functional
- Statistics calculation accurate
- Results recording works
- goto integration successful

### Test Run 2 - Manual Verification
**Date:** _____________
**Tester:** _____________
**Result:** [ ] PASS / [ ] FAIL

**Checklist:**
- [ ] All quickstart tests completed
- [ ] Performance targets validated
- [ ] No errors encountered
- [ ] Documentation clear and accurate

**Notes:**
_____________________________________________
_____________________________________________

---

## Next Steps After Testing

1. **If all tests pass:**
   - Sign off on implementation
   - Update Linear issue to "Complete"
   - Create PR for merge
   - Document any performance insights

2. **If issues found:**
   - Document specific failures
   - Create bug tickets in Linear
   - Fix issues
   - Re-test

3. **Performance data:**
   - Save results.csv for baseline
   - Compare with future optimizations
   - Track performance regression

---

**Total Manual Test Time:** ~30 minutes
**Prerequisites:** unix-goto installed, bash shell, write permissions

**Ready to test!** Start with Test 1 and work through sequentially.
