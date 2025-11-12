# Feature: Configuration-Based Bookmark Sync

**Status:** ✅ Complete and Tested (12/12 tests passing)
**Version:** Added in v0.4.0+
**Branch:** claude/track-issues-resolve-limits-011CUzgcQFBMiMNr4qEe8skS

---

## 🎯 Problem Solved

**Your Request:**
> "Is there a way to make sure there is a config file for favorites with instructions so that core workspace folders and subdirectories can be added to bookmark in a dynamic way respectively to any local environment."

**Solution Implemented:**
A configuration-based bookmark system that:
- ✅ Auto-generates bookmarks from workspace paths
- ✅ Adapts to any local environment
- ✅ Shareable with team via template
- ✅ Survives git updates (user config is gitignored)
- ✅ Crawls subdirectories automatically
- ✅ Uses consistent lowercase naming

---

## 🚀 How It Works

### 1. Configuration Template (Shared)
**File:** `.goto_config.example` (in repo, version controlled)

```bash
# unix-goto Configuration
# Copy this file to ~/.goto_config and customize

# Your workspace directories:
~/Documents/LUXOR/PROJECTS
~/work/clients
~/code/personal
```

### 2. User Configuration (Local)
**File:** `~/.goto_config` (gitignored, user-specific)

Each developer creates their own config with their local paths:
```bash
# Developer A
~/Documents/LUXOR/PROJECTS

# Developer B
~/work/company-projects

# Developer C
/Volumes/ExternalDrive/projects
```

### 3. Auto-Generate Bookmarks
**Command:** `bookmark sync`

Automatically creates lowercase bookmarks for:
- The workspace directory itself
- All immediate subdirectories (one level deep)
- Skips hidden directories (`.git`, `.config`, etc.)

### 4. Use Bookmarks
**Navigation:** `goto @projectname`

Works with:
- Direct navigation: `goto @gai-3101`
- Fuzzy matching: `goto @gai` → `@gai-3101`
- Tab completion: `goto @<TAB>`

---

## 📋 Example Workflow

### Your Setup
```
~/Documents/LUXOR/PROJECTS/
├── GAI-3101/
├── HALCON/
├── WA3590/
└── .git/  (hidden, skipped)
```

### Configuration
```bash
# Copy template
$ cp .goto_config.example ~/.goto_config

# Edit with your path
$ echo "~/Documents/LUXOR/PROJECTS" >> ~/.goto_config

# Sync bookmarks
$ bookmark sync

🔄 Syncing bookmarks from config...

Found 1 workspace path(s):
  • /Users/you/Documents/LUXOR/PROJECTS

Scanning: /Users/you/Documents/LUXOR/PROJECTS
  ✓ Added: projects → /Users/you/Documents/LUXOR/PROJECTS
  ✓ Added: gai-3101 → /Users/you/Documents/LUXOR/PROJECTS/GAI-3101
  ✓ Added: halcon → /Users/you/Documents/LUXOR/PROJECTS/HALCON
  ✓ Added: wa3590 → /Users/you/Documents/LUXOR/PROJECTS/WA3590

=== Sync Summary ===
Added:   4 bookmarks
Updated: 0 bookmarks
Skipped: 0 bookmarks (unchanged)

✓ Sync complete!
```

### Navigation
```bash
$ goto @gai-3101
→ /Users/you/Documents/LUXOR/PROJECTS/GAI-3101

$ goto @projects
→ /Users/you/Documents/LUXOR/PROJECTS

# With fuzzy matching
$ goto @gai
✓ Fuzzy match: @gai → @gai-3101
→ /Users/you/Documents/LUXOR/PROJECTS/GAI-3101
```

---

## 🌍 Team Sharing

### For Repository Maintainers

**1. Commit the template:**
```bash
git add .goto_config.example
git commit -m "Add workspace config template"
git push
```

**2. In your README:**
```markdown
## Setup Bookmarks

1. Copy the config template:
   cp .goto_config.example ~/.goto_config

2. Add your workspace paths:
   vim ~/.goto_config

3. Sync bookmarks:
   bookmark sync

4. Navigate:
   goto @yourproject
```

### For Team Members

**1. Clone the repo:**
```bash
git clone your-repo
cd your-repo
```

**2. Setup their config:**
```bash
cp .goto_config.example ~/.goto_config
vim ~/.goto_config  # Add their local paths
```

**3. Sync:**
```bash
bookmark sync
```

**4. Start working:**
```bash
goto @projectname
```

### What Gets Shared vs. Local

| File | Location | Git | Purpose |
|------|----------|-----|---------|
| `.goto_config.example` | Repo | ✅ Tracked | Template for team |
| `~/.goto_config` | User home | ❌ Gitignored | Local workspace paths |
| `~/.goto_bookmarks` | User home | ❌ Gitignored | Generated bookmarks |
| Tool code | Repo | ✅ Tracked | unix-goto itself |

---

## 🔧 Implementation Details

### Files Created

**1. `.goto_config.example`** (37 lines)
- Template configuration file
- Extensive comments and examples
- Shows workflow and usage
- Committed to repository

**2. `lib/bookmark-command.sh`** (Updated)
- Added `__goto_bookmark_sync()` function (126 lines)
- Reads config file
- Scans workspace directories
- Creates/updates bookmarks
- Tracks sync status

**3. `QUICKSTART-CONFIG.md`** (450 lines)
- Complete user guide
- Example workflows
- Troubleshooting section
- Best practices
- Team collaboration guide

**4. `tests/test-bookmark-sync.sh`** (160 lines)
- 12 comprehensive tests
- All tests passing
- Covers all edge cases

**5. `.gitignore`** (Updated)
- Added `.goto_config` to gitignore
- Keeps user configs local

### New Command

**`bookmark sync`** (alias: `bookmark s`)

**What it does:**
1. Reads `~/.goto_config`
2. Validates workspace paths exist
3. Scans each workspace directory
4. Creates lowercase bookmarks for all subdirectories
5. Updates bookmarks if paths changed
6. Skips unchanged bookmarks
7. Adds `|sync` flag for tracking

**Options:**
- No arguments needed
- Idempotent (safe to run multiple times)
- Shows summary of changes

### Bookmark Format

**File:** `~/.goto_bookmarks`

**Format:**
```
name|/absolute/path|timestamp|sync
```

**Examples:**
```
projects|/Users/you/Documents/LUXOR/PROJECTS|1699876543|sync
gai-3101|/Users/you/Documents/LUXOR/PROJECTS/GAI-3101|1699876543|sync
work|/Users/you/work|1699876500|manual
```

**Flags:**
- `|sync` - Created by `bookmark sync`
- No flag - Created manually via `bookmark add`

### Sync Behavior

**Adds:**
- New subdirectories found in workspace paths
- Workspace directories themselves
- Lowercase-converted names

**Updates:**
- Existing bookmarks if path changed
- Preserves bookmark name
- Updates timestamp

**Skips:**
- Unchanged bookmarks (same name and path)
- Hidden directories (`.git`, `.config`, etc.)
- Non-existent paths (with warning)

**Lowercase Conversion:**
```
GAI-3101    → gai-3101
HALCON      → halcon
MyProject   → myproject
Work_Stuff  → work_stuff
```

---

## ✅ Testing

### Test Coverage (12 Tests)

1. ✅ No config file handling
2. ✅ Empty config handling
3. ✅ Single workspace sync
4. ✅ Lowercase conversion
5. ✅ Hidden directories skipped
6. ✅ Sync tracking flag
7. ✅ Multiple workspace paths
8. ✅ Update existing bookmarks
9. ✅ Skip unchanged bookmarks
10. ✅ Non-existent path warnings
11. ✅ Path expansion (~ and $VAR)
12. ✅ Comment and empty line handling

**Run tests:**
```bash
./tests/test-bookmark-sync.sh
```

**Expected result:** ✅ 12/12 tests passing

---

## 📚 Use Cases

### Use Case 1: Development Team
**Scenario:** Team of 5 developers, different setups

**Shared (in repo):**
```bash
# .goto_config.example
~/work/client-projects
~/work/internal-tools
```

**Developer A (Mac):**
```bash
# ~/.goto_config
~/Documents/work/client-projects
~/Documents/work/internal-tools
```

**Developer B (Linux):**
```bash
# ~/.goto_config
~/code/clients
~/code/tools
```

**Result:** Both run `bookmark sync` and get identical bookmark names, different paths.

### Use Case 2: Multiple Machines
**Scenario:** Same developer, laptop + desktop

**Laptop:**
```bash
# ~/.goto_config
~/Documents/LUXOR/PROJECTS
```

**Desktop:**
```bash
# ~/.goto_config
/Volumes/ExternalDrive/LUXOR/PROJECTS
```

**Result:** Same bookmarks, different physical locations.

### Use Case 3: Client Work
**Scenario:** Consulting firm, multiple client projects

**Configuration:**
```bash
# ~/.goto_config
~/clients/acme-corp
~/clients/techstartup
~/clients/enterprise-inc
```

**Auto-generated bookmarks:**
```
@acme-corp, @acme-frontend, @acme-backend
@techstartup, @startup-app, @startup-api
@enterprise-inc, @erp-system, @mobile-app
```

### Use Case 4: Personal + Professional
**Scenario:** Separate work and personal code

**Configuration:**
```bash
# ~/.goto_config
~/work/company-projects
~/personal/side-projects
~/personal/learning
```

**Result:** Clean separation with clear bookmark prefixes.

---

## 🎨 Advanced Features

### Environment Variables
```bash
# ~/.goto_config
$HOME/workspace
$PROJECTS_DIR/active
${WORK_ROOT}/clients
```

### Conditional Paths
```bash
# ~/.goto_config
~/Documents/LUXOR/PROJECTS   # Always exists
~/work/clients               # May not exist on all machines
/Volumes/Backup/archive      # External drive (optional)
```

Sync shows warnings but continues:
```
Found 2 workspace path(s):
  • /Users/you/Documents/LUXOR/PROJECTS
  • /Users/you/work/clients
⚠️  Skipping non-existent path: /Volumes/Backup/archive
```

### Re-syncing
```bash
# Add new projects to your workspace
mkdir ~/Documents/LUXOR/PROJECTS/NewProject

# Re-sync to pick up new directories
bookmark sync

# Output:
Added:   1 bookmarks  (newproject)
Updated: 0 bookmarks
Skipped: 4 bookmarks (unchanged)
```

---

## 🔄 Integration with Existing Features

### Works with Fuzzy Matching
```bash
# Config creates: @gai-3101
goto @gai        # Fuzzy matches to @gai-3101
goto @hal        # Fuzzy matches to @halcon
goto @proj       # Shows multiple matches if ambiguous
```

### Works with Tab Completion
```bash
goto @<TAB>      # Shows all bookmarks (manual + synced)
goto @gai<TAB>   # Completes to @gai-3101
```

### Works with Manual Bookmarks
```bash
# Manual bookmarks
bookmark add home ~/
bookmark add temp /tmp

# Synced bookmarks
bookmark sync    # From ~/.goto_config

# Both types work together
bookmark list    # Shows all bookmarks
goto @home       # Manual bookmark
goto @gai-3101   # Synced bookmark
```

---

## 📖 Configuration File Reference

### Syntax

```bash
# Comments start with #
# Empty lines are ignored
# One path per line

# Absolute path
/Users/yourname/workspace

# Tilde expansion
~/Documents/projects

# Environment variables
$HOME/code
${WORKSPACE}/active

# NOT supported (don't use):
# - Relative paths (./projects)
# - Wildcards (~/code/*)
# - Multiple paths per line
```

### Example Complete Config

```bash
# unix-goto workspace configuration
# Last updated: 2025-11-12

# =========================
# Active Projects
# =========================

# Main client work
~/Documents/LUXOR/PROJECTS

# Internal tools
~/work/company/tools

# =========================
# Personal Code
# =========================

# Side projects
~/code/personal

# Learning and experiments
~/code/learning

# =========================
# External Storage
# =========================

# Backup drive (might not always be mounted)
# /Volumes/Backup/projects

# =========================
# Archive
# =========================

# Old projects (read-only)
~/archive/old-projects
```

---

## 🎯 Benefits

### For Individual Developers
- ✅ No manual bookmark management
- ✅ Automatic discovery of new projects
- ✅ Consistent naming (all lowercase)
- ✅ Works across multiple machines
- ✅ Easy to maintain (just `bookmark sync`)

### For Teams
- ✅ Shareable setup (template-based)
- ✅ Adapts to each developer's environment
- ✅ No hardcoded paths in documentation
- ✅ Onboarding: 3 commands and done
- ✅ Survives tool updates (config separate)

### For Project
- ✅ Robust and maintainable
- ✅ Follows CONSTITUTION.md principles
- ✅ Simple > complex (text file config)
- ✅ Well-tested (12 tests)
- ✅ Comprehensive documentation

---

## 🚦 Migration Path

### From Manual Bookmarks

**Before:**
```bash
bookmark add gai-3101 ~/Documents/LUXOR/PROJECTS/GAI-3101
bookmark add halcon ~/Documents/LUXOR/PROJECTS/HALCON
bookmark add wa3590 ~/Documents/LUXOR/PROJECTS/WA3590
# ... repeat for every new project
```

**After:**
```bash
# One-time setup
echo "~/Documents/LUXOR/PROJECTS" > ~/.goto_config

# Auto-generates all bookmarks
bookmark sync

# Add new projects? Just sync again
bookmark sync
```

### Mixing Manual and Synced

You can use both:
```bash
# Synced bookmarks (from config)
bookmark sync

# Manual bookmarks (special locations)
bookmark add tmp /tmp
bookmark add downloads ~/Downloads
bookmark add desktop ~/Desktop

# Both types work identically
goto @gai-3101    # Synced
goto @tmp         # Manual
```

---

## 📝 Next Steps

1. **Try it out:**
   ```bash
   cp .goto_config.example ~/.goto_config
   vim ~/.goto_config
   bookmark sync
   goto @yourproject
   ```

2. **Add to your workflow:**
   ```bash
   # After creating new projects
   bookmark sync

   # After restructuring workspace
   bookmark sync

   # After pulling teammate's changes
   # (your local config adapts automatically)
   ```

3. **Share with team:**
   - Commit `.goto_config.example`
   - Update README with setup instructions
   - Help teammates configure their environments

4. **Automate (optional):**
   ```bash
   # Add to your shell config to sync on startup
   # ~/.bashrc or ~/.zshrc
   bookmark sync --quiet  # (--quiet flag to be added)
   ```

---

## 🎊 Summary

**What Was Built:**
- ✅ Configuration system (`.goto_config.example` + `~/.goto_config`)
- ✅ Auto-bookmark generation (`bookmark sync`)
- ✅ Smart sync behavior (add, update, skip)
- ✅ Lowercase naming convention
- ✅ 12 comprehensive tests (all passing)
- ✅ Complete documentation (QUICKSTART-CONFIG.md)
- ✅ Integration with fuzzy matching and tab completion

**Files Changed:**
- `.goto_config.example` - Configuration template
- `.gitignore` - Added `.goto_config`
- `lib/bookmark-command.sh` - Added sync functionality
- `tests/test-bookmark-sync.sh` - Test suite
- `QUICKSTART-CONFIG.md` - User guide

**Commands Added:**
- `bookmark sync` - Generate bookmarks from config

**Benefits:**
- Adapts to any local environment
- Shareable with team
- Survives git updates
- No manual bookmark management
- Works with existing features

---

**Status:** ✅ Production Ready
**Testing:** ✅ 12/12 Tests Passing
**Documentation:** ✅ Complete
**Pushed to:** claude/track-issues-resolve-limits-011CUzgcQFBMiMNr4qEe8skS

**Ready to use!** 🚀
