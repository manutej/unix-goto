# Usage Examples

## Basic Navigation

### Quick Shortcuts
```bash
# Navigate to predefined locations
goto luxor          # → ~/Documents/LUXOR
goto halcon         # → ~/Documents/LUXOR/PROJECTS/HALCON
goto docs           # → ~/ASCIIDocs
goto infra          # → ~/ASCIIDocs/infra
```

### Direct Folder Access
```bash
# Navigate to any subfolder in search paths
goto GAI-3101       # Goes to ASCIIDocs/GAI-3101
goto WA3590         # Goes to ASCIIDocs/WA3590
goto HALCON         # Goes to LUXOR/PROJECTS/HALCON
```

### Multi-Level Navigation (v0.3.0+)
```bash
# Navigate to nested folders using path separators
goto GAI-3101/docs              # Navigate to docs subfolder
goto LUXOR/Git_Repos/unix-goto  # Full path navigation
goto HALCON/config/settings     # Multiple levels deep

# Works with any depth
goto project/sub/deep/nested
```

### Smart Search (v0.3.0+)
```bash
# Automatically finds uniquely named folders
goto unix-goto      # Finds LUXOR/Git_Repos/unix-goto automatically
goto config         # Searches up to 3 levels deep

# Shows disambiguation menu if multiple matches found
goto docs
# ⚠️  Multiple folders named 'docs' found:
#   1) /Users/.../ASCIIDocs/docs
#   2) /Users/.../LUXOR/project1/docs
# Please be more specific or use the full path
```

## Natural Language Navigation

Powered by Claude AI, you can use plain English to navigate:

```bash
# Descriptive navigation
goto "the halcon project"
goto "infrastructure folder"
goto "the docs folder"

# Project references
goto "that GAI project from march"
goto "work assignment 3590"
goto "the main luxor directory"

# Contextual descriptions
goto "where the infrastructure code is"
goto "the folder with astrology stuff"
```

## Special Commands

### Return Home
```bash
goto ~              # Navigate to $HOME directory
```

### View and Reload Shell Config
```bash
goto zshrc          # Source ~/.zshrc and display with glow/cat
goto bashrc         # Source ~/.bashrc and display with glow/cat
```

### Help Menu
```bash
goto --help         # Show help and usage information
goto -h             # Short form
goto                # No args also shows help
```

## Navigation History (v0.2.0+)

### Back Command
```bash
# Navigate backward through directory history
back                # Go to previous directory
back 3              # Go back 3 directories
back --list         # Show navigation history
back --clear        # Clear navigation history
```

### Recent Folders
```bash
# View and navigate to recently visited locations
recent              # List 10 most recent folders
recent 20           # List 20 most recent folders
recent --goto 3     # Navigate to 3rd recent folder
recent --clear      # Clear recent history
```

## Bookmarks (v0.2.0+)

### Bookmark Management
```bash
# Save and manage favorite locations
bookmark add proj1                    # Bookmark current directory
bookmark add api ~/code/api           # Bookmark specific path
bookmark list                         # Show all bookmarks
bookmark goto proj1                   # Navigate to bookmark
goto @proj1                           # Navigate using @ prefix (shortcut)
bookmark rm proj1                     # Remove bookmark
bm list                               # Short alias for bookmark
```

### Bookmark Examples
```bash
# Save frequently used locations
cd ~/Documents/important/project
bookmark add work

# Later, quickly return
goto @work          # Jump directly to bookmarked location

# Combine with multi-level navigation
goto @work/tests    # Navigate to subfolder of bookmark
```

## Discovery (v0.2.0+)

### List Available Destinations
```bash
# Discover all available navigation options
goto list                # Show all destinations
goto list --shortcuts    # Show only predefined shortcuts
goto list --folders      # Show only folders in search paths
goto list --bookmarks    # Show only bookmarks
```

## Advanced Usage

### Combining with Other Commands
```bash
# Navigate and run commands
goto luxor && ls -la
goto infra && git status

# Use in scripts
TARGET=$(echo "luxor")
goto "$TARGET"
```

### Adding Custom Shortcuts

Edit your shell config (`~/.zshrc` or `~/.bashrc`) and add cases:

```bash
case "$1" in
    # ... existing cases ...
    myproject)
        cd "$HOME/path/to/myproject"
        echo "→ $PWD"
        return
        ;;
esac
```

### Customizing Search Paths

Edit the `search_paths` array in your shell config:

```bash
local search_paths=(
    "$HOME/ASCIIDocs"
    "$HOME/Documents/LUXOR"
    "$HOME/Documents/LUXOR/PROJECTS"
    "$HOME/your/custom/path"           # Add your paths
    "$HOME/another/project/folder"
)
```

## Real-World Examples

### Morning Workflow
```bash
# Set up bookmarks for your daily routine
bookmark add dailywork ~/Documents/work/current-project
bookmark add personal ~/Documents/personal

# Quick morning navigation
goto @dailywork     # Jump to work project
goto @personal/docs # Check personal docs

# Use recent to revisit yesterday's work
recent --goto 1     # Go to most recent location
```

### Quick Context Switching
```bash
# Working on multiple projects
goto halcon          # Switch to HALCON
# ... do some work ...

goto WA3590          # Switch to work assignment
# ... do some work ...

# Navigate back through history
back                 # Return to HALCON
back                 # Return to wherever you were before

goto ~               # Go home
```

### Using Multi-Level Paths
```bash
# Navigate deep into project structure
goto HALCON/src/components/ui     # Multi-level navigation

# Search and navigate
goto unix-goto/lib                # Find base, navigate to subfolder

# Quick access to nested config files
goto @work/config/production      # Bookmark + multi-level
```

### Configuration Management
```bash
# Quick config reload
goto zshrc           # Sources and displays your shell config

# Check what's in your PATH
goto ~ && echo $PATH
```

## Tips & Tricks

1. **Quote multi-word queries**: Always quote natural language queries
   ```bash
   goto "the halcon project"    # ✓ Good
   goto the halcon project       # ✗ Bad (only searches for "the")
   ```

2. **Use exact names when possible**: Faster than NLP
   ```bash
   goto GAI-3101                 # ✓ Fast (direct match)
   goto "that GAI project"       # ✓ Works but slower (uses Claude)
   ```

3. **Tab completion**: Your folder names work as-is
   ```bash
   goto GA<TAB>                  # May autocomplete depending on shell
   ```

4. **Check your search paths**: Run `goto --help` to see configured shortcuts

## Troubleshooting

### "Project not found" error
- Verify folder exists: `ls ~/ASCIIDocs/` or `ls ~/Documents/LUXOR/`
- Check search paths in your shell config
- Try using exact folder name instead of natural language

### Natural language not working
- Ensure Claude CLI is installed: `which claude`
- Check goto-resolve is executable: `ls -l ~/bin/goto-resolve`
- Test resolver directly: `~/bin/goto-resolve "the halcon project"`

### Shell config not updating
- Reload your config: `source ~/.zshrc` or `source ~/.bashrc`
- Check function is loaded: `type goto`

## Performance Notes

- **Direct shortcuts**: Instant (case statement)
- **Folder name matching**: Very fast (simple directory checks)
- **Natural language**: ~1-2 seconds (Claude API call)

For best performance, use exact folder names or shortcuts when possible.
