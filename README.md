# unix-goto 🚀

**Smart Unix navigation powered by Claude AI**

Navigate your filesystem using natural language, fuzzy matching, and intelligent shortcuts. Make terminal navigation effortless with automatic bookmarks, tab completion, and powerful search.

[![Version](https://img.shields.io/badge/version-0.4.0-blue.svg)](https://github.com/manutej/unix-goto/releases/tag/v0.4.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## ✨ Features

### 🎯 Fuzzy Matching (v0.4.0+)
Never type exact directory names again! Use partial matches:
```bash
goto proj        # Matches "project-alpha"
goto cli         # Matches "client-work"
goto api/src     # Multi-level: matches "api-gateway/src"
goto @wo         # Bookmark fuzzy: matches "@work"
```
**Performance:** <50ms average, 34x faster than initial implementation

### ⚡ Tab Completion (v0.4.0+)
Explore your navigation options interactively:
```bash
goto <TAB>       # Shows shortcuts, bookmarks, directories
goto p<TAB>      # Shows all starting with 'p'
goto @<TAB>      # Shows all bookmarks
bookmark <TAB>   # Shows: add, rm, list, sync, goto
```
**Performance:** 22ms average response time

### 📋 Config-Based Bookmarks (v0.4.0+)
Auto-generate bookmarks from your workspace:
```bash
# 1. Configure your workspace paths
cp .goto_config.example ~/.goto_config
vim ~/.goto_config  # Add: ~/work/projects

# 2. Sync once
bookmark sync

# 3. All subdirectories are now bookmarked!
goto @project-a
goto @client-work
goto @internal-tool
```
**Adapts to any environment, survives git updates**

### 🧠 Natural Language Navigation
Use Claude AI for intelligent navigation:
```bash
goto "the infrastructure folder"
goto "that client project from last month"
goto "api documentation directory"
```

### 🔖 Smart Bookmarks
Manual or auto-generated bookmarks:
```bash
bookmark add work                # Manual bookmark
bookmark sync                    # Auto-generate from config
goto @work                       # Navigate with @ prefix
goto @cli                        # Fuzzy matches "@client-work"
```

### 📂 Direct & Multi-Level Navigation
Navigate anywhere instantly:
```bash
goto project-alpha               # Direct folder access
goto project-alpha/docs          # Multi-level navigation
goto api/src/handlers            # Any depth
```

### 🔍 Smart Search
Automatically finds uniquely named folders:
```bash
goto myproject      # Finds anywhere in search paths
                    # Shows menu if multiple matches
```

### ⏮️ Navigation History
Track and navigate your history:
```bash
back                # Previous directory
back 3              # Go back 3 directories
back --list         # Show history
recent              # Recently visited folders
recent --goto 3     # Jump to 3rd recent
```

### 🎨 Discovery
Explore available destinations:
```bash
goto list                # All destinations
goto list --shortcuts    # Predefined shortcuts
goto list --bookmarks    # All bookmarks
goto list --folders      # Available folders
```

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/manutej/unix-goto.git
cd unix-goto

# Run the installation script
./install.sh

# Reload your shell
source ~/.bashrc  # or ~/.zshrc
```

### First Steps

```bash
# 1. Configure your workspace (optional but recommended)
cp .goto_config.example ~/.goto_config
vim ~/.goto_config  # Add your workspace paths

# 2. Auto-generate bookmarks
bookmark sync

# 3. Start navigating!
goto <TAB>              # Explore with tab completion
goto @yourproject       # Navigate to bookmarked project
goto proj               # Fuzzy match "project-alpha"
```

---

## 📖 Usage Examples

### Fuzzy Matching

```bash
# Partial name matching (case-insensitive)
goto api              # Matches "api-gateway"
goto cli              # Matches "client-work"
goto proj             # Shows multiple matches if ambiguous

# Multi-level fuzzy
goto api/src          # Matches "api-gateway/src"
goto proj/docs        # Matches "project-alpha/docs"

# Bookmark fuzzy
goto @wo              # Matches "@work"
goto @proj            # Matches "@project-alpha"
```

### Configuration-Based Bookmarks

```bash
# Setup (one-time)
cp .goto_config.example ~/.goto_config
echo "~/work/projects" >> ~/.goto_config
echo "~/code/personal" >> ~/.goto_config

# Generate bookmarks
bookmark sync
# Output:
# Found 2 workspace path(s):
#   • /Users/you/work/projects
#   • /Users/you/code/personal
#
# Scanning: /Users/you/work/projects
#   ✓ Added: projects → /Users/you/work/projects
#   ✓ Added: client-a → /Users/you/work/projects/client-a
#   ✓ Added: client-b → /Users/you/work/projects/client-b
#
# === Sync Summary ===
# Added:   5 bookmarks

# Use bookmarks
goto @client-a
goto @client-b
goto @projects
```

### Manual Bookmarks

```bash
# Add bookmarks
bookmark add work                # Current directory
bookmark add api ~/code/api      # Specific path

# Use bookmarks
goto @work
goto @api

# Manage bookmarks
bookmark list                    # Show all
bookmark rm work                 # Remove
bm list                         # Short alias
```

### Tab Completion

```bash
# Explore options
goto <TAB>                # All available options
goto p<TAB>               # Filter by prefix
goto @<TAB>               # All bookmarks

# Context-aware
bookmark <TAB>            # Shows: add rm list sync goto
bookmark rm <TAB>         # Shows your bookmark names
back <TAB>                # Shows: --list --clear 1 2 3
```

### Navigation History

```bash
# Go back
back                      # Previous directory
back 2                    # Back 2 steps
back --list               # Show history

# Recent folders
recent                    # Last 10 folders
recent 20                 # Last 20 folders
recent --goto 5           # Jump to 5th recent
recent --clear            # Clear history
```

### Natural Language (AI-Powered)

```bash
goto "the api project"
goto "client documentation"
goto "infrastructure folder"
```

### Discovery

```bash
goto list                 # Everything
goto list --shortcuts     # Shortcuts only
goto list --bookmarks     # Bookmarks only
goto list --folders       # Available folders
```

---

## ⚙️ Configuration

### Search Paths

Edit `lib/goto-function.sh` to customize where `goto` searches:

```bash
local search_paths=(
    "$HOME/work/projects"
    "$HOME/code"
    "$HOME/Development"
)
```

### Workspace Configuration

Create `~/.goto_config` to auto-generate bookmarks:

```bash
# ~/.goto_config
~/work/projects
~/code/personal
~/Development/active
```

Then run `bookmark sync` to auto-create bookmarks for all subdirectories.

### Shortcuts

Add custom shortcuts in `lib/goto-function.sh`:

```bash
case "$1" in
    work)
        target_dir="$HOME/work/projects"
        ;;
    personal)
        target_dir="$HOME/code/personal"
        ;;
esac
```

---

## 🏗️ How It Works

**Navigation Flow:**
1. **Exact Match**: Check for exact folder name
2. **Shortcuts**: Check predefined shortcuts
3. **Bookmarks**: Check saved bookmarks (with fuzzy)
4. **Fuzzy Match**: Find partial matches
5. **AI Resolution**: Use Claude AI for natural language
6. **Smart Search**: Recursive search (up to 3 levels)

**Performance:**
- Fuzzy matching: <50ms (with caching)
- Tab completion: 22ms average
- Directory caching: 5-minute TTL
- All operations: Sub-50ms

---

## 📦 Requirements

### Required
- **Bash 3.2+** or **Zsh 5.0+**
- **Claude CLI** (optional, for natural language navigation)
  - [Download](https://github.com/anthropics/claude-code)
  - Only needed for natural language queries

### Optional
- **fd** - Faster directory scanning
- **fzf** - Enhanced fuzzy finding
- **bat** / **glow** - Pretty file display

---

## 📂 Project Structure

```
unix-goto/
├── bin/
│   └── goto-resolve              # Claude AI resolver
├── lib/
│   ├── goto-function.sh          # Main navigation function
│   ├── fuzzy-matching.sh         # Fuzzy matching engine
│   ├── bookmark-command.sh       # Bookmark management
│   └── back-command.sh           # Navigation history
├── completions/
│   ├── goto-completion.bash      # Bash completion
│   └── goto-completion.zsh       # Zsh completion
├── tests/
│   ├── test-fuzzy-matching.sh    # Fuzzy matching tests
│   ├── test-bookmark-sync.sh     # Bookmark sync tests
│   └── compliance-check-v0.4.0.sh # Full compliance check
├── .goto_config.example          # Config template
├── install.sh                    # Installation script
└── README.md                     # This file
```

---

## 🧪 Testing

### Run Tests

```bash
# Full test suite (44 tests)
./tests/run-all-tests.sh

# Fuzzy matching tests
./tests/test-fuzzy-matching.sh

# Bookmark sync tests
./tests/test-bookmark-sync.sh

# Compliance check
./tests/compliance-check-v0.4.0.sh
```

### Test Coverage
- **44** fuzzy matching tests
- **12** bookmark sync tests
- **17** compliance checks
- **100%** pass rate

---

## 📚 Documentation

- **[QUICKSTART-CONFIG.md](QUICKSTART-CONFIG.md)** - Configuration guide
- **[FEATURE-CONFIG-BOOKMARKS.md](FEATURE-CONFIG-BOOKMARKS.md)** - Bookmark sync details
- **[RELEASE-NOTES-v0.4.0.md](RELEASE-NOTES-v0.4.0.md)** - v0.4.0 release notes
- **[CONSTITUTION.md](CONSTITUTION.md)** - Project governance
- **[ROADMAP.md](ROADMAP.md)** - Future plans

---

## 🗺️ Roadmap

### ✅ Completed (v0.4.0)
- ✅ Fuzzy matching with caching
- ✅ Tab completion (bash + zsh)
- ✅ Configuration-based bookmark sync
- ✅ Multi-level fuzzy navigation
- ✅ Bookmark fuzzy matching
- ✅ Performance optimization (34x improvement)
- ✅ Comprehensive test suite

### 🚧 In Progress
- 🚧 Frecency algorithm (frequency + recency)
- 🚧 Smart learning from usage patterns
- 🚧 Configuration file validation

### 📋 Planned (v0.5.0+)
- File search integration (`gf` command)
- Workspace management
- IDE integrations
- AI-powered suggestions
- Cross-shell sync

See [ROADMAP.md](ROADMAP.md) for detailed plans.

---

## 🤝 Contributing

Contributions welcome! This tool is built for real-world productivity.

1. Fork the repository
2. Create your feature branch
3. Run tests: `./tests/run-all-tests.sh`
4. Submit a pull request

### Development Principles
- **Simplicity First**: Keep it simple and maintainable
- **No Over-Engineering**: Only what users need today
- **Performance Matters**: All operations <100ms
- **Test Everything**: Comprehensive test coverage
- **User Experience**: Make navigation effortless

See [CONSTITUTION.md](CONSTITUTION.md) for full principles.

---

## 📊 Performance

| Feature | Performance | Requirement | Status |
|---------|-------------|-------------|--------|
| Fuzzy matching | 43ms | <500ms | ✅ 91% faster |
| Tab completion | 22ms | <100ms | ✅ 78% faster |
| Cache build | 16ms | N/A | ✅ |
| Bookmark sync | Instant | N/A | ✅ |

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 👤 Author

**Manu Tej**

Built with Claude AI for better terminal navigation.

---

## 🎯 Use Cases

### For Individual Developers
- ✅ Effortless navigation across projects
- ✅ No remembering exact folder names
- ✅ Instant access to any directory
- ✅ Works across multiple machines

### For Teams
- ✅ Shareable configuration (template-based)
- ✅ Adapts to each developer's environment
- ✅ Consistent navigation commands
- ✅ Easy onboarding (3 commands)

### For Power Users
- ✅ Lightning-fast navigation (<50ms)
- ✅ Fuzzy matching + tab completion
- ✅ Automated bookmark management
- ✅ Extensive customization options

---

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/manutej/unix-goto/issues)
- **Discussions**: [GitHub Discussions](https://github.com/manutej/unix-goto/discussions)
- **Documentation**: See `/docs` folder

---

## 🙏 Acknowledgments

- Built with [Claude AI](https://www.anthropic.com/claude)
- Inspired by tools like `z`, `autojump`, and `fasd`
- Thanks to the open-source community

---

**Made with ❤️ and Claude Code** 🤖
