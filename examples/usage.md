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
# Check personal projects
goto docs

# Jump to work project
goto "that GAI project"

# Check infrastructure
goto infra
```

### Quick Context Switching
```bash
# Working on multiple projects
goto halcon          # Switch to HALCON
# ... do some work ...

goto WA3590          # Switch to work assignment
# ... do some work ...

goto ~               # Go home
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
