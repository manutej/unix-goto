# Quick Start: Configuration-Based Bookmarks

**Make unix-goto adapt to any environment automatically!**

This guide shows you how to set up configuration-based bookmarks so your team can share the tool while adapting it to their local workspace structure.

---

## 🎯 What This Solves

**Problem:** Different developers have different directory structures:
- Developer A: `~/work/projects/client-alpha`
- Developer B: `~/code/clients/client-alpha`
- Developer C: `~/work/projects/client-alpha`

**Solution:** Each developer configures their workspace paths once, then `bookmark sync` automatically creates all the bookmarks they need.

---

## 🚀 Quick Start (3 steps)

### Step 1: Copy the Example Config

```bash
cp .goto_config.example ~/.goto_config
```

### Step 2: Add Your Workspace Paths

Edit `~/.goto_config` and add your main workspace directories:

```bash
vim ~/.goto_config
```

Example configuration:
```bash
# My workspaces
~/work/projects
~/work/clients
~/code/personal
```

### Step 3: Sync Bookmarks

```bash
bookmark sync
```

That's it! All subdirectories are now bookmarked automatically.

---

## 📋 Example Workflow

### Your Directory Structure
```
~/work/projects/
├── client-alpha/
│   ├── docs/
│   └── src/
├── project-beta/
│   └── config/
└── internal-tool/
```

### Your Configuration
```bash
# ~/.goto_config
~/work/projects
```

### Run Sync
```bash
$ bookmark sync

🔄 Syncing bookmarks from config...

Found 1 workspace path(s):
  • /Users/you/work/projects

Scanning: /Users/you/work/projects
  ✓ Added: projects → /Users/you/work/projects
  ✓ Added: client-alpha → /Users/you/work/projects/client-alpha
  ✓ Added: project-beta → /Users/you/work/projects/project-beta
  ✓ Added: internal-tool → /Users/you/work/projects/internal-tool

=== Sync Summary ===
Added:   4 bookmarks
Updated: 0 bookmarks
Skipped: 0 bookmarks (unchanged)

✓ Sync complete! Use 'bookmark list' to see all bookmarks
  Or try: goto @projects
```

### Use Your Bookmarks
```bash
goto @client-alpha           # Navigate to client-alpha
goto @project-beta             # Navigate to project-beta
goto @internal-tool             # Navigate to internal-tool
goto @projects           # Navigate to projects root

# With fuzzy matching:
goto @gai                # Matches @client-alpha
goto @hal                # Matches @project-beta
```

---

## 🔄 How It Works

### Bookmark Naming
- **Automatic lowercase conversion:** `client-alpha` → `@client-alpha`
- **Consistent naming:** All bookmarks are lowercase for easy typing
- **No duplicates:** Existing bookmarks won't be overwritten

### Sync Behavior
- **Adds new bookmarks:** Scans subdirectories and creates bookmarks
- **Updates changed paths:** If a directory moves, bookmark is updated
- **Skips unchanged:** Won't recreate existing bookmarks
- **One level deep:** Scans workspace + immediate subdirectories
- **Skips hidden dirs:** `.git`, `.config`, etc. are ignored

### Tracking
- Synced bookmarks have a `|sync` flag in `~/.goto_bookmarks`
- Manual bookmarks don't have this flag
- Both types work identically

---

## 🌍 Sharing with Your Team

### In Your Repository

**1. Commit the example config:**
```bash
git add .goto_config.example
git commit -m "Add workspace configuration example"
```

**2. In your README or onboarding docs:**
```markdown
## Setup unix-goto

1. Install unix-goto (see installation guide)
2. Copy the config template:
   cp .goto_config.example ~/.goto_config
3. Edit ~/.goto_config and add your workspace paths
4. Run: bookmark sync
5. Start navigating: goto @projectname
```

### What Gets Shared vs. Local

**Shared (in git):**
- `.goto_config.example` - Template for new team members
- Documentation and guides
- The unix-goto tool itself

**Local (gitignored):**
- `~/.goto_config` - Your personal workspace paths
- `~/.goto_bookmarks` - Your generated bookmarks
- `~/.goto_fuzzy_cache` - Performance cache

---

## 📚 Advanced Usage

### Multiple Workspace Paths

You can configure multiple workspace directories:

```bash
# ~/.goto_config
~/work/projects
~/work/clients
~/code/personal
~/Development/experiments
```

All subdirectories from all paths will be bookmarked.

### Environment Variables

Use environment variables for dynamic paths:

```bash
# ~/.goto_config
$HOME/workspace
$WORKSPACE_ROOT/projects
${PROJECT_DIR}/active
```

### Conditional Paths

Add paths that might not exist on all machines:

```bash
# ~/.goto_config
~/work/projects
~/work/clients              # Might not exist on all machines
/Volumes/ExternalDrive/code # Only on some setups
```

Sync will skip non-existent paths with a warning.

### Re-syncing

Run `bookmark sync` anytime to:
- Add new subdirectories
- Update moved directories
- Refresh your bookmarks

```bash
# After adding new projects
bookmark sync

# After directory structure changes
bookmark sync

# After updating your config
vim ~/.goto_config
bookmark sync
```

---

## 🎨 Use Cases

### Use Case 1: Client Projects
```bash
# ~/.goto_config
~/work/clients

# Creates:
# @clients, @acme-corp, @techstartup, @enterprise-inc
```

### Use Case 2: Personal + Work
```bash
# ~/.goto_config
~/work/projects
~/personal/code

# Creates:
# @projects, @work-project-1, @work-project-2
# @code, @side-project, @learning
```

### Use Case 3: Deep Workspace
```bash
# ~/.goto_config
~/work
~/work/projects
~/work/ARCHIVES

# Creates hierarchical bookmarks:
# @luxor (root)
# @projects, @archives (first level)
# @client-alpha, @project-beta (project subdirs)
```

### Use Case 4: Multiple Machines
```bash
# ~/.goto_config on Laptop
~/work/projects
~/code/personal

# ~/.goto_config on Desktop
/Volumes/Work/work/projects
~/Desktop/code

# Same tool, different paths, bookmark sync adapts!
```

---

## 🔧 Troubleshooting

### "No configuration found"
```bash
# Copy the example config
cp .goto_config.example ~/.goto_config
vim ~/.goto_config  # Add your paths
bookmark sync
```

### "No valid workspace paths found"
- Check that paths exist
- Use absolute paths or `~` for home
- Verify no typos in directory names

### "Skipping non-existent path"
- Path doesn't exist on your system
- Comment out or remove from config
- Or create the directory first

### Bookmark name conflicts
- Sync uses lowercase names
- If `client-alpha` and `gai-other` both exist, second one wins
- Rename directories to avoid conflicts

### Want to start fresh
```bash
# Remove all synced bookmarks
grep -v "|sync$" ~/.goto_bookmarks > ~/.goto_bookmarks.tmp
mv ~/.goto_bookmarks.tmp ~/.goto_bookmarks

# Re-sync
bookmark sync
```

---

## 📖 Configuration File Format

### Simple Format
```bash
# Comments start with #
# Empty lines are ignored
# One path per line

~/work/projects
~/work/clients
```

### Supported Features
- `~` expands to home directory
- Environment variables: `$HOME`, `${WORKSPACE}`, etc.
- Absolute paths: `/Users/name/workspace`
- Relative paths: NOT supported (use absolute or ~)

### Example Configuration
```bash
# unix-goto workspace configuration
# Generated: 2025-11-12

# Main projects
~/work/projects
~/work/ARCHIVES

# Client work
~/work/active-clients
~/work/archived-clients

# Personal
~/code/personal
~/code/experiments

# External drives (optional)
# /Volumes/Backup/projects
```

---

## ✅ Best Practices

### 1. Start Simple
Begin with 1-2 workspace paths, then expand as needed.

### 2. Use Descriptive Workspace Names
- Good: `~/work/client-projects`
- Avoid: `~/stuff`, `~/misc`

### 3. Group Related Projects
Put related projects under a common parent:
```bash
~/work/clients/acme
~/work/clients/techco
```
Then configure: `~/work/clients`

### 4. Sync Regularly
Run `bookmark sync` after:
- Adding new projects
- Renaming directories
- Restructuring your workspace

### 5. Document Your Setup
Add a comment in your config explaining your structure:
```bash
# ~/work/clients - Active client projects
~/work/clients

# ~/personal - Side projects and experiments
~/personal
```

### 6. Keep Example Config Updated
When you find a good workspace structure, update `.goto_config.example` for your team.

---

## 🚀 Next Steps

1. **Set up your config:**
   ```bash
   cp .goto_config.example ~/.goto_config
   vim ~/.goto_config
   ```

2. **Sync your bookmarks:**
   ```bash
   bookmark sync
   ```

3. **Test navigation:**
   ```bash
   bookmark list          # See all bookmarks
   goto @yourproject      # Navigate
   ```

4. **Share with team:**
   - Commit `.goto_config.example`
   - Add setup instructions to README
   - Help teammates configure their local environments

---

## 📝 Summary

**What you get:**
- ✅ Automatic bookmark generation from workspace paths
- ✅ Adapts to any local environment
- ✅ Shareable with team (template-based)
- ✅ Survives git updates (user config is gitignored)
- ✅ Easy to maintain (just `bookmark sync`)
- ✅ Works with fuzzy matching (`goto @gai` → `@client-alpha`)

**Configuration file:**
- Template: `.goto_config.example` (in repo, shared)
- User config: `~/.goto_config` (gitignored, local)
- Format: Simple text file, one path per line

**Commands:**
- `bookmark sync` - Generate bookmarks from config
- `bookmark list` - See all bookmarks
- `goto @name` - Navigate to bookmarked directory

---

**Ready to make unix-goto work for your entire team? Start with `bookmark sync`!** 🚀
