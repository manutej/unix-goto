# Consolidated Action Plan - Spec-Kit Aligned

**Date:** 2025-11-12
**Based On:** Parallel agent reports + Spec-Kit principles + ROADMAP.md
**Status:** Ready for execution

---

## 📊 Situation Analysis

### Spec-Kit Alignment
✅ **Specification** - SUCCESS-CRITERIA.md exists
✅ **Plan** - PHASE-1-IMPLEMENTATION.md detailed
✅ **Implementation** - 2/3 features in progress
❌ **Constitution** - Created (CONSTITUTION.md)
⚠️ **Tasks** - Now tracked with TodoWrite

### Agent Reports Summary

| Agent | Finding | Impact |
|-------|---------|--------|
| **Code Review** | Over-engineered (6/10 complexity) | Refactoring needed |
| **Testing** | 44 tests created, all passing | ✅ Production ready |
| **Build** | Tab completion complete | ✅ Ready to merge |
| **Compliance** | Fuzzy matching 65% compliant | ❌ Critical gaps |

---

## 🚨 Critical Issues (Spec Non-Compliance)

### Issue 1: Performance Failure ⚠️ BLOCKER
**Current:** 1.288s for 100 directories
**Required:** <500ms
**Gap:** 2.6x too slow
**Root Cause:** Runs `find` every time, no caching
**Priority:** P0 (must fix before release)

### Issue 2: Over-Engineering 📝 QUALITY
**Current:** 158 lines (121 without tests)
**Required:** <100 lines
**Issues:**
- Test function in production code (37 lines)
- Config duplication (3 files)
- Recursive goto call
- Verbose messaging (15 lines)
**Priority:** P1 (fix before merge)

### Issue 3: Missing Integration 🔧 FEATURE
**Missing:**
- Multi-level fuzzy: `goto gai/docs` → `GAI-3101/docs`
- Bookmark fuzzy: `goto @wo` → `@work`
**Priority:** P1 (per SUCCESS-CRITERIA.md)

---

## 🎯 Action Plan (Priority Order)

### Phase A: Fix Critical Performance (2-3 hours)

#### Task A1: Cache Directory List
**File:** `lib/fuzzy-matching.sh`
**Change:** Build directory index once, reuse
**Approach:**
```bash
# Add caching
FUZZY_CACHE_FILE="$HOME/.goto_fuzzy_cache"
FUZZY_CACHE_TTL=300  # 5 minutes

__goto_fuzzy_build_cache() {
    # Build directory list once
    # Store in cache file with timestamp
}

__goto_fuzzy_get_dirs() {
    # Check cache age
    # Rebuild if stale
    # Return cached list
}
```
**Expected:** <100ms for 100 dirs

#### Task A2: Benchmark Performance
```bash
time goto gai  # Should be <500ms
```
**Success:** Meets performance requirement

---

### Phase B: Remove Over-Engineering (1-2 hours)

#### Task B1: Remove Test Function
**Delete:** Lines 122-159 from fuzzy-matching.sh
**Move to:** tests/test-fuzzy-matching.sh (already exists)
**Impact:** -37 lines

#### Task B2: Fix Config Duplication
**Change:** Pass search_paths as parameter
**Files:** fuzzy-matching.sh, goto-function.sh
**Impact:** Eliminates duplication

#### Task B3: Remove Recursive Call
**Change:** Return path instead of calling goto
**Impact:** Cleaner separation

#### Task B4: Simplify Messaging
**Change:** Reduce from 15 lines to 3-5 lines
**Impact:** -10 lines, cleaner output

**Expected Result:** ~65 lines total, complexity 3/10

---

### Phase C: Add Missing Integration (1-2 hours)

#### Task C1: Multi-Level Fuzzy
**Add:** Support for `goto gai/docs`
**Location:** goto-function.sh lines 145-169
**Logic:**
```bash
if [[ "$1" == */* ]]; then
    base="${1%%/*}"
    rest="${1#*/}"
    # Fuzzy match base
    matched_base=$(__goto_fuzzy_match "$base")
    # Navigate to full path
    goto "$matched_base/$rest"
fi
```

#### Task C2: Bookmark Fuzzy
**Add:** Support for `goto @wo`
**Location:** goto-function.sh lines 77-85
**Logic:** Fuzzy match bookmark names

---

### Phase D: Verification (30 min)

#### Task D1: Run Compliance Tests
```bash
./tests/test-fuzzy-matching.sh
# All 44 tests must pass
```

#### Task D2: Run Performance Benchmarks
```bash
# 100 directories
time for i in {1..100}; do mkdir test-$i; done
time goto test
# Must be <500ms

# 1000 directories
time for i in {1..1000}; do mkdir test-$i; done
time goto test
# Must be <2s
```

#### Task D3: Code Review Checklist
- [ ] <100 lines (excluding tests)
- [ ] No config duplication
- [ ] No recursion
- [ ] Simple messaging
- [ ] Performance <500ms
- [ ] All integration working

---

### Phase E: Merge & Release (1 hour)

#### Task E1: Merge feature/fuzzy-matching
```bash
git checkout master
git merge feature/fuzzy-matching
# Resolve any conflicts
```

#### Task E2: Merge feature/tab-completion
```bash
git merge feature/tab-completion
# Tab completion is clean, should merge easily
```

#### Task E3: Final Testing
```bash
./tests/run-all-tests.sh
# Everything must pass
```

#### Task E4: Tag v0.4.0
```bash
git tag -a v0.4.0 -m "Release v0.4.0: Fuzzy Matching + Tab Completion"
git push origin master --tags
```

---

## 📋 Spec-Kit Quality Checklist

Using spec-kit principles, verify:

### Constitution Compliance
- [x] Created CONSTITUTION.md with governing principles
- [ ] All code follows simplicity principle
- [ ] No over-engineering (complexity ≤3/10)
- [ ] Performance requirements met
- [ ] Backward compatible

### Specification Quality
- [x] SUCCESS-CRITERIA.md has testable criteria
- [ ] All acceptance criteria met
- [ ] Test procedures executed
- [ ] Performance benchmarks passed
- [ ] Edge cases handled

### Plan Execution
- [x] PHASE-1-IMPLEMENTATION.md detailed
- [ ] Implementation matches plan
- [ ] Deviations documented
- [ ] Code reviewed

### Task Tracking
- [x] TodoWrite tracks active tasks
- [ ] All tasks completed
- [ ] Progress visible

---

## ⏱️ Timeline

**Total Estimated Time: 5-8 hours**

| Phase | Time | Status |
|-------|------|--------|
| A: Fix Performance | 2-3 hours | 🔄 In progress |
| B: Remove Over-Engineering | 1-2 hours | ⏳ Next |
| C: Add Integration | 1-2 hours | ⏳ Pending |
| D: Verification | 30 min | ⏳ Pending |
| E: Merge & Release | 1 hour | ⏳ Pending |

---

## 🎯 Success Definition

v0.4.0 is ready when:
- ✅ Fuzzy matching: <500ms for 100 dirs
- ✅ Tab completion: <100ms response
- ✅ Code complexity: ≤3/10
- ✅ All 44 tests passing
- ✅ Multi-level fuzzy working
- ✅ Bookmark fuzzy working
- ✅ No over-engineering
- ✅ Spec compliant (100%)

---

## 📚 References

- **CONSTITUTION.md** - Governing principles (new)
- **SUCCESS-CRITERIA.md** - Feature specifications
- **PHASE-1-IMPLEMENTATION.md** - Implementation guide
- **Code Review Report** - Over-engineering analysis
- **Compliance Report** - Spec gaps identified
- **Test Coverage Report** - 44 tests documented

---

**Next Action:** Start Phase A (Fix Performance) 🚀
