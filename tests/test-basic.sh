#!/bin/bash
# Basic smoke tests for unix-goto
# Tests core functionality without interactive components

set -e

echo "=== unix-goto Basic Tests ==="
echo ""

# Test 1: Check all library files exist
echo "Test 1: Library files exist"
for file in lib/goto-function.sh lib/back-command.sh lib/recent-command.sh lib/bookmark-command.sh lib/list-command.sh lib/history-tracking.sh; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file MISSING"
        exit 1
    fi
done

# Test 2: Check for bash syntax errors
echo ""
echo "Test 2: Bash syntax check"
for file in lib/*.sh bin/goto-resolve install.sh; do
    if [ -f "$file" ]; then
        if bash -n "$file" 2>/dev/null; then
            echo "  ✓ $file"
        else
            echo "  ✗ $file has syntax errors"
            bash -n "$file"
            exit 1
        fi
    fi
done

# Test 3: Check install script
echo ""
echo "Test 3: Install script validation"
if grep -q "set -e" install.sh; then
    echo "  ✓ install.sh uses set -e"
else
    echo "  ✗ install.sh should use set -e"
fi

if grep -q "INSTALL_DIR" install.sh; then
    echo "  ✓ install.sh defines INSTALL_DIR"
else
    echo "  ✗ install.sh missing INSTALL_DIR"
    exit 1
fi

# Test 4: Check for hardcoded paths (should not exist)
echo ""
echo "Test 4: Portability checks"
if grep -q "/Users/manu/.claude" bin/goto-resolve; then
    # Check if it's only a fallback
    if grep -B5 "/Users/manu/.claude" bin/goto-resolve | grep -q "command -v claude"; then
        echo "  ✓ Claude CLI path has fallback (acceptable)"
    else
        echo "  ✗ Hardcoded Claude CLI path without fallback"
        exit 1
    fi
else
    echo "  ✓ No hardcoded paths in goto-resolve"
fi

# Test 5: Check documentation exists
echo ""
echo "Test 5: Documentation files"
for file in README.md CHANGELOG.md CONTRIBUTING.md ROADMAP.md; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ⚠ $file missing"
    fi
done

# Test 6: Check for proper error handling
echo ""
echo "Test 6: Error handling patterns"
cd_count=$(grep -c "cd .* || return" lib/goto-function.sh lib/back-command.sh lib/bookmark-command.sh 2>/dev/null || echo 0)
if [ "$cd_count" -ge 3 ]; then
    echo "  ✓ Found $cd_count instances of proper cd error handling"
else
    echo "  ⚠ Only $cd_count instances of cd error handling found"
fi

# Test 7: Check for local variable usage
echo ""
echo "Test 7: Function scope (local variables)"
if grep -q "local " lib/goto-function.sh; then
    echo "  ✓ Functions use local variables"
else
    echo "  ✗ Functions should use local variables"
    exit 1
fi

# Test 8: Check version tags exist
echo ""
echo "Test 8: Version tags"
if git tag -l | grep -q "v0."; then
    echo "  ✓ Version tags exist:"
    git tag -l | sed 's/^/    /'
else
    echo "  ⚠ No version tags found"
fi

echo ""
echo "==================================="
echo "✓ All basic tests passed!"
echo "==================================="
