# Local Customization Guide for unix-goto

**Purpose**: Keep your local project-specific shortcuts synchronized with the public unix-goto repository

---

## Overview

This document explains how to maintain local customizations (like LUXOR and CETI shortcuts) without creating merge conflicts with the public GitHub repository that other people use.

**Key Principle**: Local customizations live in SEPARATE files, OUTSIDE the git repository.

---

## The Pattern

```
├── Public Repo (GitHub)                    Local Only (Not in Git)
│   ├── lib/goto-function.sh (public)       ~/.goto-config.sh (yours only)
│   ├── lib/goto-common.sh (public)         OR
│   └── [stays clean]                       /Users/manu/Documents/LUXOR/.goto-config.sh
│
└── When you: git pull origin main
    → NO conflicts, because customizations are separate!
```

---

## Setup: 3 Simple Steps

### Step 1: Create Your Local Config File

```bash
# Create a local customizations file (outside the git repo)
# Option A: In your home directory
cat > ~/.goto-luxor-config.sh << 'EOF'
# LUXOR and CETI shortcuts (not in version control)
# These are sourced AFTER the public goto-function.sh

luxor() {
    echo "$HOME/Documents/LUXOR"
}

# ... rest of your customizations ...
EOF

# OR Option B: In your LUXOR project (recommended)
cp lib/luxor-shortcuts.sh ../LUXOR/.goto-config.sh
```

### Step 2: Update Your Shell Initialization

Edit your `.bashrc`, `.zshrc`, or `.fish/config.fish`:

```bash
# ~/.bashrc or ~/.zshrc

# 1. Load the PUBLIC unix-goto (general purpose for everyone)
source /path/to/unix-goto/lib/goto-function.sh

# 2. Load YOUR LOCAL customizations (LUXOR/CETI specific)
[ -f ~/.goto-luxor-config.sh ] && source ~/.goto-luxor-config.sh
[ -f /Users/manu/Documents/LUXOR/.goto-config.sh ] && source /Users/manu/Documents/LUXOR/.goto-config.sh

# Optional: Verify both are loaded
# goto_info() { echo "Public: loaded" && echo "Local: $([ -n "$(type -t ceti)" ] && echo 'loaded' || echo 'NOT loaded')" }
```

### Step 3: Test It Works

```bash
# Reload shell
exec $SHELL

# Test public shortcuts still work
goto luxor     # Should work
goto brand     # Should work

# Test that local customizations work
goto ceti-coding     # Should work
goto esoterism       # Should work
goto finance         # Should work

# Verify both are loaded
type -a goto | head -5
```

---

## Updating the Public Repository

**The Big Win**: Updates are now conflict-free!

```bash
cd /path/to/unix-goto

# Pull latest from GitHub - NO conflicts!
git pull origin main

# If there were ANY conflicts before (goto-function.sh changes),
# they're gone now because your customizations are in a separate file

# Test that everything still works
goto ceti-coding  # Should work
goto hello        # Should work (if hello is in public version)
```

---

## Your Local File Structure

### Before (Problematic)
```
unix-goto/
├── lib/goto-function.sh (mixed with public code)
├── lib/luxor-shortcuts.sh (YOUR customizations - causes conflicts!)
└── test/
```

### After (Clean)
```
unix-goto/ (git repo - stays public)
├── lib/goto-function.sh (public only)
├── lib/goto-common.sh (public only)
└── .gitignore (includes: lib/luxor-shortcuts.sh, .goto-config.sh)

LUXOR/ (your project - outside git)
├── .goto-config.sh (YOUR customizations - never in git!)
├── CETI/
└── ...
```

---

## Workflow: Making Changes to Local Customizations

### Adding New Shortcuts

1. Edit your local config file:
```bash
# Edit ~/.goto-luxor-config.sh or /Users/manu/Documents/LUXOR/.goto-config.sh

my-new-shortcut() {
    echo "/some/path"
}
```

2. Reload and test:
```bash
source ~/.goto-luxor-config.sh
goto my-new-shortcut
```

3. NO git operations needed - it's not in the repo!

### Syncing With Public Updates

```bash
# When public unix-goto updates
cd /path/to/unix-goto
git pull origin main

# Your local config is UNAFFECTED
# Both continue to work together

goto ceti-coding      # ✓ Still works (from your .goto-config.sh)
goto hello-world      # ✓ Still works (if added to public version)
```

---

## Troubleshooting

### Problem: Local shortcuts not working after update

```bash
# Make sure you reload your shell
exec $SHELL

# Check that local file is still being sourced
grep "goto-config" ~/.bashrc
```

### Problem: .gitignore entries not working

```bash
# Remove the file from git history first
git rm --cached lib/luxor-shortcuts.sh

# Then commit the .gitignore change
git add .gitignore
git commit -m "Add local customization files to gitignore"
```

### Problem: Merge conflicts from old commits

```bash
# If you previously committed luxor-shortcuts.sh, remove it
git log --all --full-history -- lib/luxor-shortcuts.sh

# Use BFG Repo-Cleaner or git-filter-branch to remove from history
# (ask if you need help with this)
```

---

## For Team Members / Public Users

If you're using unix-goto from GitHub, you DON'T need to do any of this:

```bash
# Just clone and use
git clone https://github.com/[user]/unix-goto.git
source unix-goto/lib/goto-function.sh

# That's it! No local configs needed.
```

---

## Advanced: Using Environment Variables

If you prefer configuration over files, you can use environment variables:

```bash
# In your .bashrc or .zshrc
export GOTO_LUXOR_ROOT="/Users/manu/Documents/LUXOR"
export GOTO_CETI_ROOT="/Users/manu/Documents/CETI"

# Then in .goto-config.sh
ceti() {
    echo "$GOTO_CETI_ROOT"
}
```

---

## Summary

| Task | Command | Location |
|------|---------|----------|
| Public shortcuts | source lib/goto-function.sh | GitHub (version controlled) |
| Local shortcuts | source .goto-config.sh | Your machine (NOT versioned) |
| Update public | git pull origin main | No conflicts! |
| Add local shortcut | Edit .goto-config.sh | Edit + reload, no git |
| Share with team | Commit to git | NO - keep in .gitignore |

---

## When to Use This Pattern

✅ **Use this pattern when:**
- You have project-specific shortcuts (LUXOR, CETI)
- Public version should stay clean for all users
- You want conflict-free updates
- Customizations are personal/project-specific

❌ **Don't use this pattern when:**
- Changes should be contributed to public (make a PR instead)
- Changes are general-purpose improvements (share with team)

---

**Created**: October 27, 2025
**Pattern**: Config-File Separation (Zero-Conflict Updates)
**Status**: Production Ready

