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

- **Navigation History**: Automatic tracking and navigation history
  - `back` → Go to previous directory
  - `back 3` → Go back 3 directories
  - `back --list` → Show navigation history

- **Recent Folders**: View and navigate to recently visited locations
  - `recent` → List 10 most recent folders
  - `recent --goto 3` → Navigate to 3rd recent folder

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

- [ ] Add `back` command for navigation history
- [ ] Add `recent` to show recently visited folders
- [ ] Add `bookmark` system for favorite locations
- [ ] Add fuzzy matching for folder names
- [ ] Support for custom configuration file
- [ ] Add `list` command to show all available folders

## Contributing

Contributions welcome! This is a personal productivity tool that's evolving based on real-world usage.

## License

MIT License - Feel free to use and modify for your own needs.

## Author

**Manu Tej** - Built with Claude AI for better terminal navigation

---

*Generated with Claude Code* 🤖
