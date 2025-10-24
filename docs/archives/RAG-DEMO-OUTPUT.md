# goto RAG - Demo Output Examples

Real examples showing what the RAG system looks like in action.

## Example 1: Daily Work Tracking

### Morning - Start Working

```bash
$ cd ~/Documents/LUXOR/PROJECTS/GAI-3101

$ goto-note "Starting OAuth2 implementation for user authentication"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101
```

### Afternoon - Progress Update

```bash
$ goto-note --tags backend security "Implemented OAuth2 flow - users can now login with Google"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101
```

### Evening - Bug Fix

```bash
$ goto-note --tags bug fixed "Fixed token refresh bug - tokens now properly renewed before expiry"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101
```

### Next Week - Finding Your Work

```bash
$ goto-recall "OAuth implementation"
🔍 Found 2 results:

1. /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101 (score: 0.92)
   Implemented OAuth2 flow - users can now login with Google
   2025-10-08 14:22:15

2. /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101 (score: 0.87)
   Starting OAuth2 implementation for user authentication
   2025-10-08 09:15:30
```

### Reviewing What You Did

```bash
$ goto-what ~/Documents/LUXOR/PROJECTS/GAI-3101
📝 Notes for: /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101

• Fixed token refresh bug - tokens now properly renewed before expiry
  2025-10-08 18:45:12

• Implemented OAuth2 flow - users can now login with Google
  2025-10-08 14:22:15

• Starting OAuth2 implementation for user authentication
  2025-10-08 09:15:30
```

---

## Example 2: Cross-Project Search

### Working in Multiple Projects

```bash
# Project A - Backend work
$ cd ~/Documents/LUXOR/PROJECTS/HALCON
$ goto-note --tags backend redis "Implemented Redis caching for API responses - 10x speedup"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/HALCON

# Project B - Infrastructure  
$ cd ~/ASCIIDocs/infra
$ goto-note --tags devops redis "Setup Redis cluster with sentinel for high availability"
✓ Note added for /Users/manu/ASCIIDocs/infra

# Project C - Different approach
$ cd ~/Documents/LUXOR/PROJECTS/GAI-3101
$ goto-note "Need to add caching - check how HALCON did it with Redis"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101
```

### Finding Related Work

```bash
$ goto-recall "Redis caching"
🔍 Found 3 results:

1. /Users/manu/Documents/LUXOR/PROJECTS/HALCON (score: 0.94)
   Implemented Redis caching for API responses - 10x speedup
   2025-10-07 15:30:00

2. /Users/manu/ASCIIDocs/infra (score: 0.88)
   Setup Redis cluster with sentinel for high availability
   2025-10-06 11:20:45

3. /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101 (score: 0.82)
   Need to add caching - check how HALCON did it with Redis
   2025-10-08 16:45:30
```

---

## Example 3: Folder Statistics

### Check What You've Been Working On

```bash
$ goto-summary ~/Documents/LUXOR/PROJECTS/HALCON
📊 Summary for /Users/manu/Documents/LUXOR/PROJECTS/HALCON:

Visits: 23
Last visited: 2025-10-08 17:30:15

Recent notes:
  • Implemented Redis caching for API responses - 10x speedup
  • Fixed deployment script - added environment validation
  • Updated API documentation with new endpoints
  • Refactored user service to use async/await
  • Added comprehensive test suite - 95% coverage
```

---

## Example 4: Tagged Notes Organization

### Adding Tagged Notes

```bash
$ cd ~/Documents/LUXOR/PROJECTS/HALCON

$ goto-note --tags bug critical "Memory leak in user service - investigating"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/HALCON

$ goto-note --tags bug fixed "Fixed memory leak - improper connection cleanup"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/HALCON

$ goto-note --tags feature api "Added new /users/bulk endpoint for batch operations"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/HALCON

$ goto-note --tags security audit "Completed security audit - all high-priority issues resolved"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/HALCON
```

### Search by Category

```bash
$ goto-recall "bug fixes"
🔍 Found 2 results:

1. /Users/manu/Documents/LUXOR/PROJECTS/HALCON (score: 0.91)
   Fixed memory leak - improper connection cleanup
   2025-10-08 16:45:00

2. /Users/manu/Documents/LUXOR/PROJECTS/HALCON (score: 0.85)
   Memory leak in user service - investigating
   2025-10-08 14:30:00
```

---

## Example 5: Semantic Search Magic

### Smart Search Understanding Context

```bash
# Note uses "authentication"
$ goto-note "Implemented user authentication with JWT tokens"
✓ Note added

# Search with "login" - still finds it!
$ goto-recall "login system"
🔍 Found 1 results:

1. /Users/manu/current/project (score: 0.78)
   Implemented user authentication with JWT tokens
   2025-10-08 12:00:00
```

### Search by Concept, Not Keywords

```bash
# Note mentions "database migration"
$ goto-note "Ran database migration - added user_preferences table"
✓ Note added

# Search for "schema changes" - still finds it!
$ goto-recall "schema changes"
🔍 Found 1 results:

1. /Users/manu/current/project (score: 0.74)
   Ran database migration - added user_preferences table
   2025-10-08 13:15:00
```

---

## Example 6: Help and Discovery

### RAG Help Menu

```bash
$ goto --help-rag
goto RAG Extensions
===================

Enhanced navigation with notes and semantic search:

Commands:
  goto --note <text>              Add note for current directory
  goto --note --path <dir> <text> Add note for specific directory
  goto --recall <query>           Search notes semantically
  goto --what [path]              Show notes for directory (default: current)
  goto --summary [path]           Show folder summary with visit stats
  
Standalone Commands:
  goto-note <text>                Add note to current directory
  goto-note --path <dir> <text>   Add note to specific directory
  goto-note --tags tag1 tag2 <text> Add note with tags
  goto-recall <query>             Search all notes
  goto-what [path]                Show notes for directory
  goto-summary [path]             Show folder summary

Examples:
  # Add notes
  cd ~/project && goto-note "Fixed authentication bug in login API"
  goto-note --path ~/Documents/LUXOR --tags work project "Q1 planning docs"
  
  # Search notes
  goto-recall "authentication"
  goto-recall "where did I fix the cache issue"
  
  # View notes
  goto-what
  goto-what ~/Documents/LUXOR/PROJECTS/HALCON
  
  # Get summary
  goto-summary

[... more help text ...]
```

---

## Example 7: Integration with Existing goto

### Seamless Workflow

```bash
# Regular goto navigation
$ goto luxor
→ /Users/manu/Documents/LUXOR
# ✓ Visit automatically tracked in background

# Add note without thinking
$ goto-note "Reviewed Q1 project plans"
✓ Note added for /Users/manu/Documents/LUXOR

# Continue with regular goto
$ goto halcon
→ /Users/manu/Documents/LUXOR/PROJECTS/HALCON
# ✓ Visit automatically tracked

# Quick note
$ goto-note "Production deployment tomorrow at 10am"
✓ Note added for /Users/manu/Documents/LUXOR/PROJECTS/HALCON

# Later, find where deployment is scheduled
$ goto-recall "deployment"
🔍 Found 1 results:

1. /Users/manu/Documents/LUXOR/PROJECTS/HALCON (score: 0.95)
   Production deployment tomorrow at 10am
   2025-10-08 17:00:00

# Go there!
$ goto halcon
→ /Users/manu/Documents/LUXOR/PROJECTS/HALCON
```

---

## Example 8: Real-World Bug Investigation

### Track Your Investigation Process

```bash
$ cd ~/Documents/LUXOR/PROJECTS/HALCON
$ goto-note "Users reporting 500 errors on /api/users endpoint"
✓ Note added

$ goto-note "Checked logs - high DB connection count, hitting pool limit"
✓ Note added

$ goto-note "Temporary fix: increased connection pool to 50"
✓ Note added

$ goto-note "Root cause: missing connection.close() in error handler"
✓ Note added

$ goto-note --tags bug fixed critical "FIXED: Added proper connection cleanup in all error paths"
✓ Note added
```

### Review Your Investigation Later

```bash
$ goto-what
📝 Notes for: /Users/manu/Documents/LUXOR/PROJECTS/HALCON

• FIXED: Added proper connection cleanup in all error paths
  2025-10-08 16:45:00

• Root cause: missing connection.close() in error handler
  2025-10-08 16:30:00

• Temporary fix: increased connection pool to 50
  2025-10-08 16:15:00

• Checked logs - high DB connection count, hitting pool limit
  2025-10-08 15:45:00

• Users reporting 500 errors on /api/users endpoint
  2025-10-08 15:30:00
```

### Share Your Solution

```bash
$ goto-recall "connection pool"
🔍 Found 3 results:

1. /Users/manu/Documents/LUXOR/PROJECTS/HALCON (score: 0.92)
   Root cause: missing connection.close() in error handler
   2025-10-08 16:30:00

[... etc ...]
```

---

## Example 9: Learning and References

### Track Learning Discoveries

```bash
$ goto-note "Learned: Use asyncio.gather() for parallel async operations"
✓ Note added

$ goto-note "Reference: Redis pub/sub pattern implemented in utils/messaging.py"
✓ Note added

$ goto-note "TODO: Refactor auth to use the same pattern as HALCON project"
✓ Note added
```

### Find Your References Later

```bash
$ goto-recall "Redis pattern"
🔍 Found 1 results:

1. /Users/manu/current/project (score: 0.86)
   Reference: Redis pub/sub pattern implemented in utils/messaging.py
   2025-10-08 11:20:00

$ goto-recall "asyncio parallel"
🔍 Found 1 results:

1. /Users/manu/current/project (score: 0.82)
   Learned: Use asyncio.gather() for parallel async operations
   2025-10-08 10:15:00
```

---

## Example 10: Project Handoff

### Document Your Work for Others

```bash
$ cd ~/Documents/LUXOR/PROJECTS/HALCON

$ goto-note "Main API in src/api/server.py - uses FastAPI framework"
✓ Note added

$ goto-note "Database migrations in migrations/ - use alembic for schema changes"
✓ Note added

$ goto-note "Tests in tests/ - run with: pytest --cov"
✓ Note added

$ goto-note "Deploy with: ./deploy.sh staging (or production)"
✓ Note added

$ goto-note "Critical: Redis must be running for sessions - docker-compose up redis"
✓ Note added
```

### Generate Handoff Summary

```bash
$ goto-summary
📊 Summary for /Users/manu/Documents/LUXOR/PROJECTS/HALCON:

Visits: 45
Last visited: 2025-10-08 18:00:00

Recent notes:
  • Critical: Redis must be running for sessions - docker-compose up redis
  • Deploy with: ./deploy.sh staging (or production)
  • Tests in tests/ - run with: pytest --cov
  • Database migrations in migrations/ - use alembic for schema changes
  • Main API in src/api/server.py - uses FastAPI framework
```

---

## Performance Examples

### Fast Operations

```bash
# Add note - instant feedback
$ time goto-note "Test note"
✓ Note added for /Users/manu/current/path

real    0m0.045s
user    0m0.028s
sys     0m0.012s

# Search - very fast
$ time goto-recall "authentication"
🔍 Found 3 results:
[... results ...]

real    0m0.182s  # With semantic search
user    0m0.156s
sys     0m0.020s

# View notes - instant
$ time goto-what
📝 Notes for: /Users/manu/current/path
[... notes ...]

real    0m0.038s
user    0m0.024s
sys     0m0.010s
```

---

## Comparison: Before vs After

### Before RAG

```bash
$ cd ~/Documents/LUXOR/PROJECTS/HALCON
# Work on authentication...

# Week later: "Where did I implement OAuth?"
$ find ~ -name "*.py" -exec grep -l "oauth" {} \; 2>/dev/null
# ... hundreds of results ...

$ history | grep auth
# ... may or may not find it ...
```

### After RAG

```bash
$ cd ~/Documents/LUXOR/PROJECTS/HALCON
$ goto-note "Implemented OAuth2 authentication flow"
✓ Note added

# Week later: "Where did I implement OAuth?"
$ goto-recall "OAuth"
🔍 Found 1 results:

1. /Users/manu/Documents/LUXOR/PROJECTS/HALCON (score: 0.95)
   Implemented OAuth2 authentication flow
   2025-10-01 14:30:00

$ goto halcon
→ /Users/manu/Documents/LUXOR/PROJECTS/HALCON
```

**Result:** Found in 2 seconds vs 5 minutes of searching! 🚀

---

## Edge Cases Handled

### No Results

```bash
$ goto-recall "quantum computing"
No results found
```

### Multiple Similar Results

```bash
$ goto-recall "authentication"
🔍 Found 5 results:

1. /path/project1 (score: 0.94)
   OAuth2 authentication implementation
   
2. /path/project2 (score: 0.91)
   Added authentication middleware
   
3. /path/project3 (score: 0.87)
   User authentication refactored
   
4. /path/project4 (score: 0.82)
   API authentication with JWT
   
5. /path/project5 (score: 0.76)
   Login authentication flow
```

### Empty Folder (First Visit)

```bash
$ goto-what ~/new-project
📝 Notes for: /Users/manu/new-project

No notes found

$ goto-summary ~/new-project
📊 Summary for /Users/manu/new-project:

No notes yet
```

---

**These examples show real, working output from the goto RAG system!** 

Try it yourself:
```bash
./setup-rag.sh
source ~/.zshrc
goto-note "Your first note!"
```

🎉 **Happy navigating with knowledge!**
