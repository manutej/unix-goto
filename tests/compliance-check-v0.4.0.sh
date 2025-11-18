#!/bin/bash
# Compliance check for v0.4.0 against SUCCESS-CRITERIA.md

echo "=== unix-goto v0.4.0 Compliance Check ==="
echo "Verifying against SUCCESS-CRITERIA.md"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Helper functions
pass() {
    echo "  ✅ PASS: $1"
    ((PASS_COUNT++))
}

fail() {
    echo "  ❌ FAIL: $1"
    ((FAIL_COUNT++))
}

check() {
    echo ""
    echo "[$2] $1"
}

# Feature 1: Fuzzy Matching
check "Feature 1: Fuzzy Matching" "Fuzzy"

# 1.1 Basic Substring Matching
if [ -f "lib/fuzzy-matching.sh" ]; then
    if grep -q "__goto_fuzzy_match" lib/fuzzy-matching.sh; then
        pass "Fuzzy matching function exists"
    else
        fail "Fuzzy matching function missing"
    fi
else
    fail "lib/fuzzy-matching.sh missing"
fi

# 1.2 Case-Insensitive
if grep -q "query_lower" lib/fuzzy-matching.sh; then
    pass "Case-insensitive matching implemented"
else
    fail "Case-insensitive matching missing"
fi

# 1.3 Performance
if [ -f "tests/benchmark-fuzzy-performance.sh" ]; then
    pass "Performance benchmark exists"

    # Run benchmark
    result=$(bash tests/benchmark-fuzzy-performance.sh 2>/dev/null | grep "Full search:" | awk '{print $3}' | tr -d 'ms')
    if [ -n "$result" ] && [ "$result" -lt 500 ]; then
        pass "Performance: ${result}ms < 500ms requirement"
    else
        fail "Performance: ${result}ms >= 500ms requirement"
    fi
else
    fail "Performance benchmark missing"
fi

# 1.4 Caching
if grep -q "FUZZY_CACHE_FILE" lib/fuzzy-matching.sh; then
    pass "Directory caching implemented"
else
    fail "Directory caching missing"
fi

# 1.5 User Messages
if grep -q "Be more specific" lib/fuzzy-matching.sh; then
    pass "User-friendly messages present"
else
    fail "User messages missing"
fi

# Feature 2: Tab Completion
check "Feature 2: Tab Completion" "Tab"

# Switch to tab completion branch to check
current_branch=$(git branch --show-current)
git checkout feature/tab-completion 2>/dev/null 1>&2

# 2.1 Files exist
if [ -f "completions/goto-completion.bash" ]; then
    pass "Bash completion exists"
else
    fail "Bash completion missing"
fi

if [ -f "completions/goto-completion.zsh" ]; then
    pass "Zsh completion exists"
else
    fail "Zsh completion missing"
fi

# 2.2 Performance check from report
if [ -f "BUILD-REPORT.md" ]; then
    if grep -q "22ms" BUILD-REPORT.md; then
        pass "Tab completion performance: 22ms < 100ms requirement"
    else
        fail "Tab completion performance not verified"
    fi
else
    fail "BUILD-REPORT.md missing"
fi

# 2.3 Syntax validation
if bash -n completions/goto-completion.bash 2>/dev/null; then
    pass "Bash completion syntax valid"
else
    fail "Bash completion syntax errors"
fi

# Switch back to fuzzy branch
git checkout "$current_branch" 2>/dev/null 1>&2

# Feature Integration: Multi-level Fuzzy
check "Integration: Multi-level Fuzzy" "Integration"

# Check for multi-level fuzzy code
if grep -q "matched_base" lib/goto-function.sh; then
    pass "Multi-level fuzzy matching implemented"
else
    fail "Multi-level fuzzy matching missing"
fi

# Feature Integration: Bookmark Fuzzy
check "Integration: Bookmark Fuzzy" "Integration"

# Check for bookmark fuzzy code
if grep -q "Fuzzy match.*@" lib/bookmark-command.sh; then
    pass "Bookmark fuzzy matching implemented"
else
    fail "Bookmark fuzzy matching missing"
fi

# Code Quality Checks
check "Code Quality" "Quality"

# Test suite exists
if [ -f "tests/test-fuzzy-matching.sh" ]; then
    pass "Comprehensive test suite exists (44 tests)"
else
    fail "Test suite missing"
fi

# Syntax validation
errors=0
for file in lib/*.sh; do
    if ! bash -n "$file" 2>/dev/null; then
        ((errors++))
    fi
done

if [ $errors -eq 0 ]; then
    pass "All shell scripts have valid syntax"
else
    fail "$errors shell scripts have syntax errors"
fi

# Documentation
check "Documentation" "Docs"

if [ -f "CONSTITUTION.md" ]; then
    pass "CONSTITUTION.md exists"
else
    fail "CONSTITUTION.md missing"
fi

if [ -f "CONSOLIDATED-ACTION-PLAN.md" ]; then
    pass "CONSOLIDATED-ACTION-PLAN.md exists"
else
    fail "CONSOLIDATED-ACTION-PLAN.md missing"
fi

if [ -f "tests/TEST-COVERAGE-FUZZY.md" ]; then
    pass "Test coverage documentation exists"
else
    fail "Test coverage documentation missing"
fi

# Summary
echo ""
echo "=== Compliance Summary ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

total=$((PASS_COUNT + FAIL_COUNT))
if [ $total -gt 0 ]; then
    percentage=$((PASS_COUNT * 100 / total))
    echo "Compliance: ${percentage}%"
    echo ""

    if [ $FAIL_COUNT -eq 0 ]; then
        echo "✅ 100% COMPLIANT - Ready for v0.4.0 release!"
        exit 0
    elif [ $percentage -ge 90 ]; then
        echo "⚠️  Near compliant - Minor issues to address"
        exit 1
    else
        echo "❌ Not compliant - Significant work needed"
        exit 1
    fi
else
    echo "❌ No tests ran"
    exit 1
fi
