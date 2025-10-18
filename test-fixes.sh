#!/bin/bash
# Test script for CET-97 and CET-100 fixes

cd "$(dirname "$0")"

echo "=== Testing Path Resolution Fixes ==="
echo ""

# Load goto
source ./goto.sh

echo "Test 1: Cache lookup for Git_Repos"
result=$(__goto_cache_lookup "Git_Repos" 2>/dev/null)
if [ -n "$result" ]; then
    echo "✓ Cache lookup returned: $result"
else
    echo "✗ Cache lookup returned empty"
fi
echo ""

echo "Test 2: Navigation error handling with non-existent directory"
__goto_navigate_to "/tmp/nonexistent-test-dir-$$" 2>&1
status=$?
if [ $status -ne 0 ]; then
    echo "✓ Error handling works (exit code: $status)"
else
    echo "✗ Error handling failed (should have returned non-zero)"
fi
echo ""

echo "Test 3: Navigation to valid directory"
original_dir="$PWD"
__goto_navigate_to "$HOME/Documents/LUXOR" 2>&1
status=$?
if [ $status -eq 0 ] && [ "$PWD" = "$HOME/Documents/LUXOR" ]; then
    echo "✓ Navigation successful"
    cd "$original_dir"
else
    echo "✗ Navigation failed"
fi
echo ""

echo "Test 4: Full goto command with cache"
cd /tmp
goto Git_Repos 2>&1
if [ "$PWD" = "$HOME/Documents/LUXOR/Git_Repos" ]; then
    echo "✓ Full goto with cache works"
else
    echo "✗ Full goto failed, pwd=$PWD"
fi
echo ""

echo "=== All tests complete ==="
