# unix-goto CONSTITUTION

**Version:** 1.0
**Date:** 2025-11-12
**Status:** Living Document

---

## 🎯 Project Purpose

**Mission:** Make filesystem navigation in the terminal as intuitive and fast as IDE navigation, while maintaining Unix philosophy simplicity.

**Vision:** unix-goto becomes the ONE tool developers reach for when navigating filesystems in the terminal.

---

## 🏛️ Core Principles (Governing Rules)

### 1. Simplicity First
- **Rule:** Choose simple solutions over clever ones
- **Application:** If a feature requires >100 lines, question if it's needed
- **Example:** Fuzzy matching uses substring, not Levenshtein distance
- **Test:** Can a junior developer understand it in 5 minutes?

### 2. No Over-Engineering
- **Rule:** Implement only what users need today, not what they might need tomorrow
- **Application:** No premature optimization, no unused features
- **Example:** Phase 1 has 3 features, not 10
- **Test:** Every line of code must solve a real user problem

### 3. Unix Philosophy
- **Rule:** Do one thing well, compose with other tools
- **Application:** Navigation only, not file management
- **Example:** Works with cd, find, grep - doesn't replace them
- **Test:** Can it be used in pipes and scripts?

### 4. User Experience > Feature Count
- **Rule:** 3 excellent features > 10 mediocre ones
- **Application:** Polish what exists before adding more
- **Example:** Fuzzy matching must be fast (<500ms), not just functional
- **Test:** Would users recommend it to colleagues?

### 5. Progressive Enhancement
- **Rule:** Core works everywhere, enhancements use available tools
- **Application:** Works in pure bash, better with fd/fzf/rg
- **Example:** Tab completion works in bash 3.2+ (macOS default)
- **Test:** Can it run on a 10-year-old system?

### 6. Testability Required
- **Rule:** If it can't be tested, it can't be released
- **Application:** Every feature needs automated tests
- **Example:** 44 test cases for fuzzy matching
- **Test:** Does CI/CD pass?

### 7. Performance Matters
- **Rule:** Sub-second response time for all operations
- **Application:** Benchmark and optimize critical paths
- **Example:** Fuzzy search must be <500ms for 100 dirs
- **Test:** Does it feel instant to users?

### 8. Backward Compatibility
- **Rule:** Don't break existing workflows
- **Application:** New features are additive, not breaking
- **Example:** v0.4.0 adds fuzzy, doesn't change exact match
- **Test:** Do v0.3.0 workflows still work?

---

## 🚫 Anti-Patterns (What We Avoid)

### 1. Feature Creep
**Don't:** Add features because they're cool
**Do:** Add features because users need them
**Example:** No GUI, no TUI, no config file (yet) - just CLI

### 2. Complex Algorithms
**Don't:** Use Levenshtein distance for fuzzy matching
**Do:** Use simple substring matching
**Rationale:** 80% of value, 20% of complexity

### 3. External Dependencies
**Don't:** Require installation of tools
**Do:** Work with pure bash, enhance if tools available
**Example:** Works without fzf, better with fzf

### 4. Configuration Complexity
**Don't:** Require configuration files
**Do:** Work perfectly with defaults
**Example:** Search paths are sensible defaults, not mandatory config

### 5. Premature Optimization
**Don't:** Optimize before measuring
**Do:** Measure, identify bottleneck, then optimize
**Example:** Only cache if proven slow

### 6. Test Theater
**Don't:** Surface-level tests that don't catch bugs
**Do:** Deep tests including edge cases and security
**Example:** Test command injection, not just happy path

---

## 📐 Development Standards

### Code Standards
- **Shell:** Bash 3.2+ compatible (macOS default)
- **Style:** Follow existing patterns, consistent indentation
- **Comments:** Explain why, not what
- **Functions:** Start with `__goto_` prefix for internal functions
- **Error Handling:** Always check return codes: `cd "$dir" || return 1`

### Testing Standards
- **Coverage:** Minimum 15 test cases per feature
- **Types:** Unit, integration, edge cases, performance, security
- **Automation:** All tests must be automated and idempotent
- **Speed:** Test suite completes in <2 minutes
- **Documentation:** Every test has clear name and comments

### Documentation Standards
- **README:** User-focused, examples-first
- **Code Comments:** Why this code exists, not what it does
- **Specs:** Testable acceptance criteria, not aspirations
- **Examples:** Real-world workflows, not toy examples

### Release Standards
- **Version:** Semantic versioning (MAJOR.MINOR.PATCH)
- **Changelog:** Every release has detailed changelog
- **Tests:** 100% passing before release
- **Performance:** Meets all performance requirements
- **Review:** Code review or self-review before merge

---

## 🎯 Success Metrics

### User Success
- **Time Saved:** 30+ minutes per day
- **Adoption:** Used 20+ times per day
- **Satisfaction:** NPS score 50+
- **Retention:** 70% monthly active users

### Technical Success
- **Performance:** 95% of operations <500ms
- **Reliability:** 99.9% uptime (no crashes)
- **Quality:** Grade A code quality
- **Test Coverage:** 65+ automated test cases

### Project Success
- **Users:** 10,000+ active users (12 months post v1.0)
- **Stars:** 2,000+ GitHub stars
- **Growth:** 20% month-over-month
- **Community:** Active contributors and discussions

---

## 🔄 Decision Framework

When evaluating a new feature or change, ask:

1. **Does it solve a real user problem?** (Not just cool tech)
2. **Is it simple?** (Can junior dev understand it?)
3. **Does it follow Unix philosophy?** (Composable, single purpose)
4. **Can we test it?** (Automated tests required)
5. **Does it perform well?** (Sub-second response)
6. **Is it backward compatible?** (Doesn't break existing workflows)
7. **Is it worth maintaining?** (Long-term value)

**If 6-7 YES:** Implement it
**If 4-5 YES:** Consider carefully
**If <4 YES:** Reject it

---

## 📋 Phase Approval Criteria

Each phase must meet these before moving to next:

### Phase Completion Requirements
- ✅ All features implemented
- ✅ All acceptance criteria met
- ✅ All tests passing
- ✅ Performance requirements met
- ✅ Documentation complete
- ✅ Code reviewed
- ✅ Released and tagged
- ✅ User feedback collected

### Phase Sign-Off
- **Developer:** Code complete and tests passing
- **Reviewer:** Code quality and specs compliance verified
- **User(s):** Feedback indicates value delivered

---

## 🔧 Technical Governance

### Architecture Principles
- **Modularity:** Features in separate lib/*.sh files
- **Composition:** Functions compose cleanly
- **State:** Minimize state, use files when needed
- **Errors:** Fail gracefully, clear messages

### File Structure
```
unix-goto/
├── bin/              # Executable scripts (Claude AI resolver)
├── lib/              # Core functions (modular)
├── completions/      # Shell completions
├── tests/            # Automated tests
├── docs/             # Specifications and guides
└── install.sh        # Installation script
```

### Dependency Policy
- **Required:** None (pure bash)
- **Optional:** fd, rg, fzf, bat (progressive enhancement)
- **Principle:** Core works everywhere, enhancements optional

---

## 🌍 Community Principles

### Open Source Values
- **Transparency:** Development happens in public
- **Collaboration:** Contributors welcome
- **Respect:** Kind, constructive feedback
- **Learning:** Help others grow

### Contribution Standards
- **Code:** Follows constitution principles
- **Tests:** Required for all features
- **Docs:** Update with code changes
- **Review:** Patient, educational feedback

---

## 📚 References

**Key Documents:**
- ROADMAP.md - Product vision and phases
- SUCCESS-CRITERIA.md - Feature specifications
- PHASE-1-IMPLEMENTATION.md - Technical implementation
- CODE-REVIEW.md - Quality standards

**External Inspiration:**
- Unix Philosophy (Doug McIlroy)
- The Art of Unix Programming (Eric Raymond)
- Worse is Better (Richard Gabriel)

---

## ✏️ Amendment Process

This constitution is a living document:

1. **Propose:** Create issue with proposed change
2. **Discuss:** Community discussion (if applicable)
3. **Decide:** Maintainer approval
4. **Document:** Update this file
5. **Announce:** Communicate change

**Last Updated:** 2025-11-12
**Maintained By:** Manu Tej + Community
