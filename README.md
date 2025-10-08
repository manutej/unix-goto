# unix-goto 🚀

Smart Unix navigation tools powered by Claude AI. Navigate your filesystem using natural language or shortcuts.

## Features

- **Natural Language Navigation**: Use plain English to navigate
  - `goto the infrastructure folder` → ASCIIDocs/infra
  - `goto that GAI project from March` → GAI-3101
  - `goto halcon project` → LUXOR/PROJECTS/HALCON

- **Quick Shortcuts**: Predefined aliases for common locations
  - `goto luxor` → Documents/LUXOR
  - `goto docs` → ASCIIDocs
  - `goto infra` → ASCIIDocs/infra

- **Direct Folder Access**: Navigate to any subfolder by name
  - `goto GAI-3101`
  - `goto WA3590`

- **Multi-Level Navigation**: Navigate to nested folders using paths
  - `goto GAI-3101/docs` → Navigate to nested subfolder
  - `goto LUXOR/Git_Repos/unix-goto` → Full path navigation
  - Works with any depth: `goto project/sub/deep`

- **Smart Search**: Automatically finds uniquely named folders
  - `goto unix-goto` → Finds `LUXOR/Git_Repos/unix-goto` automatically
  - Searches recursively (up to 3 levels deep)
  - Shows disambiguation menu if multiple matches found

- **Navigation History**: Automatic tracking and navigation history
  - `back` → Go to previous directory
  - `back 3` → Go back 3 directories
  - `back --list` → Show navigation history

- **Recent Folders**: View and navigate to recently visited locations
  - `recent` → List 10 most recent folders
  - `recent --goto 3` → Navigate to 3rd recent folder

- **Bookmarks**: Save and manage favorite locations
  - `bookmark add proj1` → Bookmark current directory
  - `goto @proj1` → Navigate to bookmark using @ syntax
  - `bookmark list` → Show all bookmarks
  - `bm` → Short alias for bookmark command

- **Discovery**: List and explore available destinations
  - `goto list` → Show all available destinations
  - `goto list --shortcuts` → Show only shortcuts
  - `goto list --bookmarks` → Show only bookmarks

- **Special Commands**:
  - `goto ~` → Return to home directory
  - `goto zshrc` → Source and display .zshrc with syntax highlighting
  - `goto --help` → Show help menu

## Requirements

- **Claude CLI** - The official Claude CLI tool ([Download](https://github.com/anthropics/claude-code))
- **zsh** or **bash** shell
- **glow** (optional) - For pretty .zshrc display: `brew install glow`

## Installation

```bash
# Clone the repository
git clone https://github.com/manutej/unix-goto.git
cd unix-goto

# Run the installation script
./install.sh

# Reload your shell configuration
source ~/.zshrc  # or source ~/.bashrc
```

## Usage

### Basic Navigation
```bash
goto luxor          # Go to Documents/LUXOR
goto infra          # Go to ASCIIDocs/infra
goto GAI-3101       # Go to any project folder
```

### Multi-Level Navigation
```bash
goto GAI-3101/docs              # Navigate to nested folder
goto LUXOR/Git_Repos/unix-goto  # Full path navigation
goto PROJECTS/HALCON/config     # Multiple levels deep
```

### Smart Search (Finds Unique Folders)
```bash
goto unix-goto      # Finds LUXOR/Git_Repos/unix-goto automatically
# 🔍 Searching in subdirectories...
# ✓ Found: /Users/.../Documents/LUXOR/Git_Repos/unix-goto

# If multiple matches exist:
goto docs
# ⚠️  Multiple folders named 'docs' found:
#   1) /Users/.../ASCIIDocs/docs
#   2) /Users/.../LUXOR/project1/docs
# Please be more specific or use the full path
```

### Natural Language (Powered by Claude AI)
```bash
goto "the halcon project"
goto "infrastructure folder"
goto "that GAI project from march"
```

### Special Commands
```bash
goto ~              # Return home
goto zshrc          # Source and view .zshrc
goto --help         # Show help
```

### Navigation History
```bash
back                # Go to previous directory
back 3              # Go back 3 directories
back --list         # Show navigation history
back --clear        # Clear navigation history

recent              # Show 10 recent folders
recent 20           # Show 20 recent folders
recent --goto 3     # Navigate to 3rd recent folder
recent --clear      # Clear recent history
```

### Bookmarks
```bash
bookmark add work               # Bookmark current directory as 'work'
bookmark add api ~/code/api     # Bookmark specific path
bookmark list                   # Show all bookmarks
bookmark goto work              # Navigate to bookmark
goto @work                      # Navigate using @ syntax (shortcut)
bookmark rm work                # Remove bookmark
bm list                         # Short alias for bookmark
```

### Discovery
```bash
goto list                # Show all available destinations
goto list --shortcuts    # Show only predefined shortcuts
goto list --folders      # Show only folders in search paths
goto list --bookmarks    # Show only bookmarks
```

## Configuration

The `goto` function searches in these locations by default:
- `$HOME/ASCIIDocs`
- `$HOME/Documents/LUXOR`
- `$HOME/Documents/LUXOR/PROJECTS`

To customize search paths, edit `lib/goto-function.sh` and update the `search_paths` array:

```bash
local search_paths=(
    "$HOME/your/custom/path"
    "$HOME/another/path"
)
```

## How It Works

1. **Direct Match**: First tries exact folder name matching
2. **Shortcuts**: Checks predefined shortcuts (luxor, docs, etc.)
3. **Natural Language**: If input contains spaces, uses Claude AI to interpret and resolve
4. **Smart Fallback**: Provides helpful error messages if nothing matches

## Architecture

```
unix-goto/
├── bin/
│   └── goto-resolve      # Claude AI resolver script
├── lib/
│   └── goto-function.sh  # Main goto shell function
├── examples/
│   └── usage.md          # Usage examples
├── install.sh            # Installation script
└── README.md
```

## Roadmap

- [x] Navigation history with `back` command
- [x] Recent folders with `recent` command
- [x] Bookmark system with `bookmark` command
- [x] Discovery with `goto list` command
- [ ] Fuzzy matching for folder names
- [ ] Custom configuration file (~/.gotorc)
- [ ] Workspace management for multi-folder projects
- [ ] Natural language directory search with `finddir`

See [ROADMAP.md](ROADMAP.md) for detailed future plans.

## Contributing

Contributions welcome! This is a personal productivity tool that's evolving based on real-world usage.

## License

MIT License - Feel free to use and modify for your own needs.

## Author

**Manu Tej** - Built with Claude AI for better terminal navigation

---

*Generated with Claude Code* 🤖
