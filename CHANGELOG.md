# Changelog

All notable changes to unix-goto will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- ROADMAP.md outlining future development plans
- CHANGELOG.md to track changes

### Changed
- goto function now automatically tracks all navigation in history
- Integrated history tracking with back command stack

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
