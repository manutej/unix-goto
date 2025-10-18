# unix-goto Quick Start Guide

Get started with unix-goto in 5 minutes!

## Installation

```bash
# Clone and install
git clone https://github.com/manutej/unix-goto.git
cd unix-goto
./install.sh

# Reload your shell
source ~/.zshrc
```

## Essential Commands

### Navigate Anywhere
```bash
goto luxor              # Predefined shortcut
goto GAI-3101           # Any folder in search paths
goto "halcon project"   # Natural language (with Claude AI)
goto @mywork            # Saved bookmark
```

### Save Favorites
```bash
bookmark add work           # Bookmark current directory
goto @work                  # Navigate using @name
bookmark list               # See all bookmarks
```

### Navigate Back
```bash
back                    # Previous directory
back 3                  # Go back 3 steps
```

### Explore
```bash
goto list               # See everything available
recent                  # Recently visited folders
```

## Common Workflows

### Quick Navigation
```bash
goto luxor              # Go to project
# ... do work ...
back                    # Return to previous location
```

### Save and Reuse Locations
```bash
cd ~/complex/deep/path/to/project
bookmark add myproj
# Later...
goto @myproj            # Instant navigation
```

### Find Recent Work
```bash
recent                  # Show recent folders
recent --goto 2         # Jump to 2nd recent folder
```

## Tips

1. **Quote multi-word queries**: `goto "the infrastructure folder"`
2. **Use shortcuts for speed**: Direct shortcuts are instant
3. **Bookmark frequently used paths**: Save time with @bookmarks
4. **Explore with list**: `goto list` shows everything available

## Get Help

```bash
goto --help             # Main help
back --help             # Back command help
recent --help           # Recent command help
bookmark --help         # Bookmark help
goto list --help        # List command help
```

## Next Steps

- Read [TESTING.md](TESTING.md) for comprehensive testing guide
- See [examples/usage.md](examples/usage.md) for more examples
- Check [ROADMAP.md](ROADMAP.md) for upcoming features

Happy navigating! 🚀
