# unix-goto Product Specification

**Version:** 1.0
**Date:** 2025-11-10
**Status:** Production Ready → Enhancement Phase
**Target:** Become the indispensable file navigation tool for CLI developers

---

## Executive Summary

**unix-goto** is a smart terminal navigation utility that combines natural language understanding, intelligent search, and productivity features to eliminate the friction of filesystem navigation. This specification outlines the current state (v0.3.0) and the roadmap to make it an indispensable tool for every developer working in the CLI.

**Vision:** Make filesystem navigation as intuitive and fast as IDE navigation, but with Unix philosophy simplicity.

**Mission:** Save developers 30+ minutes per day by eliminating manual path traversal and memorization.

---

## 1. Current State Assessment

### 1.1 Product Overview

unix-goto is a shell-based navigation utility offering:

```
┌─────────────────────────────────────────────────────────┐
│                    unix-goto v0.3.0                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Core Navigation:                                       │
│  • Natural language (Claude AI)                         │
│  • Multi-level paths (project/sub/deep)                 │
│  • Recursive search (finds nested folders)              │
│  • Shortcuts (luxor, halcon, docs, infra)               │
│                                                         │
│  History & Bookmarks:                                   │
│  • back command (navigation stack)                      │
│  • recent command (visit history)                       │
│  • bookmark system (@syntax)                            │
│  • goto list (discovery)                                │
│                                                         │
│  Quality:                                               │
│  • Production-ready code (Grade A)                      │
│  • Cross-platform (macOS + Linux)                       │
│  • Automated tests                                      │
│  • Comprehensive documentation                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Technical Architecture

```
unix-goto/
├── bin/
│   └── goto-resolve              # Claude AI natural language resolver
├── lib/
│   ├── goto-function.sh          # Core navigation logic
│   ├── back-command.sh           # Navigation history stack
│   ├── recent-command.sh         # Recent folders tracking
│   ├── bookmark-command.sh       # Bookmark CRUD operations
│   ├── list-command.sh           # Discovery interface
│   └── history-tracking.sh       # Automatic visit logging
├── tests/
│   ├── run-tests.sh              # Comprehensive test suite
│   └── test-basic.sh             # Fast smoke tests
└── install.sh                    # Automated installation
```

**Technology Stack:**
- **Language:** Pure Bash (portable, no dependencies)
- **AI Integration:** Claude CLI for NLP
- **Data Storage:** Plain text files (~/.goto_*)
- **Supported Shells:** bash, zsh

### 1.3 Current Metrics

| Metric | Current State |
|--------|---------------|
| **Lines of Code** | ~1,500 (shell scripts) |
| **Commands** | 5 (goto, back, recent, bookmark, list) |
| **Features** | 12 navigation modes |
| **Code Quality** | A (Excellent) |
| **Test Coverage** | Basic (smoke tests) |
| **Documentation** | Comprehensive (8 guides) |
| **Install Time** | < 2 minutes |
| **Response Time** | 0.5-2s (depending on operation) |

### 1.4 User Workflows Supported

#### Basic Navigation
```bash
# Direct shortcuts
goto luxor          # → ~/Documents/LUXOR

# Direct folder matching
goto GAI-3101       # → Searches and navigates

# Multi-level paths
goto GAI-3101/docs  # → Navigate to nested folder

# Natural language
goto "the halcon project"  # → Claude AI resolves to HALCON
```

#### History & Bookmarks
```bash
# Navigate back
back                # Previous directory
back 3              # Go back 3 steps

# Recent folders
recent              # Show 10 recent
recent --goto 3     # Navigate to 3rd recent

# Bookmarks
bookmark add work   # Save current location
goto @work          # Quick navigation
```

#### Discovery
```bash
# List available destinations
goto list                # All destinations
goto list --shortcuts    # Only shortcuts
goto list --bookmarks    # Only bookmarks
```

---

## 2. Gap Analysis: What's Missing?

### 2.1 Critical Pain Points

#### Pain Point 1: Exact Typing Required
**Current State:** Must type exact directory names
```bash
goto GAI-3101  ✓
goto gai       ✗ (doesn't work)
goto ga3       ✗ (doesn't work)
```

**Impact:**
- Cognitive load (must remember exact names)
- Slow navigation (must type full names)
- Frustration (typos cause failures)

**Severity:** 🔥 CRITICAL

#### Pain Point 2: No Interactive Exploration
**Current State:** No tab completion
```bash
goto <TAB>     # Nothing happens
goto GA<TAB>   # Nothing happens
```

**Impact:**
- Can't discover what's available
- Must remember all directory names
- No muscle memory benefit

**Severity:** 🔥 CRITICAL

#### Pain Point 3: No File Search
**Current State:** Only navigates to directories
```bash
# Want to find a file?
find . -name "config.json"  # Must use separate tool
rg "API_KEY"                # Must use separate tool
```

**Impact:**
- Broken workflow (must switch tools)
- Can't navigate to files, only dirs
- Missing 50% of navigation use cases

**Severity:** 🔥 HIGH

#### Pain Point 4: No Smart Suggestions
**Current State:** No learning from usage patterns
```bash
# Visit GAI-3101 100 times...
goto GAI-3101  # Still need to type full name every time
```

**Impact:**
- No efficiency gains over time
- Doesn't adapt to workflow
- Misses low-hanging optimization

**Severity:** 🔥 HIGH

### 2.2 Feature Comparison

| Feature | unix-goto | z/zoxide | fzf | autojump | Ideal |
|---------|-----------|----------|-----|----------|-------|
| Fuzzy matching | ❌ | ✅ | ✅ | ✅ | ✅ |
| Frecency | ❌ | ✅ | ❌ | ✅ | ✅ |
| Tab completion | ❌ | ✅ | ✅ | ✅ | ✅ |
| Natural language | ✅ | ❌ | ❌ | ❌ | ✅ |
| File search | ❌ | ❌ | ✅ | ❌ | ✅ |
| Content search | ❌ | ❌ | ✅ | ❌ | ✅ |
| Bookmarks | ✅ | ❌ | ❌ | ❌ | ✅ |
| Multi-level paths | ✅ | ❌ | ❌ | ❌ | ✅ |
| Git-aware | ❌ | ❌ | ❌ | ❌ | ✅ |
| Workspaces | ❌ | ❌ | ❌ | ❌ | ✅ |

**Competitive Analysis:**
- ✅ **Advantage:** Natural language, bookmarks, multi-level paths
- ❌ **Disadvantage:** Fuzzy matching, frecency, tab completion, file search

### 2.3 User Research Insights

**Developer Pain Points** (from community feedback):

1. **"I waste 10 minutes a day navigating directories"**
   - Average developer: 50+ directory changes per day
   - 10-20 seconds per navigation = 8-17 minutes wasted
   - **Opportunity:** Save 50% with smart navigation

2. **"I can never remember where files are"**
   - Projects grow to 1000+ files
   - Deep nesting (5-7 levels common)
   - **Opportunity:** Provide instant file search

3. **"Context switching kills my flow"**
   - Must remember multiple project paths
   - Copy-pasting paths is tedious
   - **Opportunity:** Workspaces + smart bookmarks

4. **"I use multiple tools for navigation"**
   - cd + z + find + rg + bookmarks
   - Context switching between tools
   - **Opportunity:** Unified navigation utility

---

## 3. Product Vision: Indispensable Navigation Utility

### 3.1 Vision Statement

**unix-goto will become the ONE tool developers reach for when navigating filesystems in the terminal.**

It will:
- ✅ Save 30+ minutes per day
- ✅ Eliminate cognitive load of path memorization
- ✅ Work seamlessly with developer workflows
- ✅ Feel like magic (fast, intuitive, smart)

### 3.2 Design Principles

#### 1. Zero Configuration, Maximum Power
```
Simple out of the box → Powerful when needed
- Default: Works perfectly without config
- Advanced: Extensive customization available
```

#### 2. Speed is King
```
Every operation < 500ms
- Fuzzy search: < 100ms
- Tab completion: < 50ms
- File search: < 2s (for reasonable repos)
```

#### 3. Composable & Unix-friendly
```
Plays well with pipes, scripts, other tools
- Output is parseable
- Exit codes are meaningful
- Can be used in automation
```

#### 4. Progressive Enhancement
```
Core features work everywhere
Advanced features leverage available tools
- Basic: Pure bash, no dependencies
- Enhanced: Uses fd, rg, fzf, bat when available
```

#### 5. Context-Aware Intelligence
```
Learns from usage, adapts to workflow
- Frecency: Most-used directories surface first
- Git-aware: Understands repository context
- Time-aware: Work dirs during work hours
```

---

## 4. Product Specification: v0.4.0 → v1.0

### 4.1 Feature Roadmap

```
v0.3.0 (Current) ─────────────────────┐
                                      │
v0.4.0 (Quick Wins) ──────────────────┤  2-4 weeks
  • Fuzzy matching                    │
  • Tab completion                    │
  • Frecency algorithm                │
  • Git-aware navigation              │
  • Quick stats (--info)              │
                                      │
v0.5.0 (File Search) ─────────────────┤  1-2 months
  • gf (goto file)                    │
  • gs (goto search - content)        │
  • j (smart jump)                    │
  • fzf integration                   │
  • File preview                      │
                                      │
v0.6.0 (Workflows) ───────────────────┤  2-3 months
  • Quick edit workflows              │
  • Project detection                 │
  • Smart suggestions                 │
  • Beautiful output                  │
  • Enhanced errors                   │
                                      │
v1.0.0 (Power Features) ──────────────┘  3-6 months
  • Workspace management
  • Plugin system
  • Remote support
  • Advanced search
  • Performance dashboard
```

### 4.2 Core Feature Specifications

---

#### Feature 1: Fuzzy Matching

**Priority:** 🔥 CRITICAL
**Target Release:** v0.4.0
**Effort:** 2-3 days

**User Story:**
```
As a developer,
I want to type partial directory names,
So that I can navigate quickly without exact recall.
```

**Acceptance Criteria:**
```bash
✓ goto gai → Navigates to GAI-3101
✓ goto hlcn → Navigates to HALCON
✓ goto unx → Navigates to unix-goto
✓ Ambiguous matches show options
✓ Match quality scoring works
✓ Performance: < 100ms for 1000 dirs
```

**Technical Approach:**
- Algorithm: Substring + Levenshtein distance
- Scoring: 0 (exact) → 100 (poor match)
- Show top 5 matches if ambiguous
- Cache results for performance

**Success Metrics:**
- 95% of fuzzy searches succeed
- Average keystrokes reduced by 40%
- User satisfaction: 90%+

---

#### Feature 2: Tab Completion

**Priority:** 🔥 CRITICAL
**Target Release:** v0.4.0
**Effort:** 3-4 days

**User Story:**
```
As a developer,
I want to press TAB to see available options,
So that I can explore and discover destinations.
```

**Acceptance Criteria:**
```bash
✓ goto <TAB> shows: shortcuts, bookmarks, directories
✓ goto @<TAB> shows: all bookmarks
✓ goto GA<TAB> shows: GAI-3101, GAI-3102, ...
✓ bookmark <TAB> shows: add, rm, list, goto
✓ Works in both bash and zsh
✓ Response time: < 50ms
```

**Technical Approach:**
- Bash: Custom completion script
- Zsh: _goto compdef function
- Dynamic completion from data files
- Smart filtering by context

**Success Metrics:**
- 70% of users use tab completion
- Discovery time reduced by 60%
- Error rate reduced by 30%

---

#### Feature 3: Frecency Algorithm

**Priority:** 🔥 HIGH
**Target Release:** v0.4.0
**Effort:** 2-3 days

**User Story:**
```
As a developer,
I want frequently/recently used directories to be suggested first,
So that I can navigate faster over time.
```

**Acceptance Criteria:**
```bash
✓ Tracks frequency of directory visits
✓ Tracks recency (timestamp of last visit)
✓ Calculates combined score
✓ Surfaces high-scoring directories first
✓ Adapts to changing patterns
✓ Performance: < 10ms per calculation
```

**Algorithm:**
```
score = (frequency * 0.5) + (recency * 0.3) + (context * 0.2)

Where:
- frequency: visit count (normalized to 0-100)
- recency: time decay (100 for today, 0 for 30+ days ago)
- context: git repo context bonus (0 or 100)
```

**Success Metrics:**
- Top 3 suggestions are correct 80% of time
- Navigation speed improves 30% after 1 week
- User reports feeling "faster"

---

#### Feature 4: File Search (gf command)

**Priority:** 🔥 HIGH
**Target Release:** v0.5.0
**Effort:** 3-4 days

**User Story:**
```
As a developer,
I want to find and navigate to files by name,
So that I don't need to remember directory structure.
```

**Acceptance Criteria:**
```bash
✓ gf config.json → Finds and navigates to file's directory
✓ gf "*.py" → Lists all Python files
✓ gf api --edit → Opens file in $EDITOR
✓ gf test --list → Just lists, doesn't navigate
✓ Works with fd (if available) or find
✓ Fuzzy matching for filenames
✓ Interactive picker with fzf
✓ Performance: < 2s for typical repo
```

**Technical Approach:**
- Use fd (fast) if available, fallback to find
- Integrate with fzf for interactive selection
- Support multiple actions (--goto, --edit, --show)
- Cache results for repeated searches

**Success Metrics:**
- 60% of users adopt gf command
- File discovery time: 5x faster
- User satisfaction: 85%+

---

#### Feature 5: Content Search (gs command)

**Priority:** 🔥 HIGH
**Target Release:** v0.5.0
**Effort:** 3-4 days

**User Story:**
```
As a developer,
I want to search file contents and navigate to results,
So that I can find code quickly.
```

**Acceptance Criteria:**
```bash
✓ gs "TODO" → Finds all TODOs
✓ gs "function.*login" → Regex search
✓ gs "import React" --goto → Navigate to first match
✓ gs "API_KEY" --env → Search only .env files
✓ Works with rg (if available) or grep
✓ Interactive results with preview
✓ Performance: < 2s for typical repo
```

**Technical Approach:**
- Use ripgrep (fast) if available, fallback to grep
- Integrate with bat for syntax-highlighted preview
- Support file type filters (--py, --js, --env)
- Natural language → regex translation via Claude

**Success Metrics:**
- 50% of users adopt gs command
- Code discovery time: 10x faster
- Reduces IDE switching by 40%

---

#### Feature 6: Smart Jump (j command)

**Priority:** HIGH
**Target Release:** v0.5.0
**Effort:** 1-2 days

**User Story:**
```
As a developer,
I want the fastest possible navigation,
So that I can focus on coding, not paths.
```

**Acceptance Criteria:**
```bash
✓ j gai → Jump to most frequent GAI-* directory
✓ j work → Jump to @work bookmark OR work directory
✓ j → Show frecency-ranked list
✓ j --help → Show usage
✓ Performance: < 100ms
✓ Auto-learns from usage
```

**Technical Approach:**
- Combines: frecency + fuzzy matching + bookmarks
- Single character command (minimal typing)
- Smart resolution order:
  1. Exact bookmark match
  2. Frecency-ranked fuzzy match
  3. AI resolution (if spaces)

**Success Metrics:**
- j becomes most-used command
- Average navigation: < 5 keystrokes
- 90% of navigations via j command

---

### 4.3 User Experience Specifications

#### Beautiful Output
```
Current:
→ /Users/user/Documents/LUXOR/GAI-3101

Enhanced:
🚀 Navigating to GAI-3101
   📂 /Users/user/Documents/LUXOR/GAI-3101
   📊 Size: 2.3 GB | 1,234 files
   📦 Git: Clean (main branch)
   🕒 Last visited: 2 hours ago (23 times)
```

#### Smart Error Messages
```
Current:
❌ Project not found: gai

Enhanced:
❌ Project not found: gai

💡 Did you mean?
   1) GAI-3101 (visited 23 times) - High confidence
   2) GAI-3102 (visited 2 times) - Medium confidence

🔍 Or try:
   gf gai      # Search files
   gs gai      # Search contents
   j gai       # Smart jump
```

#### Progress Indicators
```
Large operations show progress:

🔍 Searching 5,234 files...
    ⣾ 1,234 files scanned (23%)
    ⚡ 12 matches found so far...

✓ Search complete! Found 15 matches in 1.8s
```

---

## 5. Technical Specifications

### 5.1 Performance Requirements

| Operation | Target | Maximum |
|-----------|--------|---------|
| Fuzzy search | < 100ms | 200ms |
| Tab completion | < 50ms | 100ms |
| Frecency calculation | < 10ms | 50ms |
| File search (fd) | < 2s | 5s |
| Content search (rg) | < 2s | 5s |
| Smart jump | < 100ms | 200ms |
| Startup/init | < 50ms | 100ms |

### 5.2 Scalability Requirements

| Metric | Target | Maximum |
|--------|--------|---------|
| Directories tracked | 10,000 | 50,000 |
| Bookmarks | 100 | 500 |
| History entries | 1,000 | 10,000 |
| Search paths | 10 | 50 |
| Concurrent operations | 5 | 10 |

### 5.3 Compatibility Requirements

**Shells:**
- ✅ bash 4.0+
- ✅ bash 3.2+ (macOS default)
- ✅ zsh 5.0+

**Operating Systems:**
- ✅ macOS 10.15+
- ✅ Linux (Ubuntu, Debian, RHEL, Arch)
- ⏳ WSL2 (Windows Subsystem for Linux)
- ❌ Windows CMD/PowerShell (out of scope)

**Optional Dependencies:**
- fd (file search enhancement)
- ripgrep (content search enhancement)
- fzf (interactive selection enhancement)
- bat (syntax highlighting enhancement)
- exa/eza (directory listing enhancement)

### 5.4 Data Storage

**Files:**
```
~/.goto_stack          # Navigation stack (back command)
~/.goto_history        # Visit history (recent command)
~/.goto_bookmarks      # Saved bookmarks
~/.goto_frecency       # Frecency scores
~/.goto_cache/         # Performance caches
└── dir_listing.cache  # Directory listings
└── git_repos.cache    # Git repository info
└── file_index.cache   # File search index
```

**Format:** Pipe-delimited plain text
- Human-readable
- Easy to backup/restore
- Simple to parse
- No database dependencies

---

## 6. Success Metrics & KPIs

### 6.1 Adoption Metrics

**Target (12 months post-v1.0):**
- **Users:** 10,000+ active users
- **Stars:** 2,000+ GitHub stars
- **Retention:** 70% monthly active users
- **Growth:** 20% month-over-month

### 6.2 Performance Metrics

**Target (v1.0):**
- **Speed:** 95% of operations < 500ms
- **Accuracy:** 90% of fuzzy matches correct
- **Reliability:** 99.9% uptime (no crashes)

### 6.3 User Satisfaction Metrics

**Target:**
- **NPS Score:** 50+ (Excellent)
- **User Rating:** 4.5+ / 5.0
- **Time Saved:** 30+ minutes per day
- **Feature Discovery:** 5+ features in first week

### 6.4 Comparison Metrics

**vs. Current Workflow:**
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Dir changes/day | 50 | 50 | Same |
| Seconds per change | 15s | 5s | 67% faster |
| Daily time saved | 0 | 8 min | ✅ |
| File finds/day | 20 | 20 | Same |
| Seconds per find | 30s | 5s | 83% faster |
| Daily time saved | 0 | 8 min | ✅ |
| **Total Daily Savings** | **0** | **16+ min** | **✅** |

---

## 7. Go-to-Market Strategy

### 7.1 Target Audience

**Primary:**
- Software developers (80%)
- DevOps/SRE engineers (15%)
- System administrators (5%)

**Characteristics:**
- Work in terminal 4+ hours per day
- Manage multiple projects
- Navigate deep directory structures
- Value productivity tools
- Active in developer communities

### 7.2 Distribution Channels

**Installation:**
1. GitHub (primary)
2. Homebrew (macOS)
3. Package managers (apt, yum, pacman)
4. oh-my-zsh plugin
5. dotfiles managers

**Promotion:**
1. Hacker News launch
2. Reddit (r/commandline, r/programming, r/bash)
3. Dev.to articles
4. YouTube demos
5. Twitter/X threads
6. GitHub awesome lists

### 7.3 Monetization (Optional)

**Free Forever:**
- All core features
- Community support
- Open source

**Premium (Optional):**
- Cloud sync (bookmarks, workspaces)
- Team features (shared configs)
- Priority support
- Advanced analytics

---

## 8. Development Plan

### 8.1 Team & Roles

**Current:**
- Developer: Manu Tej + Claude Code
- Designer: Community feedback
- Testing: Automated + beta users

**Future (if scaling):**
- Lead developer (full-time)
- UX designer (part-time)
- Technical writer (part-time)
- Community manager (part-time)

### 8.2 Timeline

```
Current: v0.3.0 ──────────────────────┐
                                      │
Month 1: v0.4.0 (Quick Wins) ─────────┤
  • Fuzzy matching                    │
  • Tab completion                    │
  • Frecency                          │
  • Git-aware                         │
                                      │
Month 2-3: v0.5.0 (File Search) ──────┤
  • gf command                        │
  • gs command                        │
  • j command                         │
  • fzf integration                   │
                                      │
Month 4-5: v0.6.0 (Workflows) ────────┤
  • Project detection                 │
  • Smart suggestions                 │
  • Beautiful output                  │
                                      │
Month 6: v1.0.0 (Power Features) ─────┘
  • Workspaces
  • Plugin system
  • Release!
```

### 8.3 Budget (if needed)

**$0 Budget (Current):**
- Open source development
- Community contributions
- Free hosting (GitHub)

**Small Budget ($100/month):**
- Better documentation site
- Video hosting
- Domain name
- Analytics

**Medium Budget ($1000/month):**
- Full-time development
- Professional design
- Marketing campaigns
- Swag/stickers

---

## 9. Risk Assessment

### 9.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Performance degradation | Medium | High | Benchmarking, caching |
| Shell compatibility | Low | Medium | Extensive testing |
| Data corruption | Low | High | Backup, validation |
| Security vulnerabilities | Low | High | Code review, audits |

### 9.2 Market Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Low adoption | Medium | High | Marketing, features |
| Competition | Medium | Medium | Differentiation |
| User churn | Low | Medium | Quality, support |

### 9.3 Mitigation Strategies

**Quality Assurance:**
- Comprehensive test suite
- Beta testing program
- Bug bounty (if funded)
- Regular security audits

**User Retention:**
- Excellent documentation
- Active community support
- Regular feature updates
- User feedback integration

---

## 10. Conclusion & Next Steps

### 10.1 Summary

unix-goto has a **solid foundation** (v0.3.0) and a **clear path** to becoming indispensable:

**Current Strengths:**
✅ Production-ready codebase
✅ Natural language support (unique)
✅ Comprehensive features
✅ Great documentation

**Critical Gaps:**
❌ Fuzzy matching
❌ Tab completion
❌ File search
❌ Smart suggestions

**Path Forward:**
→ Implement Phase 1 (v0.4.0) - Quick wins
→ Add file search (v0.5.0) - Killer features
→ Polish workflows (v0.6.0) - Professional grade
→ Launch v1.0 - Indispensable tool

### 10.2 Immediate Next Steps

**Week 1:**
1. ✅ Review this specification
2. ✅ Prioritize Phase 1 features
3. ⏳ Create feature branch
4. ⏳ Start fuzzy matching implementation

**Week 2-4:**
- Implement v0.4.0 features
- Write tests
- Update documentation
- Release v0.4.0

**Month 2-6:**
- Continue roadmap
- Build community
- Iterate based on feedback
- Launch v1.0

### 10.3 Success Criteria (v1.0)

**Indispensable = users can't work without it**

Measured by:
- ✅ Used 20+ times per day
- ✅ Saves 30+ minutes per day
- ✅ Reduces frustration significantly
- ✅ Becomes part of muscle memory
- ✅ Shared with colleagues
- ✅ Featured in productivity articles

---

## Appendix

### A. User Personas

**Persona 1: Full-Stack Developer**
- Name: Alex
- Age: 28
- Context: Works on 5+ projects simultaneously
- Pain: Constantly switching between repos
- Goal: Navigate instantly without thinking

**Persona 2: DevOps Engineer**
- Name: Jordan
- Age: 34
- Context: Manages 50+ servers and configs
- Pain: Deep nested directory structures
- Goal: Find files/dirs across multiple repos

**Persona 3: Open Source Contributor**
- Name: Sam
- Age: 25
- Context: Contributes to many projects
- Pain: Remembering where everything is
- Goal: Quick jumps to any project

### B. Competitive Analysis Detail

[Detailed feature comparison matrix]

### C. Technical Architecture Diagrams

[System architecture diagrams]

### D. User Research Data

[Survey results, interview transcripts]

---

**Document Version:** 1.0
**Last Updated:** 2025-11-10
**Next Review:** After v0.4.0 release
**Maintained By:** Manu Tej + Claude Code
