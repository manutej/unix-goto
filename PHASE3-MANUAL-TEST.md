# Phase 3 Manual Testing Guide

**Quick test guide for finddir and enhanced goto list features**

---

## 🚀 Setup

First, install the new commands:

```bash
# From the unix-goto directory
./install.sh

# OR manually copy to ~/bin
cp bin/finddir ~/bin/
cp bin/finddir-resolver ~/bin/
chmod +x ~/bin/finddir
chmod +x ~/bin/finddir-resolver

# Reload shell to get updated goto list function
source ~/.zshrc  # or source ~/.bashrc
```

---

## ✅ Test 1: finddir Help

**Command:**
```bash
finddir --help
```

**Expected Output:**
- Should show help menu
- Examples of usage
- Search criteria explanations

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 2: Simple Name Search

**Command:**
```bash
finddir "unix-goto"
```

**Expected Output:**
```
🔍 Searching for: "unix-goto"
🤖 Parsing search criteria...
✓ Search criteria parsed

📁 Searching directories...
✓ Found 1 matching directory

  1) unix-goto
     → /Users/.../Documents/LUXOR/Git_Repos/unix-goto
     📅 Modified: [date]  💾 Size: [size]
     🔧 Git repository
```

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 3: Git Repositories Search

**Command:**
```bash
finddir "folders with git"
```

**Expected Output:**
- Should find directories containing .git folders
- Should show "🔧 Git repository" indicator
- Multiple results if you have multiple git repos

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 4: Time-Based Search

**Command:**
```bash
finddir "folders modified this week"
```

**Expected Output:**
- Should find folders modified in last 7 days
- Should show modification dates
- Might find 0 results if you haven't modified many folders recently (that's OK)

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 5: Project Type Search - Python

**Command:**
```bash
finddir "python projects"
```

**Expected Output:**
- Should look for folders with .py files, requirements.txt, or setup.py
- Should show "🐍 Python project" indicator
- May find 0 results if you don't have Python projects (that's OK)

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 6: Project Type Search - Node

**Command:**
```bash
finddir "node projects"
```

**Expected Output:**
- Should look for folders with package.json
- Should show "📦 Node.js project" indicator
- May find 0 results if you don't have Node projects (that's OK)

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 7: Time + Content Combined

**Command:**
```bash
finddir "git repositories from last month"
```

**Expected Output:**
- Should find git repos modified in last 30 days
- Should combine both criteria
- Shows both modification date and git indicator

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 8: Invalid Query Handling

**Command:**
```bash
finddir "asdfghjkl nonsense query"
```

**Expected Output:**
```
🔍 Searching for: "asdfghjkl nonsense query"
🤖 Parsing search criteria...

⚠️  Could not understand search criteria
Try: finddir "python projects from last month"
```

**OR** it might still parse it - that's OK, Claude AI is flexible

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 9: No Results

**Command:**
```bash
finddir "folders created in 1990"
```

**Expected Output:**
```
❌ No directories found matching criteria

Try:
  - Broader search: finddir "projects from last year"
  - Different criteria: finddir "folders with git"
```

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 10: goto list --recent

**Command:**
```bash
# First, navigate to a few places to build history
goto luxor
goto docs
cd ~

# Now test
goto list --recent
```

**Expected Output:**
```
📂 Recently Visited Folders:

  1)  docs
      → /Users/.../ASCIIDocs
      📅 Last visited: [recent timestamp]

  2)  luxor
      → /Users/.../Documents/LUXOR
      📅 Last visited: [recent timestamp]

Total: 2 recent folders

💡 Use 'recent --goto N' to navigate to any of these
```

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 11: goto list --recent with limit

**Command:**
```bash
goto list --recent 3
```

**Expected Output:**
- Should show maximum of 3 recent folders
- Should be formatted nicely

**Result:** ✅ PASS / ❌ FAIL

---

## ✅ Test 12: goto list help updated

**Command:**
```bash
goto list --help
```

**Expected Output:**
- Should include `--recent` in the help text
- Should show: "goto list --recent     Show recently visited folders"

**Result:** ✅ PASS / ❌ FAIL

---

## 🐛 Common Issues & Troubleshooting

### Issue 1: "finddir: command not found"
**Fix:**
```bash
# Make sure ~/bin is in your PATH
echo $PATH | grep "$HOME/bin"

# If not found, add to ~/.zshrc or ~/.bashrc:
export PATH="$HOME/bin:$PATH"

# Then reload:
source ~/.zshrc
```

### Issue 2: "finddir-resolver not found"
**Fix:**
```bash
# Make sure it's executable and in ~/bin
ls -la ~/bin/finddir*
chmod +x ~/bin/finddir-resolver

# Try with full path
~/bin/finddir "test query"
```

### Issue 3: Claude AI errors
**Fix:**
```bash
# Make sure Claude CLI is installed and working
claude --version

# Test the resolver directly
~/bin/finddir-resolver "python projects"
```

### Issue 4: goto list --recent shows nothing
**This is expected if:**
- You haven't navigated anywhere with `goto` yet
- Your history file is empty
- Solution: Use `goto luxor` or `goto docs` a few times first

### Issue 5: finddir returns no results
**This is OK if:**
- You genuinely don't have matching folders
- Try a broader query: `finddir "folders from last year"`
- Try a simpler query: `finddir "LUXOR"`

---

## 📋 Quick Test Checklist

Run through these quickly:

```bash
# 1. Help works
finddir --help

# 2. Simple search
finddir "unix-goto"

# 3. Git search
finddir "git"

# 4. Recent list
goto list --recent

# 5. Recent list help
goto list --help
```

All should work without errors!

---

## 🎯 Expected Results Summary

**Minimum passing criteria:**
- [ ] finddir --help shows help
- [ ] finddir can find at least one folder (unix-goto)
- [ ] goto list --recent works (may be empty if no history)
- [ ] goto list --help includes --recent
- [ ] No command crashes or shows shell errors

**What's OK to fail:**
- Specific project type searches (if you don't have those projects)
- Time-based searches (if no matching folders)
- Zero results (just means no matches, not a bug)

**What's NOT OK:**
- Command not found errors
- Shell syntax errors
- Crashes or hanging
- Missing help text

---

## 📝 Report Template

```markdown
## Test Results - Phase 3

**Date:** [date]
**Tester:** [name]

### Quick Tests
- [ ] finddir --help: PASS/FAIL
- [ ] finddir "unix-goto": PASS/FAIL
- [ ] finddir "git": PASS/FAIL
- [ ] goto list --recent: PASS/FAIL
- [ ] goto list --help: PASS/FAIL

### Issues Found
[List any problems]

### Overall Result
✅ READY TO MERGE / ⚠️ NEEDS FIXES
```

---

**After testing, let me know the results and we can proceed with merging!**
