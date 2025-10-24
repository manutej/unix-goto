# goto RAG Extension 🧠

Transform `goto` into a smart knowledge base for your filesystem! Add notes, search semantically, and never forget where you worked on that feature.

## What is RAG?

**RAG (Retrieval-Augmented Generation)** combines:
- **Local knowledge base** (your notes and context)
- **Semantic search** (AI-powered understanding)
- **Context retrieval** (remember what you did where)

## Features

### 📝 Add Notes to Folders
```bash
# Note in current directory
goto-note "Fixed authentication bug in login API"

# Note in specific directory
goto-note --path ~/Documents/LUXOR "Q1 planning documents"

# Note with tags
goto-note --tags backend api python "Refactored user service"
```

### 🔍 Semantic Search
```bash
# Find where you worked on something
goto-recall "authentication bug"

# Search understands context
goto-recall "where did I fix caching"
# → Finds notes about cache fixes, even if exact words differ

# Find by concept
goto-recall "API documentation"
```

### 📊 Folder Summaries
```bash
# Summary of current folder
goto-summary

# Summary of specific folder
goto-summary ~/Documents/LUXOR/PROJECTS/HALCON

# Shows:
# - Visit count and last visited
# - Recent notes
# - Tags and description
```

### 🕐 Automatic Visit Tracking
Every time you navigate with `goto`, it automatically tracks:
- When you visited
- How many times you've been there
- Navigation patterns

## Installation

### Quick Setup
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
./setup-rag.sh
```

The script will:
1. ✅ Check Python 3 installation
2. 📦 Optionally install semantic search dependencies
3. 🔧 Make scripts executable
4. 📝 Offer to add to your `.zshrc`

### Manual Setup

1. **Install Python dependencies** (optional but recommended):
   ```bash
   pip3 install sentence-transformers numpy
   ```

2. **Add to `.zshrc`**:
   ```bash
   echo 'source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/rag-command.sh' >> ~/.zshrc
   source ~/.zshrc
   ```

## Usage Examples

### Example 1: Track Your Work
```bash
# Start working on a project
cd ~/Documents/LUXOR/PROJECTS/HALCON
goto-note "Started implementing OAuth2 flow"

# Later, in another project
goto-note "Need to reference HALCON OAuth implementation"

# Even later, find where you implemented OAuth
goto-recall "OAuth implementation"
# → Shows both notes with paths
```

### Example 2: Tag Projects
```bash
# Tag different types of work
goto-note --tags frontend react "New dashboard component"
cd ../backend
goto-note --tags backend api "User authentication endpoint"

# Search by concept
goto-recall "authentication"
# → Finds both frontend and backend auth work
```

### Example 3: Project Context
```bash
# Check what you last did in a folder
goto-what ~/Documents/LUXOR/PROJECTS/HALCON

# Output:
# 📝 Notes for: /Users/manu/Documents/LUXOR/PROJECTS/HALCON
# 
# • Started implementing OAuth2 flow
#   2025-10-08 07:15:30
# 
# • Fixed login redirect bug
#   2025-10-05 14:22:15
```

### Example 4: Visit Statistics
```bash
goto-summary ~/Documents/LUXOR/PROJECTS/HALCON

# Output:
# 📊 Summary for /Users/manu/Documents/LUXOR/PROJECTS/HALCON:
# 
# Visits: 45
# Last visited: 2025-10-08 07:15:30
# 
# Recent notes:
#   • Started implementing OAuth2 flow
#   • Fixed login redirect bug
#   • Updated deployment docs
```

## Commands Reference

### Note Management
| Command | Description |
|---------|-------------|
| `goto-note <text>` | Add note to current directory |
| `goto-note --path <dir> <text>` | Add note to specific directory |
| `goto-note --tags <tag1> <tag2> <text>` | Add note with tags |

### Search & Retrieval
| Command | Description |
|---------|-------------|
| `goto-recall <query>` | Semantic search across all notes |
| `goto-what [path]` | Show notes for directory (default: current) |
| `goto-summary [path]` | Show folder summary with stats |

### Integration with goto
```bash
# All existing goto commands work
goto luxor
goto halcon
goto GAI-3101

# Plus new RAG flags
goto --note "your note"
goto --recall "search query"
goto --what
goto --summary
goto --help-rag
```

## How It Works

### Architecture
```
┌─────────────────────────────────────────────────┐
│                goto Command                     │
└─────────────────┬───────────────────────────────┘
                  │
      ┌───────────┴───────────┐
      │                       │
┌─────▼──────┐        ┌──────▼─────┐
│ Navigation │        │    RAG     │
│  (existing)│        │ (new layer)│
└────────────┘        └──────┬─────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌────▼────┐  ┌─────▼──────┐
        │  SQLite   │  │Embedding│  │   Search   │
        │    DB     │  │  Model  │  │   Engine   │
        └───────────┘  └─────────┘  └────────────┘
```

### Data Storage
- **Database**: `~/.goto_rag.db` (SQLite)
- **Notes**: Text notes with timestamps and tags
- **Embeddings**: Vector representations for semantic search
- **Metadata**: Visit tracking, folder descriptions

### Semantic Search (Optional)
If `sentence-transformers` is installed:
- Uses `all-MiniLM-L6-v2` model (small, fast, local)
- Creates embeddings for notes
- Finds similar notes by meaning, not just keywords
- Falls back to keyword search if unavailable

## Advanced Usage

### Custom Scripts Integration
```python
#!/usr/bin/env python3
from goto_rag import GotoRAG

rag = GotoRAG()

# Add notes programmatically
rag.add_note("/path/to/project", "Automated deployment", tags=["devops", "ci/cd"])

# Search
results = rag.search_notes("deployment issues")
for r in results:
    print(f"{r['path']}: {r['note']}")

rag.close()
```

### Git Integration (Future)
```bash
# Auto-capture git commits as context
goto-context --git
# Adds recent commits as searchable context
```

### Export/Import
```bash
# Export your knowledge base
sqlite3 ~/.goto_rag.db .dump > goto_notes_backup.sql

# Import on another machine
sqlite3 ~/.goto_rag.db < goto_notes_backup.sql
```

## Performance

- **Fast**: SQLite database with indexes
- **Lightweight**: ~50MB for embedding model (optional)
- **Non-blocking**: Visit tracking runs in background
- **Offline**: Everything runs locally

## Troubleshooting

### Semantic search not working?
```bash
# Check if dependencies are installed
python3 -c "import sentence_transformers"

# Install if missing
pip3 install sentence-transformers numpy
```

### Database issues?
```bash
# Check database
ls -lh ~/.goto_rag.db

# Reset (WARNING: deletes all notes)
rm ~/.goto_rag.db
```

### Not integrated with goto?
```bash
# Check if sourced
grep "rag-command.sh" ~/.zshrc

# Source manually
source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/rag-command.sh
```

## Roadmap

- [ ] **Git integration**: Auto-capture commit messages
- [ ] **File content indexing**: Search inside files
- [ ] **Claude integration**: Ask questions about folders
- [ ] **Smart suggestions**: "You usually visit X after Y"
- [ ] **Export/share**: Export knowledge base as markdown
- [ ] **Cross-reference**: Link related folders
- [ ] **Time-based search**: "What did I work on last week?"
- [ ] **Workspace context**: Project-level context graphs

## FAQ

**Q: Does this send data to the cloud?**  
A: No! Everything runs locally. If you install `sentence-transformers`, embeddings are generated on your machine.

**Q: How much disk space does it use?**  
A: Minimal. The database grows with your notes (~1KB per note). The embedding model is ~50MB if installed.

**Q: Can I use it without semantic search?**  
A: Yes! It falls back to keyword search. Still very useful for tracking notes and visits.

**Q: Does it slow down navigation?**  
A: No! Visit tracking runs in the background and doesn't block navigation.

**Q: Can I delete notes?**  
A: Currently via SQL. Coming soon: `goto-note --delete` command.

## Contributing

Ideas for enhancement:
1. File content indexing
2. Integration with external tools (JIRA, Confluence)
3. Smart suggestions based on patterns
4. Visual interface (TUI or web)

## License

Same as unix-goto project.

---

**Questions?** Open an issue or check `goto --help-rag`
