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

## Phase 2: Navigation History & Bookmarks (Next)

### `back` - Navigate backward through history
```bash
back              # Go to previous directory
back 3            # Go back 3 directories in history
back --list       # Show navigation history
```

**Implementation:**
- Maintain a history stack in a temp file or shell array
- Hook into `cd` or wrap it to track directory changes
- Support numeric arguments to go back N steps

### `recent` - Show recently visited folders
```bash
recent            # List 10 most recent folders
recent 20         # List 20 most recent folders
recent --goto 3   # Navigate to 3rd recent folder
```

**Implementation:**
- Log all `goto` usage to ~/.goto_history
- Parse and display with timestamps
- Integrate with goto for quick navigation

### `bookmark` - Bookmark management
```bash
bookmark add proj1                    # Bookmark current folder as 'proj1'
bookmark add proj1 ~/path/to/folder   # Bookmark specific path
bookmark list                         # List all bookmarks
bookmark rm proj1                     # Remove bookmark
bookmark goto proj1                   # Go to bookmark
goto @proj1                           # Alternative syntax
```

**Implementation:**
- Store bookmarks in ~/.goto_bookmarks (JSON or key=value format)
- Integrate with goto for @ prefix syntax
- Support bookmark descriptions/notes

## Phase 3: Smart Search & Discovery

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

### `goto list` - Show available destinations
```bash
goto list                 # All folders in search paths
goto list --shortcuts     # Only shortcuts
goto list --bookmarks     # Only bookmarks
goto list --recent        # Recent folders
```

**Implementation:**
- Scan configured search paths
- Display formatted output with categories
- Support filtering and sorting

## Phase 4: Productivity Enhancements

### `goto exec` - Execute commands in target directory
```bash
goto exec infra "git status"
goto exec luxor "ls -la"
goto exec "the halcon project" "npm run dev"
```

**Implementation:**
- Navigate to folder
- Execute command
- Return to original directory (optional flag)

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

### `goto watch` - Monitor folder and navigate on changes
```bash
goto watch GAI-3101      # Navigate when files change
goto watch infra --exec "git status"
```

**Implementation:**
- Use fswatch or inotify
- Trigger navigation or commands on file changes

## Phase 5: AI-Powered Features

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

## Phase 6: Integration & Ecosystem

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

### Performance
- [ ] Cache folder listings
- [ ] Async Claude AI calls
- [ ] Parallel search across paths
- [ ] Intelligent caching of NLP results

### UX Enhancements
- [ ] Fuzzy matching for folder names
- [ ] Tab completion for all commands
- [ ] Rich output formatting (colors, icons)
- [ ] Progress indicators for slow operations

### Testing & Quality
- [ ] Unit tests for all functions
- [ ] Integration tests with mocked Claude
- [ ] Shell script linting (shellcheck)
- [ ] Automated release pipeline

### Configuration
- [ ] Config file support (~/.gotorc)
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
1. Phase 2 features (history & bookmarks)
2. Testing framework
3. Performance optimizations
4. Documentation improvements

---

Last updated: 2025-10-06
