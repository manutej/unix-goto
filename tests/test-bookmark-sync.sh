#!/bin/bash
# Test bookmark sync functionality

# Test setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_CONFIG="/tmp/.goto_config.test.$$"
TEST_BOOKMARKS="/tmp/.goto_bookmarks.test.$$"
TEST_WORKSPACE="/tmp/goto_test_workspace.$$"

# Override environment
export GOTO_BOOKMARKS_FILE="$TEST_BOOKMARKS"

# Source the bookmark command
source "$SCRIPT_DIR/../lib/bookmark-command.sh"
source "$SCRIPT_DIR/../lib/fuzzy-matching.sh"

# Test counters
PASS=0
FAIL=0

# Helper functions
pass() {
    echo "  ✅ PASS: $1"
    ((PASS++))
}

fail() {
    echo "  ❌ FAIL: $1"
    ((FAIL++))
}

cleanup() {
    rm -rf "$TEST_CONFIG" "$TEST_BOOKMARKS" "$TEST_WORKSPACE"
}

# Trap cleanup on exit
trap cleanup EXIT

# Create test workspace
mkdir -p "$TEST_WORKSPACE/projects/GAI-3101"
mkdir -p "$TEST_WORKSPACE/projects/HALCON"
mkdir -p "$TEST_WORKSPACE/projects/WA3590"
mkdir -p "$TEST_WORKSPACE/code/personal"
mkdir -p "$TEST_WORKSPACE/code/.hidden"

echo "=== Testing Bookmark Sync Functionality ==="
echo ""

# Test 1: No config file
echo "[Test 1] No config file handling"
HOME="/nonexistent" __goto_bookmark_sync >/dev/null 2>&1
if [ $? -eq 1 ]; then
    pass "Returns error when config doesn't exist"
else
    fail "Should return error when config doesn't exist"
fi

# Test 2: Empty config
echo ""
echo "[Test 2] Empty config handling"
echo "# Empty config" > "$TEST_CONFIG"
HOME="$TEST_CONFIG" __goto_bookmark_sync >/dev/null 2>&1
if [ $? -eq 1 ]; then
    pass "Returns error for empty config"
else
    fail "Should return error for empty config"
fi

# Test 3: Valid config with one workspace
echo ""
echo "[Test 3] Single workspace sync"
cat > "$TEST_CONFIG" <<EOF
# Test config
$TEST_WORKSPACE/projects
EOF

# Override HOME for this test
HOME_BACKUP="$HOME"
HOME=$(dirname "$TEST_CONFIG")
mv "$TEST_CONFIG" "$HOME/.goto_config"

__goto_bookmark_sync >/dev/null 2>&1

# Check bookmarks were created
if grep -q "^projects|" "$TEST_BOOKMARKS"; then
    pass "Workspace bookmark created"
else
    fail "Workspace bookmark not created"
fi

if grep -q "^gai-3101|" "$TEST_BOOKMARKS"; then
    pass "Subdirectory bookmark created (gai-3101)"
else
    fail "Subdirectory bookmark not created (gai-3101)"
fi

if grep -q "^halcon|" "$TEST_BOOKMARKS"; then
    pass "Subdirectory bookmark created (halcon)"
else
    fail "Subdirectory bookmark not created (halcon)"
fi

# Test 4: Lowercase conversion
echo ""
echo "[Test 4] Lowercase conversion"
bookmark_name=$(grep "^gai-3101|" "$TEST_BOOKMARKS" | cut -d'|' -f1)
if [ "$bookmark_name" = "gai-3101" ]; then
    pass "Names converted to lowercase"
else
    fail "Names not converted to lowercase: $bookmark_name"
fi

# Test 5: Hidden directories skipped
echo ""
echo "[Test 5] Hidden directories"
if ! grep -q "^.hidden|" "$TEST_BOOKMARKS"; then
    pass "Hidden directories skipped"
else
    fail "Hidden directories should be skipped"
fi

# Test 6: Sync tracking
echo ""
echo "[Test 6] Sync tracking flag"
if grep -q "|sync$" "$TEST_BOOKMARKS"; then
    pass "Sync flag added to synced bookmarks"
else
    fail "Sync flag not added"
fi

# Test 7: Multiple workspaces
echo ""
echo "[Test 7] Multiple workspace paths"
cat > "$HOME/.goto_config" <<EOF
$TEST_WORKSPACE/projects
$TEST_WORKSPACE/code
EOF

rm -f "$TEST_BOOKMARKS"
__goto_bookmark_sync >/dev/null 2>&1

bookmark_count=$(wc -l < "$TEST_BOOKMARKS")
if [ "$bookmark_count" -ge 6 ]; then
    pass "Multiple workspaces processed (found $bookmark_count bookmarks)"
else
    fail "Expected >= 6 bookmarks, got $bookmark_count"
fi

# Test 8: Update existing bookmark
echo ""
echo "[Test 8] Update existing bookmark path"
# Add a bookmark manually with different path
echo "projects|/tmp/oldpath|$(date +%s)|manual" > "$TEST_BOOKMARKS"

__goto_bookmark_sync >/dev/null 2>&1

updated_path=$(grep "^projects|" "$TEST_BOOKMARKS" | cut -d'|' -f2)
if [[ "$updated_path" == "$TEST_WORKSPACE/projects" ]]; then
    pass "Existing bookmark path updated"
else
    fail "Bookmark path not updated: $updated_path"
fi

# Test 9: Skip unchanged bookmarks
echo ""
echo "[Test 9] Skip unchanged bookmarks"
# Run sync twice
rm -f "$TEST_BOOKMARKS"
output1=$(__goto_bookmark_sync 2>&1)
output2=$(__goto_bookmark_sync 2>&1)

if echo "$output2" | grep -q "Skipped:"; then
    pass "Unchanged bookmarks skipped on re-sync"
else
    fail "Should skip unchanged bookmarks"
fi

# Test 10: Non-existent path warning
echo ""
echo "[Test 10] Non-existent path handling"
cat > "$HOME/.goto_config" <<EOF
$TEST_WORKSPACE/projects
/nonexistent/path
EOF

output=$(__goto_bookmark_sync 2>&1)
if echo "$output" | grep -q "Skipping non-existent path"; then
    pass "Warning shown for non-existent paths"
else
    fail "Should warn about non-existent paths"
fi

# Restore HOME
HOME="$HOME_BACKUP"

# Summary
echo ""
echo "=== Test Summary ==="
echo "PASSED: $PASS"
echo "FAILED: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
