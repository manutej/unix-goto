# Success Criteria & Specifications

**Version:** v0.4.0
**Date:** 2025-11-10
**Philosophy:** Simple, testable, no over-engineering

---

## 🎯 Purpose

This document defines **concrete, testable success criteria** for unix-goto v0.4.0. Every criterion must be:
1. **Measurable** - Can be objectively verified
2. **Testable** - Has a clear test procedure
3. **Realistic** - Achievable in 2-4 weeks
4. **Value-driven** - Solves a real user problem

**Anti-goals:**
- ❌ Over-engineering
- ❌ Feature creep
- ❌ Surface-level tests
- ❌ Vague requirements

---

## 📊 Current State (v0.3.0)

### What Works Well ✅
- Multi-level navigation: `goto project/sub/deep`
- Recursive search: Finds nested folders automatically
- Bookmarks: `goto @work`
- Navigation history: `back`, `recent`
- Natural language: Claude AI integration
- Production quality: Grade A codebase

### Critical Gaps ❌
From existing docs (ROADMAP.md, CRITICAL-IMPROVEMENTS.md):
1. **No fuzzy matching** - Must type exact names
2. **No tab completion** - Cannot explore interactively
3. **Limited testing** - Only basic smoke tests

**Focus for v0.4.0:** Fix these 3 gaps ONLY. Nothing more.

---

## 🎯 v0.4.0 Success Criteria

### Feature 1: Fuzzy Matching

#### User Problem
"I have to type exact directory names like 'GAI-3101'. If I type 'gai' or 'ga3101', nothing works."

#### Success Definition
Users can type partial or abbreviated directory names and still navigate successfully.

#### Acceptance Criteria

**1.1 Substring Matching**
```bash
# Given directories: GAI-3101, GAI-3102, HALCON
✓ goto GAI     # Matches GAI-3101 (or shows both if ambiguous)
✓ goto HAL     # Matches HALCON
✓ goto 3101    # Matches GAI-3101
✓ goto ai-     # Matches GAI-* directories
```

**Test Procedure:**
```bash
# Setup
mkdir -p ~/test/GAI-3101 ~/test/GAI-3102 ~/test/HALCON ~/test/WA3590

# Test 1: Exact substring match
goto GAI
# Expected: Show options or navigate to first match
# Fail if: Error or no match

# Test 2: Case-insensitive
goto gai
# Expected: Same as "goto GAI"
# Fail if: Case sensitivity prevents match

# Test 3: Partial match
goto 3101
# Expected: Navigate to GAI-3101
# Fail if: No match or wrong directory

# Test 4: No match
goto xyz
# Expected: Clear error message
# Fail if: Silent failure or crash
```

**1.2 Ambiguity Resolution**
```bash
# Given: GAI-3101, GAI-3102 both exist
✓ goto GAI     # Shows numbered list of options
✓ Message clearly explains what user should do
✗ Does NOT automatically pick one
✗ Does NOT use complex algorithms
```

**Test Procedure:**
```bash
# Setup
mkdir -p ~/test/project-1 ~/test/project-2 ~/test/project-3

# Test: Ambiguous match
goto proj
# Expected output format:
# "Multiple matches found:
#  1) project-1
#  2) project-2
#  3) project-3
# Please be more specific"
# Fail if: Picks one arbitrarily or crashes
```

**1.3 Performance**
```bash
✓ Matches complete in < 500ms for 100 directories
✓ Matches complete in < 2s for 1000 directories
```

**Test Procedure:**
```bash
# Setup: Create 100 test directories
for i in {1..100}; do mkdir -p ~/test/project-$i; done

# Test
time goto proj
# Expected: < 500ms
# Measure: Real time from command to response

# Performance test with 1000 dirs
for i in {1..1000}; do mkdir -p ~/test/dir-$i; done
time goto dir
# Expected: < 2s
```

**1.4 Integration**
```bash
✓ Works with multi-level paths: goto gai/docs
✓ Works with bookmarks: goto @wo (matches @work)
✓ Falls back to Claude AI if needed
✓ Does NOT break existing exact matches
```

**Test Procedure:**
```bash
# Test 1: Multi-level fuzzy
goto gai/docs
# Expected: Navigate to GAI-3101/docs
# Fail if: Fuzzy matching breaks path resolution

# Test 2: Bookmark fuzzy
bookmark add work ~/Documents/Work
goto @wo
# Expected: Navigate to @work bookmark
# Fail if: Fuzzy matching doesn't work with bookmarks

# Test 3: Exact match still works
goto GAI-3101
# Expected: Navigate immediately (no fuzzy search)
# Fail if: Fuzzy search runs when exact match exists
```

#### Implementation Constraints
- ❌ No external dependencies (no fzf required)
- ❌ No complex algorithms (keep it simple)
- ✅ Pure bash implementation
- ✅ Degrades gracefully (fallback to exact match)

#### Deep Tests (Not Surface-Level)

**Edge Cases:**
```bash
# Test: Directory with spaces
mkdir "Project Name With Spaces"
goto proj
# Expected: Matches correctly
# Fail if: Spaces break matching

# Test: Special characters
mkdir "project-[test]"
goto proj
# Expected: Matches or clear error
# Fail if: Crashes on special chars

# Test: Very long names
mkdir "very-long-project-name-that-exceeds-normal-length"
goto very
# Expected: Matches correctly
# Fail if: Long names break algorithm

# Test: Unicode
mkdir "项目-test"
goto test
# Expected: Matches or graceful skip
# Fail if: Unicode causes crash

# Test: Symlinks
ln -s ~/real/path ~/test/link
goto link
# Expected: Navigates to symlink target
# Fail if: Symlinks break navigation
```

**Failure Modes:**
```bash
# Test: Empty input
goto ""
# Expected: Show help or error
# Fail if: Crash or undefined behavior

# Test: Very long input
goto "a"*1000
# Expected: Error or no match
# Fail if: Crashes or hangs

# Test: Malicious input
goto "; rm -rf /"
# Expected: Treat as literal string
# Fail if: Command injection possible

# Test: Concurrent execution
goto proj & goto proj & goto proj
# Expected: All complete correctly
# Fail if: Race conditions or corruption
```

#### Minimum Viable Implementation

**Simple Algorithm (50 lines max):**
```bash
__goto_fuzzy_match() {
    local query="$1"
    local -a matches=()

    # Case-insensitive substring search
    for dir in "${all_dirs[@]}"; do
        if [[ "${dir,,}" == *"${query,,}"* ]]; then
            matches+=("$dir")
        fi
    done

    # Return results
    case ${#matches[@]} in
        0) echo "No matches"; return 1 ;;
        1) navigate_to "${matches[0]}" ;;
        *) show_options "${matches[@]}" ;;
    esac
}
```

**That's it. No Levenshtein distance needed for v0.4.0.**

---

### Feature 2: Tab Completion

#### User Problem
"I can't explore what directories are available. I have to remember everything."

#### Success Definition
Users can press TAB to see available options and complete partially typed commands.

#### Acceptance Criteria

**2.1 Basic Completion**
```bash
✓ goto <TAB>    # Shows: shortcuts, bookmarks, directories
✓ goto G<TAB>   # Shows: GAI-3101, GAI-3102, etc.
✓ goto @<TAB>   # Shows: all bookmarks
✓ Response time: < 100ms
```

**Test Procedure:**
```bash
# Test in bash
bash
goto <TAB><TAB>
# Expected: Shows completion options
# Count options shown
# Measure: Response time

# Test in zsh
zsh
goto <TAB>
# Expected: Shows completion menu
# Check: Format is readable
```

**2.2 Context-Aware Completion**
```bash
✓ bookmark <TAB>  # Shows: add, rm, list, goto
✓ bookmark rm <TAB>  # Shows: existing bookmark names
✓ back <TAB>  # Shows: --list, --clear, --help, 1, 2, 3
```

**Test Procedure:**
```bash
# Test: Command completion
bookmark <TAB>
# Expected: add, rm, list, goto
# Count: Should show exactly 4-5 options

# Test: Argument completion
bookmark add work
bookmark rm <TAB>
# Expected: Shows "work"
# Fail if: Shows wrong bookmarks or commands
```

**2.3 Shell Compatibility**
```bash
✓ Works in bash 3.2+ (macOS default)
✓ Works in bash 4.0+
✓ Works in zsh 5.0+
✓ Graceful fallback if completion not available
```

**Test Procedure:**
```bash
# Test each shell version
for shell in /bin/bash /usr/local/bin/bash /bin/zsh; do
    $shell -c "source install; goto <TAB>"
done
# Expected: Works or shows "completion not available"
# Fail if: Crashes or shows errors
```

**2.4 Performance**
```bash
✓ Completion responds in < 100ms
✓ Works with 1000+ directories
✓ Does NOT hang or freeze terminal
```

**Test Procedure:**
```bash
# Setup: 1000 directories
for i in {1..1000}; do mkdir ~/test/dir-$i; done

# Test: Completion speed
time (goto d<TAB>)
# Expected: < 100ms
# Measure: Time to show options

# Test: No freeze
goto <TAB>
# During completion, try Ctrl+C
# Expected: Cancels gracefully
# Fail if: Terminal hangs
```

#### Implementation Constraints
- ✅ Separate completion scripts (not inline)
- ✅ Bash and zsh implementations
- ❌ No complex completion logic
- ✅ Static list generation (no dynamic search)

#### Deep Tests

**Edge Cases:**
```bash
# Test: Empty completion
cd /tmp/empty
goto <TAB>
# Expected: Shows help or "no options"
# Fail if: Hangs or errors

# Test: Many options (1000+)
# Already covered above

# Test: Long directory names
mkdir "very-long-directory-name-"*100
goto very<TAB>
# Expected: Shows truncated or scrollable list
# Fail if: Terminal breaks

# Test: Completion with active job
sleep 100 &
goto <TAB>
# Expected: Completion works normally
# Fail if: Interferes with background jobs
```

**Failure Modes:**
```bash
# Test: Completion file missing
rm ~/.bash_completions/goto
goto <TAB>
# Expected: No completion or error message
# Fail if: Crashes shell

# Test: Corrupted completion file
echo "invalid bash syntax" > ~/.bash_completions/goto
goto <TAB>
# Expected: Skips completion or shows error
# Fail if: Crashes shell

# Test: Permission denied
chmod 000 ~/.bash_completions/goto
goto <TAB>
# Expected: Graceful fallback
# Fail if: Error messages
```

#### Minimum Viable Implementation

**Bash Completion (100 lines max):**
```bash
_goto_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Get static lists
    local shortcuts="luxor halcon docs infra"
    local bookmarks=$(cut -d'|' -f1 ~/.goto_bookmarks 2>/dev/null)
    local dirs=$(ls -1 ~/ASCIIDocs ~/Documents/LUXOR 2>/dev/null)

    # Complete
    COMPREPLY=($(compgen -W "$shortcuts $bookmarks $dirs" -- "$cur"))
}

complete -F _goto_completions goto
```

**Zsh Completion (similar simplicity)**

---

### Feature 3: Improved Testing

#### User Problem
"Tests are too basic. We need confidence that changes don't break things."

#### Success Definition
Comprehensive test suite that covers common use cases and edge cases.

#### Acceptance Criteria

**3.1 Test Coverage**
```bash
✓ Core navigation: 10+ test cases
✓ Fuzzy matching: 15+ test cases
✓ Tab completion: 10+ test cases
✓ Error handling: 10+ test cases
✓ Edge cases: 20+ test cases
✓ Total: 65+ test cases minimum
```

**3.2 Test Types**

**Unit Tests:**
```bash
# Test individual functions
test_fuzzy_match_exact()
test_fuzzy_match_partial()
test_fuzzy_match_case_insensitive()
test_fuzzy_match_no_results()
test_fuzzy_match_multiple_results()
```

**Integration Tests:**
```bash
# Test complete workflows
test_goto_with_fuzzy_matching()
test_goto_with_multi_level_path()
test_bookmark_with_fuzzy_goto()
test_recent_with_fuzzy_selection()
```

**Edge Case Tests:**
```bash
# Test unusual situations
test_directory_with_spaces()
test_directory_with_special_chars()
test_very_long_directory_names()
test_symlinks()
test_empty_search_paths()
test_non_existent_directories()
test_concurrent_navigation()
test_malformed_input()
```

**Performance Tests:**
```bash
# Test at scale
test_fuzzy_match_100_dirs()
test_fuzzy_match_1000_dirs()
test_completion_with_1000_options()
test_navigation_history_1000_entries()
```

**3.3 Test Execution**
```bash
✓ All tests pass on macOS
✓ All tests pass on Linux (Ubuntu)
✓ Tests complete in < 2 minutes
✓ Tests are idempotent (can run multiple times)
✓ Tests clean up after themselves
```

**Test Procedure:**
```bash
# Run all tests
./tests/run-all-tests.sh

# Expected output:
# Running 65 tests...
# ✓ Test 1: exact match
# ✓ Test 2: fuzzy match
# ...
# ✓ 65/65 tests passed
# Completed in 1m 23s

# Fail if: Any test fails or takes > 2min
```

**3.4 Test Quality Standards**
```bash
✓ Each test is independent
✓ Tests have clear names describing what they test
✓ Tests include both positive and negative cases
✓ Tests verify actual behavior, not implementation
✓ Tests document expected vs actual results
```

#### Implementation Constraints
- ✅ Use existing bash testing patterns
- ❌ No external test framework required (but can use bats if helpful)
- ✅ Tests must be readable by non-experts
- ✅ Self-documenting test names

#### Deep Test Examples

**Example: Deep Navigation Test**
```bash
test_multi_level_navigation_with_symlinks() {
    # Setup
    mkdir -p /tmp/test/real/path/deep
    ln -s /tmp/test/real /tmp/test/link

    # Test
    goto link/path/deep

    # Verify
    [[ "$PWD" == "/tmp/test/real/path/deep" ]] || fail "Symlink navigation failed"

    # Cleanup
    rm -rf /tmp/test
}
```

**Example: Deep Edge Case Test**
```bash
test_fuzzy_match_with_conflicting_names() {
    # Setup: Create confusing directory names
    mkdir -p "/tmp/test/ABC-123"
    mkdir -p "/tmp/test/ABC-124"
    mkdir -p "/tmp/test/ABD-123"
    mkdir -p "/tmp/test/abc-123"  # Case variation

    # Test 1: Fuzzy match "ABC"
    result=$(goto ABC 2>&1)
    # Should show all 3 ABC matches (case-insensitive)
    [[ "$result" == *"ABC-123"* ]] || fail "Missing ABC-123"
    [[ "$result" == *"ABC-124"* ]] || fail "Missing ABC-124"
    [[ "$result" == *"abc-123"* ]] || fail "Case insensitive failed"
    [[ "$result" != *"ABD-123"* ]] || fail "Wrong match included"

    # Test 2: More specific
    result=$(goto ABC-12)
    [[ $(echo "$result" | wc -l) -eq 3 ]] || fail "Should show 3 matches"

    # Cleanup
    rm -rf /tmp/test
}
```

---

## 📋 Release Checklist for v0.4.0

### Code Complete
- [ ] Fuzzy matching implemented
- [ ] Tab completion (bash + zsh) implemented
- [ ] Tests written (65+ test cases)
- [ ] All tests passing
- [ ] No regressions in existing features
- [ ] Code reviewed (self or peer)

### Documentation
- [ ] README.md updated with fuzzy matching examples
- [ ] README.md updated with tab completion info
- [ ] CHANGELOG.md updated
- [ ] examples/usage.md updated
- [ ] This SUCCESS-CRITERIA.md marked complete

### Testing
- [ ] Run full test suite: `./tests/run-all-tests.sh`
- [ ] Manual testing on macOS
- [ ] Manual testing on Linux
- [ ] Performance tests pass
- [ ] Edge case tests pass

### Quality
- [ ] No shellcheck errors (if available)
- [ ] No syntax errors in any shell script
- [ ] Install script works on clean system
- [ ] Uninstall script works (if provided)

### Release
- [ ] Create tag: v0.4.0
- [ ] Write release notes
- [ ] Push to GitHub
- [ ] Update PROJECT-STATUS.md
- [ ] Announce release

---

## 🎯 Success Metrics

### Quantitative
- **Test Coverage:** 65+ tests passing
- **Performance:** Fuzzy match < 500ms for 100 dirs
- **Completion Speed:** < 100ms response time
- **Zero Regressions:** All v0.3.0 features still work

### Qualitative
- **Usability:** Users can navigate with partial names
- **Discoverability:** Users can explore via tab completion
- **Reliability:** No crashes or data loss
- **Simplicity:** Code is maintainable and understandable

---

## ❌ Explicit Non-Goals for v0.4.0

**What we are NOT building:**
- ❌ File search (gf command) - Save for v0.5.0
- ❌ Content search (gs command) - Save for v0.5.0
- ❌ Frecency algorithm - Save for v0.5.0
- ❌ Git-aware features - Save for v0.5.0
- ❌ Workspaces - Save for v1.0.0
- ❌ Plugin system - Save for v1.0.0
- ❌ Complex algorithms - Keep it simple
- ❌ External dependencies - Stay pure bash
- ❌ GUI or TUI - CLI only

**Why?**
Focus on doing 2-3 things really well rather than 10 things poorly.

---

## 🚦 Definition of Done

A feature is "done" when:
1. ✅ Code is written and works
2. ✅ Tests are written and passing (including edge cases)
3. ✅ Documentation is updated
4. ✅ Peer review complete (or self-review if solo)
5. ✅ No regressions
6. ✅ Performance meets criteria
7. ✅ User can actually use it

A version is "done" when:
1. ✅ All features are "done"
2. ✅ Release checklist complete
3. ✅ Tag created and pushed
4. ✅ Announced publicly

---

## 📖 How to Use This Document

### For Implementation:
1. Pick a feature (start with Fuzzy Matching)
2. Read its Acceptance Criteria
3. Implement to meet the criteria
4. Run the Test Procedures
5. Fix until all criteria met
6. Move to next feature

### For Testing:
1. Run test procedures exactly as written
2. Document actual results
3. Compare to expected results
4. Mark pass/fail for each criterion
5. Fix failures before release

### For Review:
1. Check each criterion independently
2. Run deep tests, not just surface tests
3. Verify edge cases work
4. Ensure performance meets targets
5. Sign off only when ALL criteria met

---

## 📅 Timeline

**Week 1:** Fuzzy Matching
- Days 1-2: Implementation
- Day 3: Testing (deep tests!)
- Day 4: Fixes and refinement

**Week 2:** Tab Completion
- Days 1-3: Implementation (bash + zsh)
- Day 4: Testing
- Day 5: Fixes

**Week 3:** Testing & Polish
- Days 1-2: Write comprehensive test suite
- Days 3-4: Fix issues found
- Day 5: Documentation updates

**Week 4:** Release
- Days 1-2: Final testing
- Day 3: Release prep
- Day 4: Release v0.4.0
- Day 5: Buffer/contingency

---

## ✅ Sign-Off

This document will be marked complete when:
- [ ] All acceptance criteria met
- [ ] All tests passing
- [ ] Release checklist complete
- [ ] v0.4.0 shipped

**Version:** 1.0
**Status:** ACTIVE
**Next Review:** After v0.4.0 release
