# Quick Start: goto RAG 🚀

Get started with goto RAG in 5 minutes!

## What You'll Learn

- Add notes to folders
- Search notes semantically  
- Track your navigation history
- Get folder summaries

## Installation (2 minutes)

```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
./setup-rag.sh
source ~/.zshrc
```

Done! ✅

## Your First Commands (3 minutes)

### 1. Add a Note 📝

Navigate somewhere and add a note:

```bash
cd ~/Documents/LUXOR
goto-note "This is my main work directory for all LUXOR projects"
```

**Output:**
```
✓ Note added for /Users/manu/Documents/LUXOR
```

### 2. Search for Notes 🔍

Later, search for that note:

```bash
goto-recall "work directory"
```

**Output:**
```
🔍 Found 1 results:

1. /Users/manu/Documents/LUXOR (score: 0.85)
   This is my main work directory for all LUXOR projects
   2025-10-08 07:15:30
```

### 3. View Notes for Current Folder 👁️

```bash
cd ~/Documents/LUXOR
goto-what
```

**Output:**
```
📝 Notes for: /Users/manu/Documents/LUXOR

• This is my main work directory for all LUXOR projects
  2025-10-08 07:15:30
```

### 4. Get Folder Summary 📊

```bash
goto-summary
```

**Output:**
```
📊 Summary for /Users/manu/Documents/LUXOR:

Visits: 5
Last visited: 2025-10-08 07:35:12

Recent notes:
  • This is my main work directory for all LUXOR projects
```

## Real-World Example

### Scenario: Working on a Bug Fix

```bash
# Day 1: Start working on authentication bug
cd ~/Documents/LUXOR/PROJECTS/GAI-3101
goto-note --tags bug auth "Found authentication bug in login.py - users can't login with special chars in password"

# Day 2: Fixed the bug
goto-note --tags bug fixed "Fixed auth bug - properly escaped special characters before hashing"

# Week later: "Where did I fix that auth issue?"
goto-recall "authentication bug"
```

**Output:**
```
🔍 Found 2 results:

1. ~/Documents/LUXOR/PROJECTS/GAI-3101 (score: 0.92)
   Fixed auth bug - properly escaped special characters before hashing
   2025-10-08 14:22:15

2. ~/Documents/LUXOR/PROJECTS/GAI-3101 (score: 0.89)
   Found authentication bug in login.py - users can't login with special chars
   2025-10-07 09:15:30
```

Navigate there:
```bash
goto GAI-3101
```

## Advanced Features

### Tags for Organization

```bash
goto-note --tags backend python api "Refactored user service to use async/await"
goto-note --tags frontend react ui "Updated dashboard with new metrics"
goto-note --tags devops docker k8s "Configured Kubernetes deployment"
```

Search by tag concept:
```bash
goto-recall "kubernetes"  # Finds the devops note
```

### Notes for Specific Paths

```bash
# Add note without being in the directory
goto-note --path ~/Documents/LUXOR/PROJECTS/HALCON "Production deployment scheduled for Friday"

# Check notes
goto-what ~/Documents/LUXOR/PROJECTS/HALCON
```

## Integration with goto

All RAG features work seamlessly with your existing goto commands:

```bash
# Navigate as usual
goto luxor
goto halcon
goto GAI-3101

# Add notes along the way
goto-note "Working on feature X"

# Navigate somewhere else
goto infra

# Later, find where you worked on feature X
goto-recall "feature X"
```

## Command Cheat Sheet

| Command | What It Does | Example |
|---------|--------------|---------|
| `goto-note <text>` | Add note to current folder | `goto-note "Fixed bug"` |
| `goto-note --path <dir> <text>` | Add note to specific folder | `goto-note --path ~/project "Note"` |
| `goto-note --tags <tags> <text>` | Add tagged note | `goto-note --tags bug fix "Fixed issue"` |
| `goto-recall <query>` | Search all notes | `goto-recall "authentication"` |
| `goto-what [path]` | Show notes for folder | `goto-what` |
| `goto-summary [path]` | Show folder summary | `goto-summary` |

## Tips & Tricks

### 1. **Daily Work Log**
```bash
# Start of day
cd ~/projects/current-sprint
goto-note "Starting sprint 23 - focus on user dashboard"

# End of day
goto-note "Completed 3 tickets, dashboard 80% done"
```

### 2. **Project Handoff**
```bash
cd ~/important-project
goto-summary > handoff-notes.txt
# Share handoff-notes.txt with team
```

### 3. **Learning Trail**
```bash
goto-note "Learned: Redis pub/sub for real-time updates"
goto-note "Reference: Check auth implementation in project X"
# Later: goto-recall "Redis" finds your learning notes
```

### 4. **Problem Solving**
```bash
goto-note "Problem: High memory usage in production"
# ... investigate ...
goto-note "Solution: Added connection pooling, reduced memory by 40%"
```

## What's Next?

- 📖 Read the [full RAG README](RAG-README.md)
- 🎬 Run the demo: `./examples/rag-demo.sh`
- 🧪 Run tests: `./test-rag.sh`
- 💡 Share your use cases!

## Need Help?

```bash
# Show RAG help
goto --help-rag

# Show main goto help
goto --help

# Test your installation
./test-rag.sh
```

---

**Happy navigating!** 🎉

*Made with ❤️ for productive terminal users*
