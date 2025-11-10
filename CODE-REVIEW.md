# Code Review Summary

**Date:** 2025-11-10
**Reviewer:** Claude Code
**Status:** Manual review (shellcheck unavailable)

## Overview

Manual code review of all shell scripts in unix-goto project. Focus on:
- Shell best practices
- Portability issues
- Security concerns
- Error handling

---

## Critical Issues

### 1. Hardcoded Claude CLI Path (CRITICAL)
**File:** `bin/goto-resolve:55`
**Issue:** Hardcoded macOS-specific path `/Users/manu/.claude/local/claude`
**Impact:** Won't work on other systems or users
**Priority:** HIGH

**Current:**
```bash
RESPONSE=$(/Users/manu/.claude/local/claude --print --model claude-3-5-sonnet-20241022 --append-system-prompt "$SYSTEM_PROMPT" "$QUERY" 2>/dev/null)
```

**Recommendation:**
```bash
# Find claude in PATH or use common locations
CLAUDE_CMD=""
if command -v claude &> /dev/null; then
    CLAUDE_CMD="claude"
elif [ -f "$HOME/.claude/local/claude" ]; then
    CLAUDE_CMD="$HOME/.claude/local/claude"
else
    echo "Error: Claude CLI not found" >&2
    exit 1
fi

RESPONSE=$($CLAUDE_CMD --print --model claude-3-5-sonnet-20241022 --append-system-prompt "$SYSTEM_PROMPT" "$QUERY" 2>/dev/null)
```

### 2. Missing Error Check on cd Command
**File:** `lib/goto-function.sh:15`
**Issue:** `cd` command without error handling
**Impact:** Silent failures if directory doesn't exist
**Priority:** MEDIUM

**Current:**
```bash
# Navigate
cd "$target_dir"
```

**Recommendation:**
```bash
# Navigate
cd "$target_dir" || return 1
```

### 3. File Race Condition
**File:** `lib/back-command.sh:22-23`
**Issue:** Reading and writing same file simultaneously
**Impact:** Potential data corruption
**Priority:** MEDIUM

**Current:**
```bash
# Keep stack size reasonable (max 50 entries)
/usr/bin/tail -n 50 "$GOTO_STACK_FILE" > "$GOTO_STACK_FILE.tmp"
/bin/mv "$GOTO_STACK_FILE.tmp" "$GOTO_STACK_FILE"
```

**Status:** Actually correct - writes to .tmp first, then moves. No issue.

---

## Medium Priority Issues

### 4. Portability - Hardcoded Binary Paths
**Files:** Multiple
**Issue:** Using `/usr/bin/` and `/bin/` prefixes throughout
**Impact:** May not work on all Linux distributions
**Priority:** MEDIUM

**Examples:**
- `/usr/bin/grep`
- `/usr/bin/tail`
- `/bin/mv`
- `/bin/date`

**Recommendation:**
For better portability, consider:
```bash
# Option 1: Use command without path (relies on PATH)
grep instead of /usr/bin/grep

# Option 2: Find command in PATH
GREP_CMD=$(command -v grep)
```

**Note:** Current approach is acceptable for macOS-focused tool, but document Linux compatibility.

---

## Low Priority Issues

### 5. Potential Recursive Call Issue
**File:** `lib/back-command.sh:49`
**Issue:** Recursive call without depth limit
**Impact:** Could cause stack overflow if many dirs are deleted
**Priority:** LOW

**Current:**
```bash
else
    echo "⚠️  Directory no longer exists: $prev_dir"
    __goto_stack_pop  # Try the next one
fi
```

**Recommendation:**
Add depth limit or max retry count.

---

## Security Review

### ✓ Good Practices Found:

1. **Proper quoting**: Variables are quoted throughout (`"$var"`)
2. **Input validation**: Bookmark names, numeric inputs validated
3. **Path validation**: Checks for directory existence before navigation
4. **No eval usage**: No dangerous `eval` commands
5. **Local variables**: Proper use of `local` keyword
6. **Command substitution**: Safe command substitution patterns

### ⚠️ Minor Security Concerns:

1. **Natural language input**: User input passed to Claude AI
   - **Status:** Acceptable - Claude API handles sanitization

2. **File operations**: Creates files in home directory
   - **Status:** Acceptable - standard practice for user tools

---

## Code Quality

### ✓ Strengths:

1. **Consistent style**: Uniform code formatting
2. **Good comments**: Clear documentation
3. **Help text**: Comprehensive help for all commands
4. **Error messages**: User-friendly error messages with suggestions
5. **Modular design**: Functions well-separated
6. **Feature detection**: Uses `command -v` to check for optional features

### Areas for Improvement:

1. **Testing**: No automated tests (see TESTING-GUIDE.md)
2. **Documentation**: Some inline comments could be more detailed
3. **Error codes**: Inconsistent return codes (sometimes 0/1, sometimes no return)

---

## Performance Review

### ✓ Optimizations Found:

1. **maxdepth limits**: Recursive search limited to 3 levels
2. **Stack size limits**: Navigation history capped at 50 entries
3. **Direct matching first**: Fast paths before expensive operations
4. **Lazy loading**: Claude AI only called when needed

### Potential Improvements:

1. **Caching**: Could cache folder listings for faster searches
2. **Parallel search**: Could search multiple paths in parallel

---

## Recommendations Summary

### Must Fix (Before Public Release):
1. ✅ Fix hardcoded Claude CLI path in `bin/goto-resolve`

### Should Fix (Soon):
2. ✅ Add error handling to cd commands
3. 📝 Document macOS/Linux compatibility in README

### Nice to Have (Future):
4. Consider removing `/usr/bin/` prefixes for better portability
5. Add recursion depth limit to `__goto_stack_pop`
6. Add automated testing (planned in roadmap)

---

## Overall Assessment

**Grade: B+ (Very Good)**

The codebase is well-structured, follows shell scripting best practices, and has good error handling. The main issue is the hardcoded path which prevents portability. Once fixed, the code is production-ready.

### Strengths:
- Clean, readable code
- Good error handling
- User-friendly
- Modular design

### Weaknesses:
- Portability issues (hardcoded paths)
- No automated tests
- Some minor error handling gaps

---

**Next Steps:**
1. Fix hardcoded Claude CLI path
2. Add cd error handling
3. Document platform compatibility
4. Create automated test suite (Phase 3)
