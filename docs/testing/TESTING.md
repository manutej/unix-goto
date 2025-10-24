# unix-goto Manual Testing Guide

This guide will help you test all features of unix-goto before deployment.

## Prerequisites

Before testing, ensure you have:
- [ ] Sourced the shell configuration: `source ~/.zshrc`
- [ ] Claude CLI installed and working: `which claude`
- [ ] Test directories available (ASCIIDocs, LUXOR, etc.)

## Test Suite

### 1. Basic Navigation Tests

#### Test 1.1: Direct Shortcuts
```bash
# Test each shortcut
goto luxor          # Should navigate to ~/Documents/LUXOR
pwd                 # Verify current directory

goto docs           # Should navigate to ~/ASCIIDocs
pwd

goto infra          # Should navigate to ~/ASCIIDocs/infra
pwd

goto halcon         # Should navigate to ~/Documents/LUXOR/PROJECTS/HALCON
pwd
```

**Expected:** Each command navigates to correct directory and shows "→ /path"

#### Test 1.2: Direct Folder Matching
```bash
# Navigate to a folder in search paths
goto GAI-3101       # Should find in ASCIIDocs
pwd

goto HALCON         # Should find in LUXOR/PROJECTS
pwd
```

**Expected:** Finds and navigates to folders across search paths

#### Test 1.3: Special Commands
```bash
goto ~              # Should go to home directory
pwd                 # Should show $HOME

goto --help         # Should display help menu
goto -h             # Should also display help menu

goto                # Should display help (no args)
```

**Expected:** Special commands work correctly

---

### 2. Natural Language Navigation Tests

#### Test 2.1: Natural Language with Claude AI
```bash
# Test natural language queries (must quote multi-word phrases)
goto "the halcon project"
pwd                 # Should be in HALCON directory

goto "infrastructure folder"
pwd                 # Should be in infra directory

goto "luxor root"
pwd                 # Should be in LUXOR directory
```

**Expected:**
- Shows "🤖 Using natural language processing..." message
- Claude resolves query correctly
- Navigates to resolved location

#### Test 2.2: Natural Language Edge Cases
```bash
# Test without quotes (should only search for first word)
cd ~
goto infrastructure folder    # Only searches for "infrastructure"
pwd

# Test unrecognized query
goto "something that doesnt exist"
```

**Expected:**
- First test works (searches for "infrastructure")
- Second test shows error message

---

### 3. Navigation History Tests

#### Test 3.1: Back Command
```bash
# Create navigation history
goto luxor
goto docs
goto infra
goto halcon

# Test back command
back                # Should return to infra
pwd

back                # Should return to docs
pwd

back 2              # Should go back 2 steps to luxor
pwd

back --list         # Should show navigation stack
```

**Expected:**
- back navigates to previous directories
- back N goes back N steps
- back --list shows history with current marked

#### Test 3.2: Back Command Edge Cases
```bash
# Test at beginning of stack
cd ~/Documents/LUXOR/Git_Repos/unix-goto
back
back
back
back                # Should show warning about first directory

# Clear and test
back --clear
back --list         # Should show minimal/empty history
```

**Expected:**
- Warning when at beginning of stack
- Clear removes history
- Graceful handling of edge cases

---

### 4. Recent Folders Tests

#### Test 4.1: Recent Command
```bash
# Build up recent history
goto luxor
goto docs
goto infra
goto halcon
goto GAI-3101

# View recent folders
recent              # Should show 10 most recent
recent 20           # Should show 20 most recent (if available)
recent --help       # Should show help
```

**Expected:**
- Recent folders displayed in reverse chronological order
- Current directory highlighted
- Numbered list

#### Test 4.2: Recent Navigation
```bash
recent              # Note which folder is at position 3
recent --goto 3     # Should navigate to that folder
pwd                 # Verify location

recent -g 1         # Short form should work
pwd
```

**Expected:**
- Navigates to correct folder by index
- Short form (-g) works

#### Test 4.3: Recent Clear
```bash
recent --clear      # Should clear recent history
recent              # Should show "No recent history yet" message
```

**Expected:** Clear removes history

---

### 5. Bookmark Tests

#### Test 5.1: Add Bookmarks
```bash
# Add bookmark to current directory
cd ~/Documents/LUXOR
bookmark add testluxor
# Should show: ✓ Bookmarked 'testluxor' → /Users/manu/Documents/LUXOR

# Add bookmark with specific path
bookmark add testdocs ~/ASCIIDocs
# Should show: ✓ Bookmarked 'testdocs' → /Users/manu/ASCIIDocs

# Test duplicate (should fail)
bookmark add testluxor
# Should show warning about existing bookmark
```

**Expected:**
- Bookmarks created successfully
- Duplicate detection works
- Confirmation messages shown

#### Test 5.2: List Bookmarks
```bash
bookmark list       # Should show all bookmarks
bm list             # Short alias should work
bookmark ls         # Alternative command should work
```

**Expected:**
- Formatted list with names and paths
- Count of total bookmarks
- Usage instructions

#### Test 5.3: Navigate to Bookmarks
```bash
# Full command
bookmark goto testdocs
pwd                 # Should be in ASCIIDocs

# Short command
bookmark go testluxor
pwd                 # Should be in LUXOR

# @ prefix syntax (THE KEY FEATURE!)
goto @testdocs
pwd                 # Should be in ASCIIDocs

goto @testluxor
pwd                 # Should be in LUXOR
```

**Expected:**
- All methods navigate correctly
- @ prefix integrates with goto seamlessly

#### Test 5.4: Remove Bookmarks
```bash
bookmark list       # Note existing bookmarks

bookmark rm testluxor
# Should show: ✓ Removed bookmark: testluxor

bookmark list       # Should not show testluxor anymore

# Test removing non-existent
bookmark rm nonexistent
# Should show error message
```

**Expected:**
- Removal works correctly
- List updates
- Error on non-existent bookmark

#### Test 5.5: Bookmark Edge Cases
```bash
# Try to add bookmark to non-existent path
bookmark add badpath /path/that/doesnt/exist
# Should show error

# Try to goto non-existent bookmark
goto @nonexistent
# Should show error

# Try to goto bookmark whose path was deleted
bookmark add temptest /tmp/temptest_unix_goto
mkdir /tmp/temptest_unix_goto
bookmark add temptest
rmdir /tmp/temptest_unix_goto
goto @temptest
# Should show warning about directory not existing
bookmark rm temptest
```

**Expected:** Graceful error handling for all edge cases

---

### 6. Discovery Tests

#### Test 6.1: List All Destinations
```bash
goto list           # Should show all: shortcuts, bookmarks, folders
```

**Expected:**
- Categorized output with colors:
  - ⚡ Shortcuts (yellow)
  - 🔖 Bookmarks (cyan)
  - 📁 Folders (green)
  - 💡 Tips (magenta)

#### Test 6.2: Filtered Lists
```bash
goto list --shortcuts   # Only show shortcuts
goto list -s            # Short form

goto list --bookmarks   # Only show bookmarks
goto list -b            # Short form

goto list --folders     # Only show folders
goto list -f            # Short form

goto list --help        # Show help
```

**Expected:** Each filter shows only requested category

---

### 7. Configuration Tests

#### Test 7.1: View Shell Config
```bash
goto zshrc          # Should source and display with glow/cat
```

**Expected:**
- Sources configuration
- Displays with syntax highlighting (if glow available)
- Shows "Sourcing ~/.zshrc..." message

---

### 8. Integration Tests

#### Test 8.1: History Tracking with All Commands
```bash
# Clear histories
back --clear
recent --clear

# Navigate using different methods
goto luxor          # Direct shortcut
goto GAI-3101       # Folder name
goto @testdocs      # Bookmark (if exists)

# Check histories
back --list         # Should show all navigations
recent              # Should show all navigations
```

**Expected:** All navigation methods populate history correctly

#### Test 8.2: Combined Workflow
```bash
# Real-world workflow
goto list                           # Explore available destinations
bookmark add mywork ~/Documents/LUXOR/PROJECTS/HALCON
goto @mywork                        # Navigate to bookmark
goto GAI-3101                       # Navigate to folder
back                                # Go back to mywork
recent                              # See recent folders
recent --goto 3                     # Jump to recent folder
goto list --bookmarks               # Check bookmarks
bookmark rm mywork                  # Cleanup
```

**Expected:** All commands work together seamlessly

---

## Cleanup After Testing

```bash
# Remove test bookmarks
bookmark list
bookmark rm testluxor
bookmark rm testdocs
bookmark rm mywork

# Optionally clear histories
back --clear
recent --clear

# Navigate back to test directory
goto unix-goto
# or
cd ~/Documents/LUXOR/Git_Repos/unix-goto
```

---

## Test Results Checklist

After completing all tests, verify:

- [ ] All shortcuts work correctly
- [ ] Direct folder matching works
- [ ] Natural language processing works (requires Claude)
- [ ] back command navigates history correctly
- [ ] recent command shows and navigates correctly
- [ ] Bookmarks can be added, listed, used, and removed
- [ ] @ prefix syntax works with goto
- [ ] goto list shows all destinations correctly
- [ ] Filtered lists work (--shortcuts, --folders, --bookmarks)
- [ ] History tracking works across all navigation methods
- [ ] Error messages are helpful and clear
- [ ] Help commands display correct information

---

## Known Issues to Check

1. **Claude AI dependency**: Natural language features require Claude CLI
2. **Path dependencies**: Shortcuts assume specific directory structure
3. **Shell compatibility**: Primarily tested on zsh
4. **History files**: Check ~/.goto_history, ~/.goto_stack, ~/.goto_bookmarks exist

---

## Performance Notes

- Direct shortcuts: Instant
- Folder matching: Very fast (< 0.1s)
- Natural language: 1-2 seconds (Claude API call)
- History operations: Instant
- List operations: Fast (< 0.5s)

---

## Report Issues

If any test fails, note:
1. Which test failed
2. Expected behavior
3. Actual behavior
4. Error messages
5. Shell version and OS

Ready to commit when all tests pass! ✅
