# unix-goto Roadmap

## Vision

Build a comprehensive suite of Unix navigation and productivity tools that leverage Claude AI to make terminal workflows more intuitive and efficient.

## Phase 1: Core Navigation ✅ (Completed)

- [x] `goto` - Smart folder navigation with natural language
- [x] Basic shortcuts (luxor, docs, infra, halcon)
- [x] Direct folder matching
- [x] Claude AI natural language resolver
- [x] Special commands (~, zshrc, --help)
- [x] Installation script
- [x] Documentation

## Phase 2: Navigation History & Bookmarks ✅ (Completed)

### `back` - Navigate backward through history ✅
```bash
back              # Go to previous directory
back 3            # Go back 3 directories in history
back --list       # Show navigation history
```

**Status:** ✅ Complete
- Directory stack maintained in ~/.goto_stack
- Support for numeric arguments
- List and clear functionality

### `recent` - Show recently visited folders ✅
```bash
recent            # List 10 most recent folders
recent 20         # List 20 most recent folders
recent --goto 3   # Navigate to 3rd recent folder
```

**Status:** ✅ Complete
- All goto usage logged to ~/.goto_history
- Recent folder display with timestamps
- Quick navigation with --goto

### `bookmark` - Bookmark management ✅
```bash
bookmark add proj1                    # Bookmark current folder as 'proj1'
bookmark add proj1 ~/path/to/folder   # Bookmark specific path
bookmark list                         # List all bookmarks
bookmark rm proj1                     # Remove bookmark
bookmark goto proj1                   # Go to bookmark
goto @proj1                           # Alternative syntax
```

**Status:** ✅ Complete
- Bookmarks stored in ~/.goto_bookmarks
- @ prefix syntax integrated with goto
- Full CRUD operations (add, list, goto, remove)
- Short alias: `bm`

### `goto list` - Show available destinations ✅
```bash
goto list                # All available destinations
goto list --shortcuts    # Only shortcuts
goto list --bookmarks    # Only bookmarks
goto list --folders      # Only folders
```

**Status:** ✅ Complete
- Displays all navigation options
- Categorized by type (shortcuts, bookmarks, folders)
- Colored output for better readability

## Phase 3: High-Performance Navigation (v0.4.0 - Planned)

**Focus:** Speed, usability, and scripting support - NO AI features

### 1. Folder Index Caching System ⏳
```bash
goto index rebuild       # Build/rebuild folder index cache
goto index status        # Show cache stats
goto index clear         # Clear cache
```

**Implementation:**
- Cache all navigable folders in `~/.goto_index`
- Reduce navigation from ~2-5s to <100ms for cached lookups
- Auto-refresh cache when older than 24 hours
- O(1) lookup instead of O(n) file system scans

### 2. Quick Bookmark Current Directory ⏳
```bash
bookmark .               # Bookmark current dir with folder name
bookmark here proj1      # Bookmark current dir as "proj1"
bookmark add proj1 .     # Alternative syntax
```

**Implementation:**
- Detect `.` argument and replace with `$PWD`
- Extract folder name for auto-naming
- No need to type full path

### 3. Configurable Search Depth ⏳
```bash
goto --depth 5 unix-goto         # One-time deeper search
goto config set depth 4          # Update default depth
goto config                      # Show current config
```

**Implementation:**
- Create `~/.gotorc` configuration file
- Default depth: 3 (backward compatible)
- Per-search override with `--depth` flag
- Configurable settings: depth, cache TTL, parallel search

### 4. Tab Completion for Bash/Zsh ⏳
**Implementation:**
- Bash completion script: `completions/goto-completion.bash`
- Zsh completion script: `completions/goto-completion.zsh`
- Complete subcommands, bookmarks (@name), shortcuts, folders
- Auto-installed via `install.sh`

### 5. Batch-Friendly Output Modes ⏳
```bash
goto list --format json          # {"shortcuts": [...], "bookmarks": [...]}
goto list --format simple        # One path per line (for scripting)
goto --quiet luxor               # Suppress human-readable output
goto pwd @proj1                  # Print path without navigating
goto check unix-goto --quiet     # Test if exists (exit code only)
```

**Implementation:**
- `--format json|simple|csv` flags
- `--quiet` mode for scripts
- `goto pwd <target>` - print path without navigation
- `goto check <target>` - existence test (exit code)

### 6. Execute Commands in Target Directory ⏳
```bash
goto exec luxor "git status"     # Run in luxor, return here
goto exec @proj1 "npm test"      # Run in bookmark
goto exec --stay luxor "git pull" # Navigate and stay
```

**Implementation:**
- Execute command in target directory
- Return to original directory by default
- `--stay` flag to remain in target
- Preserve command exit codes

## Phase 4: Advanced Performance & UX (v0.5.0 - Planned)

**Focus:** Optimization and advanced matching

### 1. Parallel Search Across Multiple Paths ⏳
**Implementation:**
- Launch searches in background jobs across all search paths
- Collect results as they complete
- Early termination on first unique match
- ~50% faster for multi-path searches

### 2. Fuzzy Matching for Folder Names ⏳
```bash
goto halcn           # Fuzzy match → HALCON
goto gai3            # Fuzzy match → GAI-3101
goto unx-gt          # Fuzzy match → unix-goto
```

**Implementation:**
- Levenshtein distance algorithm
- Interactive selection for multiple fuzzy matches
- Configurable fuzzy threshold
- Can disable: `GOTO_FUZZY=false` in ~/.gotorc

### 3. Performance Benchmark Suite ⏳
```bash
./bin/benchmark-goto             # Run comprehensive benchmarks
```

**Implementation:**
- Automated benchmark script
- Measure cache vs no-cache, parallel vs sequential, depth impact
- Generate comparison reports
- CI integration for regression detection

## Phase 5: Smart Search & Discovery (v0.6.0 - Future)

**Focus:** AI-powered search and workspace management

### `finddir` - Natural language directory search
```bash
finddir "projects from last month"
finddir "folders with python code"
finddir "large directories over 1GB"
```

**Implementation:**
- Use Claude AI to interpret search criteria
- Combine with find/fd commands
- Return ranked results based on relevance

### Enhanced `goto list` Features
```bash
goto list --recent               # Recent folders from history
goto list --sort name            # Alphabetical sorting
goto list --search python        # Filter by keyword
```

**Implementation:**
- Recent filter integration
- Multiple sorting options (name, recent, size, modified)
- Keyword search/filter

## Phase 6: Productivity Enhancements (v0.7.0 - Future)

### `workspace` - Manage multi-folder workspaces
```bash
workspace create mywork infra halcon GAI-3101
workspace list
workspace open mywork         # Opens all in tmux/tabs
workspace goto mywork         # Interactive selection
```

**Implementation:**
- Store workspace definitions in ~/.goto_workspaces
- Integration with tmux for split panes
- Support for VS Code workspace files

## Phase 7: AI-Powered Features (Future)

### Enhanced natural language understanding
- Context awareness (time-based, project-based)
- Learning from usage patterns
- Suggestions based on workflow

### `smart` - AI assistant for navigation
```bash
smart "where was I working on the API last week?"
smart "find me the folder with the most recent commits"
smart "suggest a good place to start this new feature"
```

**Implementation:**
- Deep Claude AI integration
- Access to git history, file metadata
- Personalized recommendations

### Auto-categorization
- Automatically detect project types
- Group similar projects
- Smart tags and organization

## Phase 8: Integration & Ecosystem (Future)

### Git integration
```bash
goto branch feature/new-thing    # Navigate to repo and checkout branch
goto repo manutej/unix-goto      # Clone and navigate to repo
goto pr 123                      # Navigate to PR folder
```

### IDE integration
- VS Code extension
- JetBrains plugin
- Vim/Neovim plugin

### Cloud storage support
- Dropbox, Google Drive navigation
- Remote server bookmarks (SSH)
- Container navigation (Docker)

## Technical Improvements

### Performance (Phase 3 & 4)
- [ ] Cache folder listings → Phase 3 Feature #1
- [ ] Parallel search across paths → Phase 4 Feature #1
- [ ] Async Claude AI calls → Phase 7 (AI features)
- [ ] Intelligent caching of NLP results → Phase 7 (AI features)

### UX Enhancements (Phase 3 & 4)
- [ ] Tab completion for all commands → Phase 3 Feature #4
- [ ] Fuzzy matching for folder names → Phase 4 Feature #2
- [ ] Rich output formatting (colors, icons) → Ongoing
- [ ] Progress indicators for slow operations → Ongoing

### Testing & Quality
- [ ] Unit tests for all functions
- [ ] Integration tests with mocked Claude
- [ ] Shell script linting (shellcheck)
- [ ] Automated release pipeline
- [ ] Performance benchmarks → Phase 4 Feature #3

### Configuration (Phase 3)
- [ ] Config file support (~/.gotorc) → Phase 3 Feature #3
- [ ] Per-project configuration
- [ ] Environment-specific settings
- [ ] Profiles (work, personal, etc.)

## Community Features

### Sharing & Collaboration
- [ ] Export/import bookmarks
- [ ] Share workspace definitions
- [ ] Community bookmark registry
- [ ] Plugin system for extensions

### Documentation
- [ ] Video tutorials
- [ ] Interactive examples
- [ ] Best practices guide
- [ ] Migration guides

## Long-term Vision

Transform terminal navigation from a manual, path-based process to an intuitive, intent-based workflow where you tell the system **where you want to go** or **what you want to do**, and it figures out the rest.

### Example Future Workflow:
```bash
# Morning routine
smart morning           # Opens daily workspace based on schedule

# Natural intent
goto "start the API work"        # Understands context, opens right folder
goto "continue what I was doing" # Remembers last session

# Project discovery
smart "show me what needs attention"  # Checks git status, deadlines, etc.

# Seamless context switching
workspace switch client-work     # Switches entire terminal context
```

## Contributing

Want to help build this? Check out the [Contributing Guide](CONTRIBUTING.md) and pick an item from the roadmap!

Priority areas for contribution:
1. **Phase 3 features** (folder caching, quick bookmarking, tab completion)
2. **Phase 4 features** (parallel search, fuzzy matching, benchmarks)
3. Testing framework
4. Documentation improvements

---

Last updated: 2025-10-17
