# Changelog

All notable changes to unix-goto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-10-08

### Added
- **Multi-level navigation support**: Navigate to nested folders using path separators
  - `goto project/subfolder/deep` now works seamlessly
  - Finds base folder in search paths, then navigates to nested path
  - Clear error messages if base exists but subpath doesn't
- **Recursive unique folder search**: Automatically finds folders by name
  - `goto unix-goto` finds `LUXOR/Git_Repos/unix-goto` automatically
  - Searches up to 3 levels deep in all search paths
  - Shows disambiguation menu if multiple matches found
  - Performance optimized with maxdepth 3
- CONTRIBUTING.md: Complete contributor guide
  - Branch protection and PR workflow documentation
  - Branching strategy (feature/*, fix/*, docs/*, test/*)
  - Pull request templates and guidelines
  - Code style standards
- ENHANCED-NAVIGATION-TESTS.md: Comprehensive testing guide
  - 20+ test scenarios for new features
  - Integration and regression tests
  - Performance testing procedures

### Changed
- Enhanced goto help text with multi-level and smart search examples
- Improved error messages with helpful suggestions
- Root-level folder matching now explicitly returns 0 for consistency

## [0.2.0] - 2025-10-07

### Added
- Navigation history tracking for all `goto` commands
- `back` command to navigate backward through directory history
  - `back` - Go to previous directory
  - `back N` - Go back N directories
  - `back --list` - Show navigation history
  - `back --clear` - Clear navigation history
- `recent` command to show recently visited folders
  - `recent` - List 10 most recent folders
  - `recent N` - List N most recent folders
  - `recent --goto N` - Navigate to Nth recent folder
  - `recent --clear` - Clear recent history
- `bookmark` command for managing favorite locations
  - `bookmark add <name> [path]` - Save bookmark
  - `bookmark list` - Show all bookmarks
  - `bookmark goto <name>` - Navigate to bookmark
  - `bookmark rm <name>` - Remove bookmark
  - `goto @<name>` - Navigate using @ prefix syntax
  - `bm` - Short alias for bookmark command
- `goto list` command to discover available destinations
  - `goto list` - Show all destinations
  - `goto list --shortcuts` - Show only shortcuts
  - `goto list --folders` - Show only folders
  - `goto list --bookmarks` - Show only bookmarks
- ROADMAP.md outlining future development plans
- CHANGELOG.md to track changes

### Changed
- goto function now automatically tracks all navigation in history
- Integrated history tracking with back command stack
- Enhanced goto help with bookmark and list information

## [0.1.0] - 2025-10-06

### Added
- Initial release of unix-goto
- `goto` command with natural language support
- Claude AI integration for natural language folder resolution
- Direct shortcuts (luxor, halcon, docs, infra)
- Direct folder name matching across search paths
- Special commands:
  - `goto ~` - Return to home directory
  - `goto zshrc` - Source and display .zshrc
  - `goto bashrc` - Source and display .bashrc
  - `goto --help` - Show help menu
- Installation script
- Comprehensive documentation
- Usage examples

[Unreleased]: https://github.com/manutej/unix-goto/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/manutej/unix-goto/releases/tag/v0.1.0
