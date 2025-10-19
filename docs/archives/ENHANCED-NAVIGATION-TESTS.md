# Enhanced Navigation Testing Guide

**Feature Branch:** feature/enhanced-navigation
**Commit:** b07fea1
**Date:** 2025-10-07

---

## 🎯 New Features to Test

### 1. Multi-Level Navigation
Navigate to nested folders using path separators

### 2. Recursive Unique Folder Search
Find folders by name even if they're nested deep

---

## 📋 Test Scenarios

### Feature 1: Multi-Level Navigation Tests

#### Test 1.1: Basic Multi-Level Path
```bash
# Test: Navigate to nested folder
goto LUXOR/Git_Repos

# Expected:
# - Should find LUXOR in search paths (~/Documents/LUXOR)
# - Navigate to ~/Documents/LUXOR/Git_Repos
# - Show: "→ /Users/.../Documents/LUXOR/Git_Repos"

# Verify:
pwd  # Should show ~/Documents/LUXOR/Git_Repos
```

#### Test 1.2: Deep Multi-Level Path
```bash
# Test: Navigate multiple levels deep
goto LUXOR/Git_Repos/unix-goto

# Expected:
# - Should find LUXOR, then navigate to nested path
# - Show: "→ /Users/.../Documents/LUXOR/Git_Repos/unix-goto"

# Verify:
pwd  # Should show ~/Documents/LUXOR/Git_Repos/unix-goto
```

#### Test 1.3: Multi-Level with Search Path Base
```bash
# Test: Use folder from search path as base
goto PROJECTS/HALCON

# Expected:
# - Finds PROJECTS in ~/Documents/LUXOR/PROJECTS
# - Navigate to HALCON subfolder
# - Show: "→ /Users/.../Documents/LUXOR/PROJECTS/HALCON"
```

#### Test 1.4: Invalid Multi-Level Path (Base Exists, Subpath Doesn't)
```bash
# Test: Base folder exists but nested path doesn't
goto LUXOR/NonExistentFolder/test

# Expected:
# - Finds LUXOR in search paths
# - Error: "❌ Path not found: /Users/.../Documents/LUXOR/NonExistentFolder/test"
# - Help message: "Base folder 'LUXOR' found, but 'NonExistentFolder/test' doesn't exist within it"
# - Should NOT navigate, stay in current directory

# Verify:
pwd  # Should not have changed
```

#### Test 1.5: Invalid Multi-Level Path (Base Doesn't Exist)
```bash
# Test: Base folder doesn't exist anywhere
goto NonExistent/subfolder

# Expected:
# - Error: "❌ Base folder not found: NonExistent"
# - Help: "Try 'goto list --folders' to see available folders"
# - Should NOT navigate

# Verify:
pwd  # Should not have changed
```

---

### Feature 2: Recursive Unique Folder Search Tests

#### Test 2.1: Find Unique Nested Folder
```bash
# Test: Find unix-goto folder (nested in LUXOR/Git_Repos)
cd ~
goto unix-goto

# Expected:
# - Message: "🔍 Searching in subdirectories..."
# - Message: "✓ Found: /Users/.../Documents/LUXOR/Git_Repos/unix-goto"
# - Navigate to found folder
# - Show: "→ /Users/.../Documents/LUXOR/Git_Repos/unix-goto"

# Verify:
pwd  # Should show ~/Documents/LUXOR/Git_Repos/unix-goto
```

#### Test 2.2: Find Another Unique Nested Folder
```bash
# Test: Find any other uniquely named folder in your search paths
# Example: If you have LUXOR/PROJECTS/HALCON/config
cd ~
goto config  # Assuming 'config' is unique

# Expected:
# - Message: "🔍 Searching in subdirectories..."
# - If unique: "✓ Found: [path]" and navigate
# - If multiple: Show numbered list

# Verify:
pwd  # Should show the found path if unique
```

#### Test 2.3: Multiple Matches - Disambiguation
```bash
# Test: Search for folder name that appears multiple times
# Example: 'docs' might exist in multiple projects
goto docs

# Expected (if multiple matches):
# - Message: "🔍 Searching in subdirectories..."
# - Message: "⚠️  Multiple folders named 'docs' found:"
# - Numbered list:
#     1) /Users/.../path1/docs
#     2) /Users/.../path2/docs
# - Help: "Please be more specific or use the full path:"
# - Example: "  Example: goto Git_Repos/docs"
# - Should NOT navigate

# Verify:
pwd  # Should not have changed
```

#### Test 2.4: No Matches Found
```bash
# Test: Search for non-existent folder
goto CompletelyNonExistentFolder12345

# Expected:
# - Message: "🔍 Searching in subdirectories..."
# - Error: "❌ Project not found: CompletelyNonExistentFolder12345"
# - Help: "Try 'goto list --folders' to see available folders"
# - Should NOT navigate

# Verify:
pwd  # Should not have changed
```

---

### Integration Tests: New Features with Existing Features

#### Test 3.1: Shortcut Still Works (Regression Test)
```bash
# Test: Existing shortcuts unaffected
goto luxor

# Expected:
# - Direct shortcut match (no search message)
# - Navigate immediately
# - Show: "→ /Users/.../Documents/LUXOR"
```

#### Test 3.2: Bookmark with Multi-Level Path
```bash
# Test: Bookmark a nested folder, then navigate
cd ~/Documents/LUXOR/Git_Repos/unix-goto
bookmark add unixgoto

# Navigate away
cd ~

# Test multi-level navigation to same place
goto LUXOR/Git_Repos/unix-goto

# Verify same as:
goto @unixgoto

# Both should work and go to same place
```

#### Test 3.3: History Tracking Works with New Features
```bash
# Test: Multi-level navigation tracked
goto LUXOR/Git_Repos
goto unix-goto  # Recursive search

# Check history
back --list
recent

# Expected:
# - Both navigations should appear in history
# - back should return to LUXOR/Git_Repos
```

#### Test 3.4: Root Level Match Takes Priority
```bash
# Test: Root level folder found before recursive search
# If you have both:
#   ~/Documents/LUXOR/infra  (root level in search paths)
#   ~/Documents/LUXOR/some-project/infra (nested)

goto infra

# Expected:
# - Should match root level first (faster)
# - NO "🔍 Searching in subdirectories..." message
# - Navigate to ~/ASCIIDocs/infra (the direct shortcut)
```

---

## 🔄 Backward Compatibility Tests

### Test 4.1: All Phase 1 Features Still Work
```bash
# Direct shortcuts
goto luxor      # Should work
goto halcon     # Should work
goto docs       # Should work
goto infra      # Should work

# Special commands
goto ~          # Should work
goto --help     # Should work

# Root level folders
goto GAI-3101   # Should work (if exists in search paths)
```

### Test 4.2: All Phase 2 Features Still Work
```bash
# back command
goto luxor
goto docs
back            # Should return to luxor

# recent command
recent          # Should list recent folders
recent --goto 1 # Should navigate

# bookmarks
bookmark add test
goto @test      # Should work

# goto list
goto list       # Should show all destinations
```

---

## 🎨 User Experience Tests

### Test 5.1: Help Text Updated
```bash
goto --help

# Expected:
# - Should show new sections:
#   "Multi-level navigation:"
#   "Smart search (recursively finds unique folders):"
# - Examples should include:
#   GAI-3101/docs
#   unix-goto
```

### Test 5.2: Error Messages Are Helpful
```bash
# Test various error conditions and verify messages are clear:

# Non-existent path
goto fake/path      # Should show helpful error

# Non-existent folder
goto fakefolder     # Should suggest 'goto list --folders'

# Multiple matches
goto docs           # If multiple, should show numbered list
```

---

## ⚡ Performance Tests

### Test 6.1: Recursive Search Depth Limit
```bash
# The search is limited to maxdepth 3 for performance
# Test that it doesn't take too long:

time goto unix-goto

# Expected:
# - Should complete in < 1 second for reasonable directory structures
# - If slow (>2 seconds), may need optimization
```

### Test 6.2: Root Level Match is Fast
```bash
# Root level matches should be instant (no recursive search)

time goto luxor

# Expected:
# - Should be nearly instant (< 0.1s)
# - No "🔍 Searching..." message
```

---

## 📊 Test Results Template

```markdown
## Test Run: [Date]

**Tester:** [Name]
**Branch:** feature/enhanced-navigation
**Commit:** b07fea1

### Multi-Level Navigation
- [ ] Test 1.1: Basic multi-level path
- [ ] Test 1.2: Deep multi-level path
- [ ] Test 1.3: Multi-level with search path base
- [ ] Test 1.4: Invalid path (base exists, subpath doesn't)
- [ ] Test 1.5: Invalid path (base doesn't exist)

### Recursive Unique Folder Search
- [ ] Test 2.1: Find unique nested folder
- [ ] Test 2.2: Find another unique folder
- [ ] Test 2.3: Multiple matches - disambiguation
- [ ] Test 2.4: No matches found

### Integration Tests
- [ ] Test 3.1: Shortcuts still work
- [ ] Test 3.2: Bookmark with multi-level path
- [ ] Test 3.3: History tracking works
- [ ] Test 3.4: Root level priority

### Backward Compatibility
- [ ] Test 4.1: All Phase 1 features work
- [ ] Test 4.2: All Phase 2 features work

### User Experience
- [ ] Test 5.1: Help text updated
- [ ] Test 5.2: Error messages helpful

### Performance
- [ ] Test 6.1: Recursive search completes quickly
- [ ] Test 6.2: Root level match is instant

### Overall Result
- [ ] ✅ ALL TESTS PASS - Ready to merge
- [ ] ⚠️ SOME FAILURES - Issues to address
- [ ] ❌ MAJOR ISSUES - Needs rework

### Issues Found
[List any issues or unexpected behavior]

### Notes
[Additional observations]
```

---

## 🚀 After Testing

Once all tests pass:
1. Update TESTING-GUIDE.md with new test scenarios
2. Update README.md with examples
3. Update CHANGELOG.md
4. Create pull request
5. Review and merge

---

**Next Steps After Merge:**
- Update documentation
- Announce new features
- Consider adding more advanced features:
  - Configurable search depth
  - Performance metrics
  - Search result caching
