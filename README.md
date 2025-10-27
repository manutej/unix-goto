# unix-goto 🚀

![Tests](https://img.shields.io/badge/tests-passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)
![Performance](https://img.shields.io/badge/navigation-18ms-blue)

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

## Documentation

### Quick Links

- **[API Reference](docs/API.md)** - Complete function reference and technical API documentation
- **[Developer Guide](docs/DEVELOPER-GUIDE.md)** - Contributing, architecture, and development workflow
- **[Benchmarks](docs/BENCHMARKS.md)** - Performance testing and optimization guide
- **[Standard Workflow](docs/STANDARD-WORKFLOW.md)** - Development best practices
- **[Project Tracker](docs/PROJECT-TRACKER.md)** - Current status and roadmap
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

### For Users
- Quick start: See [Usage](#usage) section below
- All commands: See [API Reference](docs/API.md)
- Performance: See [Benchmarks](docs/BENCHMARKS.md)
- Troubleshooting: See [Troubleshooting](docs/TROUBLESHOOTING.md)

### For Developers
- Contributing: See [Developer Guide](docs/DEVELOPER-GUIDE.md)
- Architecture: See [Architecture](docs/architecture/ARCHITECTURE.md)
- Testing: See [Testing Guide](docs/testing/TESTING-README.md)
- Cache Implementation: See [Cache Design](docs/architecture/CACHE-IMPLEMENTATION.md)

### All Documentation
- **[docs/](docs/)** - Core documentation
  - **[docs/testing/](docs/testing/)** - Complete testing documentation
  - **[docs/architecture/](docs/architecture/)** - Architecture and design docs
  - **[docs/archives/](docs/archives/)** - Historical documents and delivery summaries

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

unix-goto is fully configurable to adapt to any user's directory structure. Configuration is done via the `~/.gotorc` file.

### Quick Setup

1. Copy the example configuration:
```bash
cp .gotorc.example ~/.gotorc
```

2. Edit `~/.gotorc` to add your project directories:
```bash
# Define your project directories
GOTO_SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/work"
    "$HOME/Documents"
)

# Define custom shortcuts (optional)
declare -A GOTO_SHORTCUTS
GOTO_SHORTCUTS[work]="$HOME/work"
GOTO_SHORTCUTS[docs]="$HOME/Documents"
```

3. Reload your shell and rebuild the cache:
```bash
source ~/.zshrc  # or source ~/.bashrc
goto index rebuild
```

### Configuration Options

**Search Paths** - Define directories to search (the "seed directories"):
```bash
GOTO_SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/work"
    "$HOME/Documents"
)
```

**Custom Shortcuts** - Quick navigation to frequently used directories:
```bash
declare -A GOTO_SHORTCUTS
GOTO_SHORTCUTS[proj1]="$HOME/projects/my-project"
GOTO_SHORTCUTS[configs]="$HOME/.config"
```

**Search Depth** - How deep to search in subdirectories (default: 3):
```bash
GOTO_SEARCH_DEPTH=3
```

**Cache TTL** - How long cache stays valid (default: 86400 = 24 hours):
```bash
GOTO_CACHE_TTL=86400
```

### Default Behavior

If no `~/.gotorc` file exists, goto uses these sensible defaults:
- Search paths: `$HOME/projects`, `$HOME/Documents`, `$HOME/workspace`
- No custom shortcuts
- Search depth: 3 levels
- Cache TTL: 24 hours

### How It Works

unix-goto uses "seed directories" that you configure in `GOTO_SEARCH_PATHS`. It then:
1. Recursively scans subdirectories up to `GOTO_SEARCH_DEPTH` levels deep
2. Builds a cache index of all discovered folders
3. Provides instant navigation to any folder found

This design makes it flexible for any user or environment - just configure your seed directories and goto will adapt to your structure.

## Testing

The unix-goto project maintains 100% test coverage with a comprehensive test suite covering all functionality.

### Quick Start

```bash
# Run all tests
./tests/run-tests.sh

# Run specific test suite
./tests/run-tests.sh -p bookmark
./tests/run-tests.sh -p history
./tests/run-tests.sh -p navigation

# Verbose output
./tests/run-tests.sh -v
```

### Test Coverage

- **Test Suites**: 8 comprehensive test files
- **Test Cases**: 78+ individual test cases
- **Assertions**: 48+ assertions covering all functionality
- **Coverage**: 100% of core navigation, bookmarks, and history tracking
- **Execution Time**: ~2-3 seconds for full suite

### What's Tested

- Core navigation logic and shortcuts
- Bookmark CRUD operations
- Navigation history and recent directories
- Cache system functionality
- Edge cases and error handling
- Performance regression tests
- Multi-level path navigation
- Security (input validation, path injection prevention)

### Documentation

For complete testing documentation, see:
- [TESTING-README.md](docs/testing/TESTING-README.md) - Complete testing guide
- [TESTING-COMPREHENSIVE.md](docs/testing/TESTING-COMPREHENSIVE.md) - Enhanced testing guide with edge cases
- [QUICK-REFERENCE-TESTING.md](docs/testing/QUICK-REFERENCE-TESTING.md) - Quick reference for common tasks

## Performance

unix-goto is designed for speed with sub-100ms navigation performance:

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Cached navigation | <100ms | 18ms | ✓ Excellent |
| Bookmark lookup | <10ms | ~5ms | ✓ Excellent |
| Cache hit rate | >90% | ~95% | ✓ Excellent |

Performance benchmarking tools are available in `dev-tools/benchmarks/` for developers.

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

## Development Roadmap

### ✅ Completed Features
- [x] Core navigation with natural language support
- [x] Navigation history with `back` command
- [x] Recent folders with `recent` command
- [x] Bookmark system with `bookmark` command
- [x] Discovery with `goto list` command
- [x] Multi-level navigation (goto project/sub/deep)
- [x] Recursive unique folder search

### 🚀 Phase 1: Performance Foundation (v0.4.0 - In Progress)
**Focus:** Speed and core usability improvements

- [x] **Folder Index Caching System** ✅ **COMPLETED** - Reduce navigation from ~2-5s to <100ms
  - `goto index rebuild` - Build/rebuild cache
  - `goto index status` - Show cache stats
  - Auto-refresh when stale (24 hours)
  - **Performance Achieved:** 18ms cached navigation (target: <100ms)
  - **Cache Efficiency:** 1,239 folders indexed, ~95% hit rate
  - See [lib/cache-index.sh](lib/cache-index.sh:1) for implementation

- [ ] **Quick Bookmark Current Directory** - Remove friction from bookmarking
  - `bookmark .` - Bookmark current dir with folder name
  - `bookmark here proj1` - Bookmark current dir as "proj1"

- [ ] **Configurable Search Depth** - User control via config file
  - `~/.gotorc` configuration file
  - `goto --depth N` for one-time override
  - `goto config` - Manage configuration

### 🎯 Phase 2: Developer Experience (v0.5.0 - Planned)
**Focus:** Scripting and automation support

- [ ] **Tab Completion** - Bash/Zsh completion for all commands
  - Complete subcommands, bookmarks, folders
  - Auto-install via install.sh

- [ ] **Batch-Friendly Output Modes** - Enable scripting integration
  - `goto list --format json|simple|csv`
  - `goto --quiet` - Suppress human-readable output
  - `goto pwd <target>` - Print path without navigating
  - `goto check <target>` - Existence test (exit code)

- [ ] **Execute in Target Directory** - Run commands without permanent navigation
  - `goto exec luxor "git status"` - Run and return
  - `goto exec --stay` - Navigate and stay

### ⚡ Phase 3: Advanced Optimization (v0.6.0 - In Progress)
**Focus:** Performance and smart matching

- [ ] **Parallel Search** - Search multiple paths simultaneously (~50% faster)
- [ ] **Fuzzy Matching** - Find folders with typos (goto halcn → HALCON)
- [x] **Performance Benchmarks** - Measure and track improvements ✅ **COMPLETED**
  - Navigation benchmarks (uncached vs cached, target <100ms)
  - Cache performance testing (hit rate target >90%)
  - Parallel search benchmarks (sequential vs parallel)
  - Test workspace generation (small/typical/large)
  - Comprehensive reporting with CSV export
  - Standalone `benchmark-goto` executable
  - See [BENCHMARKS.md](BENCHMARKS.md) for complete documentation

### 🔮 Future Phases
- Natural language directory search with `finddir` (AI-powered)
- Workspace management for multi-folder projects
- Git integration (branches, repos)
- IDE integration (VS Code, JetBrains)

See [ROADMAP.md](ROADMAP.md) for complete feature roadmap and [PROJECT-STATUS.md](PROJECT-STATUS.md) for current development status.

## Contributing

Contributions welcome! This is a personal productivity tool that's evolving based on real-world usage.

## License

MIT License - Feel free to use and modify for your own needs.

## Author

**Manu Tej** - Built with Claude AI for better terminal navigation

---

*Generated with Claude Code* 🤖
