# unix-goto Testing Guide

**Last Updated:** 2025-10-07
**Version Coverage:** v0.2.0 (Phases 1 & 2)

---

## 🧪 Testing Philosophy

**Before ANY commit or release:**
1. Run through ALL test scenarios
2. Verify no regressions in existing features
3. Test new features in isolation
4. Test integration between features
5. Document any failures or unexpected behavior

---

## ✅ Pre-Commit Test Checklist

Copy this checklist for each test run:

```markdown
## Test Run: [Date] - [Branch/Commit]

### Phase 1: Core Navigation
- [ ] Direct shortcuts (luxor, halcon, docs, infra)
- [ ] Direct folder matching
- [ ] Natural language resolution
- [ ] Special commands (~, zshrc, --help)

### Phase 2: History & Bookmarks
- [ ] back command
- [ ] recent command
- [ ] bookmark command (full CRUD)
- [ ] goto list command
- [ ] @ prefix syntax

### Integration Tests
- [ ] History tracking on all navigations
- [ ] Navigation helpers work across commands
- [ ] Error handling and edge cases

### Regression Tests
- [ ] All Phase 1 features still work
- [ ] No broken integrations
```

---

## 📋 Detailed Test Scenarios

### 1. Phase 1: Core Navigation Tests

#### 1.1 Direct Shortcuts
```bash
# Test: luxor shortcut
goto luxor
# Expected: Navigate to ~/Documents/LUXOR
# Verify: pwd shows correct path

# Test: halcon shortcut
goto halcon
# Expected: Navigate to ~/Documents/LUXOR/PROJECTS/HALCON
# Verify: pwd shows correct path

# Test: docs shortcut
goto docs
# Expected: Navigate to ~/ASCIIDocs
# Verify: pwd shows correct path

# Test: infra shortcut
goto infra
# Expected: Navigate to ~/ASCIIDocs/infra
# Verify: pwd shows correct path
```

**Pass Criteria:**
- ✅ Navigates to correct directory
- ✅ Prints "→ [path]" confirmation
- ✅ pwd confirms location

#### 1.2 Direct Folder Matching
```bash
# Setup: Ensure test folders exist in search paths
# Test: Direct folder name
cd ~
goto GAI-3101  # or any project folder in search paths
# Expected: Navigate to first match in search paths
# Verify: pwd shows folder

# Test: Non-existent folder
goto NONEXISTENT_FOLDER_12345
# Expected: "❌ Project not found: NONEXISTENT_FOLDER_12345"
# Verify: No navigation, stays in current directory
```

**Pass Criteria:**
- ✅ Finds folders in all configured search paths
- ✅ Prioritizes first match
- ✅ Clear error message for non-existent folders
- ✅ Remains in current directory on failure

#### 1.3 Natural Language Resolution
```bash
# Test: Natural language query
goto "the halcon project"
# Expected: Uses Claude AI, resolves to "halcon", navigates
# Verify: See "🤖 Using natural language processing..."
# Verify: Eventually navigates to halcon

# Test: Natural language with spaces
goto "infrastructure folder"
# Expected: Resolves to "infra" or similar
# Verify: Successful navigation

# Note: Requires Claude CLI to be properly configured
```

**Pass Criteria:**
- ✅ Shows "🤖 Using natural language processing..." message
- ✅ Claude AI resolver (goto-resolve) is found and executed
- ✅ Successfully interprets and navigates
- ✅ Falls back gracefully if AI unavailable

#### 1.4 Special Commands
```bash
# Test: Home directory
cd /tmp
goto ~
# Expected: Navigate to $HOME
# Verify: pwd shows $HOME

# Test: zshrc command
goto zshrc
# Expected: Sources ~/.zshrc, displays contents (with glow if available)
# Verify: No errors, .zshrc contents shown

# Test: Help
goto --help
# Expected: Display comprehensive help menu
# Verify: Shows usage, shortcuts, bookmarks, natural language sections

# Test: Empty/no argument
goto
# Expected: Display help (same as --help)
# Verify: Help menu appears
```

**Pass Criteria:**
- ✅ goto ~ returns to home
- ✅ goto zshrc sources and displays
- ✅ goto --help shows complete help
- ✅ goto (empty) shows help

---

### 2. Phase 2: Navigation History & Bookmarks Tests

#### 2.1 back Command
```bash
# Test: Basic back navigation
cd ~
goto luxor
goto docs
back
# Expected: Return to luxor directory
# Verify: pwd shows ~/Documents/LUXOR

# Test: Back with numeric argument
cd ~
goto luxor
goto docs
goto infra
back 2
# Expected: Go back 2 directories (to luxor)
# Verify: pwd shows ~/Documents/LUXOR

# Test: back --list
back --list
# Expected: Display directory history stack
# Verify: Shows list with indices

# Test: back at start
cd ~
# Clear any existing history
back --clear
back
# Expected: "⚠️  Already at the first directory"
# Verify: No navigation, stays in place

# Test: back --clear
goto luxor
goto docs
back --clear
# Expected: "✓ Navigation history cleared"
# Verify: Stack is reset
```

**Pass Criteria:**
- ✅ back navigates to previous directory
- ✅ back N goes back N steps
- ✅ back --list shows history
- ✅ back --clear resets history
- ✅ Error message at beginning of history

#### 2.2 recent Command
```bash
# Setup: Create some navigation history
goto luxor
goto docs
goto infra
goto halcon

# Test: List recent folders
recent
# Expected: Shows 10 most recent folders (default)
# Verify: Displays formatted list with timestamps

# Test: List N recent folders
recent 3
# Expected: Shows only 3 most recent folders
# Verify: Exactly 3 entries shown

# Test: Navigate to recent folder
recent --goto 2
# Expected: Navigate to 2nd folder in recent list
# Verify: pwd confirms navigation

# Test: recent --clear
recent --clear
# Expected: "✓ Recent history cleared"
# Verify: History file emptied

# Test: recent with no history
recent
# Expected: "No recent folders yet"
# Verify: Helpful message shown
```

**Pass Criteria:**
- ✅ recent shows most recent folders
- ✅ recent N limits to N entries
- ✅ recent --goto N navigates correctly
- ✅ recent --clear resets history
- ✅ Handles empty history gracefully

#### 2.3 bookmark Command (Full CRUD)
```bash
# Test: Add bookmark (current directory)
cd ~/Documents/LUXOR
bookmark add testbm
# Expected: "✓ Bookmarked 'testbm' → /Users/.../Documents/LUXOR"
# Verify: Message confirms bookmark

# Test: Add bookmark with explicit path
bookmark add testbm2 ~/ASCIIDocs
# Expected: "✓ Bookmarked 'testbm2' → /Users/.../ASCIIDocs"

# Test: Add duplicate bookmark
bookmark add testbm
# Expected: "⚠️  Bookmark 'testbm' already exists"
# Verify: Error message, bookmark not added

# Test: List bookmarks
bookmark list
# Expected: Shows all bookmarks with paths
# Verify: testbm and testbm2 appear

# Test: Navigate to bookmark (direct)
cd ~
bookmark goto testbm
# Expected: Navigate to ~/Documents/LUXOR
# Verify: pwd confirms

# Test: Navigate to bookmark (@ syntax)
cd ~
goto @testbm2
# Expected: Navigate to ~/ASCIIDocs
# Verify: pwd confirms

# Test: Remove bookmark
bookmark rm testbm
# Expected: "✓ Removed bookmark: testbm"
# Verify: bookmark gone from list

# Test: Bookmark alias (bm)
bm add test3
bm list
# Expected: Works exactly like bookmark command
# Verify: test3 appears in list

# Cleanup
bm rm testbm2
bm rm test3
```

**Pass Criteria:**
- ✅ bookmark add creates bookmark
- ✅ bookmark add with path works
- ✅ Duplicate prevention works
- ✅ bookmark list shows all
- ✅ bookmark goto navigates
- ✅ goto @ prefix works
- ✅ bookmark rm removes
- ✅ bm alias works identically

#### 2.4 goto list Command
```bash
# Test: List all destinations
goto list
# Expected: Shows shortcuts, bookmarks, and available folders
# Verify: Sections clearly labeled with colors/emojis

# Test: Filter shortcuts only
goto list --shortcuts
# Expected: Shows only luxor, halcon, docs, infra
# Verify: No bookmarks or folders shown

# Test: Filter bookmarks only
bookmark add templist
goto list --bookmarks
# Expected: Shows only bookmarks
# Verify: templist appears
bookmark rm templist

# Test: Filter folders only
goto list --folders
# Expected: Shows only folders from search paths
# Verify: No shortcuts or bookmarks

# Test: goto list --help
goto list --help
# Expected: Shows usage information
# Verify: Help text displayed
```

**Pass Criteria:**
- ✅ goto list shows all categories
- ✅ --shortcuts filter works
- ✅ --bookmarks filter works
- ✅ --folders filter works
- ✅ Output is formatted with colors
- ✅ Help is available

---

### 3. Integration Tests

#### 3.1 History Tracking Integration
```bash
# Test: goto commands tracked in history
goto luxor
goto docs
back --list
# Expected: Both navigations in back history
recent
# Expected: Both appear in recent list

# Test: Bookmark navigation tracked
bookmark add inttest ~/Documents/LUXOR
goto @inttest
back --list
# Expected: Bookmark navigation in history
recent
# Expected: Bookmark destination in recent list

# Cleanup
bookmark rm inttest
```

**Pass Criteria:**
- ✅ All goto navigations tracked
- ✅ back and recent share consistent history
- ✅ Bookmark navigations tracked

#### 3.2 Navigation Helper Integration
```bash
# Test: __goto_navigate_to helper used consistently
# This is internal, verify via behavior:
goto luxor
back
# Expected: back works after goto (proves stack push worked)

goto @bookmark_if_exists
# Expected: Bookmark uses same navigation helper
# Verify: History tracking works
```

**Pass Criteria:**
- ✅ Navigation helper consistent across commands
- ✅ History tracking works everywhere

---

### 4. Edge Cases & Error Handling

#### 4.1 Invalid Inputs
```bash
# Test: Invalid bookmark name
bookmark add ""
# Expected: "❌ Error: Bookmark name required"

# Test: Bookmark non-existent path
bookmark add badpath /nonexistent/path/12345
# Expected: "❌ Error: Directory does not exist"

# Test: Remove non-existent bookmark
bookmark rm NOTEXIST_12345
# Expected: "❌ Bookmark not found"

# Test: goto to non-existent bookmark
goto @NOTEXIST_12345
# Expected: "❌ Bookmark not found"

# Test: recent --goto out of range
recent --goto 999
# Expected: "⚠️  No folder at index 999"
```

**Pass Criteria:**
- ✅ All errors handled gracefully
- ✅ Clear, helpful error messages
- ✅ No crashes or undefined behavior

#### 4.2 File Permissions & Missing Files
```bash
# Test: History file doesn't exist
rm ~/.goto_history 2>/dev/null
recent
# Expected: Creates file, shows "No recent folders yet"

# Test: Bookmarks file doesn't exist
rm ~/.goto_bookmarks 2>/dev/null
bookmark list
# Expected: Creates file, shows "No bookmarks yet"

# Test: Stack file doesn't exist
rm ~/.goto_stack 2>/dev/null
back
# Expected: Creates file, shows appropriate message
```

**Pass Criteria:**
- ✅ Missing files created automatically
- ✅ No errors on first use
- ✅ Graceful initialization

---

## 🔄 Regression Testing

**After EVERY change, verify:**

### Regression Checklist
```markdown
- [ ] All Phase 1 shortcuts still work
- [ ] Direct folder matching unchanged
- [ ] Natural language still processes
- [ ] Special commands (~, zshrc, --help) work
- [ ] back command still navigates correctly
- [ ] recent command shows history
- [ ] Bookmarks CRUD operations work
- [ ] goto list displays all destinations
- [ ] History tracking captures all navigations
- [ ] Error messages are clear and helpful
```

---

## 🚨 Known Testing Limitations

1. **Claude AI Testing**
   - Natural language queries require Claude CLI
   - May vary based on API availability
   - Hard to test deterministically

2. **File System Dependent**
   - Tests assume specific directory structure
   - Paths may vary per machine
   - Search paths need to exist

3. **Shell State**
   - Tests affect global history files
   - May need cleanup between runs
   - Current directory state matters

---

## 📊 Test Results Template

Use this template to document test runs:

```markdown
# Test Run: [Date]

**Branch:** [branch-name]
**Commit:** [commit-hash]
**Tester:** [name]

## Results

### Phase 1 Tests
- Direct Shortcuts: ✅ PASS / ❌ FAIL
- Folder Matching: ✅ PASS / ❌ FAIL
- Natural Language: ✅ PASS / ❌ FAIL
- Special Commands: ✅ PASS / ❌ FAIL

### Phase 2 Tests
- back Command: ✅ PASS / ❌ FAIL
- recent Command: ✅ PASS / ❌ FAIL
- bookmark Command: ✅ PASS / ❌ FAIL
- goto list: ✅ PASS / ❌ FAIL

### Integration Tests
- History Tracking: ✅ PASS / ❌ FAIL
- Navigation Helpers: ✅ PASS / ❌ FAIL

### Edge Cases
- Error Handling: ✅ PASS / ❌ FAIL
- File Permissions: ✅ PASS / ❌ FAIL

### Regression Tests
- No Regressions: ✅ PASS / ❌ FAIL

## Issues Found
[List any failures or unexpected behavior]

## Notes
[Additional observations]
```

---

## 🎯 Future: Automated Testing

**Planned for Technical Improvements:**

1. **Shell Script Test Framework**
   - Use `bats` (Bash Automated Testing System)
   - Or custom shell test runner
   - Automated regression suite

2. **CI/CD Integration**
   - Run tests on PR creation
   - Block merge on test failures
   - Automated test reports

3. **Mocking**
   - Mock Claude AI calls for deterministic tests
   - Mock file system operations
   - Isolated test environment

---

**Maintained By:** Manu Tej + Claude Code
**Update Policy:** Update this guide when new features are added
