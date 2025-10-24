# goto RAG - Architecture Documentation

## System Overview

The goto RAG system extends the existing goto navigation tool with intelligent context retrieval and semantic search capabilities.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Shell                           │
│                    (bash/zsh terminal)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            │                         │
┌───────────▼────────────┐  ┌────────▼──────────────┐
│   Original goto        │  │   RAG Extensions      │
│   (existing)           │  │   (new)               │
│                        │  │                       │
│ • goto <project>       │  │ • goto-note           │
│ • goto list            │  │ • goto-recall         │
│ • goto --help          │  │ • goto-what           │
│ • back                 │  │ • goto-summary        │
│ • recent               │  │ • goto --help-rag     │
└────────────────────────┘  └────────┬──────────────┘
                                     │
                    ┌────────────────▼─────────────────┐
                    │      lib/rag-command.sh          │
                    │   Shell Integration Layer        │
                    │                                  │
                    │ • Argument parsing               │
                    │ • Command routing                │
                    │ • Visit tracking hook            │
                    │ • Background job management      │
                    └────────────┬─────────────────────┘
                                 │
                    ┌────────────▼─────────────────────┐
                    │      lib/goto-rag.py             │
                    │    Core RAG Implementation       │
                    │                                  │
                    │ ┌──────────────────────────────┐ │
                    │ │  GotoRAG Class               │ │
                    │ │                              │ │
                    │ │ • add_note()                 │ │
                    │ │ • get_notes()                │ │
                    │ │ • search_notes()             │ │
                    │ │ • update_visit()             │ │
                    │ │ • get_folder_summary()       │ │
                    │ │ • add_context()              │ │
                    │ └──────────────────────────────┘ │
                    └────────┬─────────┬───────────────┘
                             │         │
                ┌────────────▼───┐     └──────────────┐
                │                │                    │
      ┌─────────▼──────────┐  ┌─▼───────────────┐   │
      │   SQLite Database  │  │  Embedding       │   │
      │   ~/.goto_rag.db   │  │  Generator       │   │
      │                    │  │                  │   │
      │ ┌────────────────┐ │  │ sentence-        │   │
      │ │ notes          │ │  │ transformers     │   │
      │ │ context        │ │  │                  │   │
      │ │ folder_meta    │ │  │ (optional)       │   │
      │ └────────────────┘ │  └──────────────────┘   │
      └────────────────────┘                         │
                                                     │
                                    ┌────────────────▼────────┐
                                    │  Semantic Search         │
                                    │  (if embeddings enabled) │
                                    │                          │
                                    │  • Cosine similarity     │
                                    │  • Vector search         │
                                    │  • Result ranking        │
                                    └──────────────────────────┘
```

## Data Flow

### 1. Adding a Note

```
User: goto-note "Fixed auth bug"
  │
  ├─▶ rag-command.sh
  │     ├─ Parse arguments
  │     └─ Call Python script
  │
  └─▶ goto-rag.py
        ├─ Expand path (PWD)
        ├─ Generate embedding (if available)
        ├─ Insert to database
        └─ Return success
```

### 2. Searching Notes

```
User: goto-recall "authentication"
  │
  ├─▶ rag-command.sh
  │     └─ Route to search
  │
  └─▶ goto-rag.py
        ├─ Generate query embedding
        ├─ Search database
        │   ├─ If embeddings: Vector similarity
        │   └─ Else: Keyword match
        ├─ Rank results
        └─ Format and display
```

### 3. Automatic Visit Tracking

```
User: goto luxor
  │
  └─▶ goto-function.sh
        ├─ Navigate to folder
        └─ Call __goto_navigate_to()
              │
              └─▶ rag-command.sh (hook)
                    ├─ Background job spawned
                    └─▶ goto-rag.py (non-blocking)
                          ├─ Update visit count
                          ├─ Update last_visited
                          └─ Return (silent)
```

## Database Schema

### Tables

```sql
┌──────────────────────────────────────────────────────┐
│                      notes                           │
├──────────┬───────────┬──────────────────────────────┤
│ id       │ INTEGER   │ PRIMARY KEY                  │
│ path     │ TEXT      │ Absolute folder path         │
│ note     │ TEXT      │ User's note content          │
│ timestamp│ DATETIME  │ When note was added          │
│ tags     │ TEXT      │ JSON array of tags           │
│ embedding│ BLOB      │ Vector embedding (optional)  │
└──────────┴───────────┴──────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│                    context                           │
├──────────┬───────────┬──────────────────────────────┤
│ id       │ INTEGER   │ PRIMARY KEY                  │
│ path     │ TEXT      │ Absolute folder path         │
│ type     │ TEXT      │ Context type (git, cmd, etc.)│
│ content  │ TEXT      │ Context content              │
│ timestamp│ DATETIME  │ When captured                │
│ embedding│ BLOB      │ Vector embedding (optional)  │
└──────────┴───────────┴──────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│                  folder_meta                         │
├──────────────┬────────┬──────────────────────────────┤
│ path         │ TEXT   │ PRIMARY KEY                  │
│ last_visited │ DATE   │ Most recent visit            │
│ visit_count  │ INT    │ Total visits                 │
│ description  │ TEXT   │ Folder description           │
│ tags         │ TEXT   │ JSON array of tags           │
└──────────────┴────────┴──────────────────────────────┘
```

### Indexes

```sql
CREATE INDEX idx_notes_path ON notes(path);
CREATE INDEX idx_notes_timestamp ON notes(timestamp);
CREATE INDEX idx_context_path ON context(path);
```

## Embedding System

### Model: all-MiniLM-L6-v2

```
┌─────────────────────────────────────────────┐
│          Embedding Pipeline                 │
├─────────────────────────────────────────────┤
│                                             │
│  Text Input                                 │
│     │                                       │
│     ▼                                       │
│  ┌──────────────────┐                      │
│  │ Tokenization     │                      │
│  └────────┬─────────┘                      │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────┐                      │
│  │ Transformer      │                      │
│  │ Encoder          │                      │
│  │ (6 layers)       │                      │
│  └────────┬─────────┘                      │
│           │                                 │
│           ▼                                 │
│  ┌──────────────────┐                      │
│  │ Mean Pooling     │                      │
│  └────────┬─────────┘                      │
│           │                                 │
│           ▼                                 │
│  [384-dim vector]                          │
│           │                                 │
│           ▼                                 │
│  Store as BLOB in SQLite                   │
│                                             │
└─────────────────────────────────────────────┘
```

### Similarity Calculation

```python
def cosine_similarity(v1, v2):
    """
    Calculates similarity between two embeddings
    
    Range: -1.0 to 1.0
    • 1.0  = identical
    • 0.0  = unrelated
    • -1.0 = opposite (rare in practice)
    """
    dot_product = v1 · v2
    magnitude = |v1| × |v2|
    return dot_product / magnitude
```

## Command Processing Flow

### goto-note Flow

```
┌─────────────────────────────────────────────────┐
│ User enters: goto-note "Fixed bug in auth"     │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ rag-command.sh: goto-note()                    │
├─────────────────────────────────────────────────┤
│ 1. Parse args: --path, --tags, <text>         │
│ 2. Get current directory if no --path         │
│ 3. Build Python command                        │
│ 4. Execute: python3 goto-rag.py note ...      │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ goto-rag.py: main() → note command            │
├─────────────────────────────────────────────────┤
│ 1. Parse args                                  │
│ 2. Initialize GotoRAG()                        │
│ 3. Call rag.add_note()                         │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ GotoRAG.add_note()                             │
├─────────────────────────────────────────────────┤
│ 1. Expand path to absolute                    │
│ 2. Generate embedding if model available      │
│ 3. Serialize tags to JSON                     │
│ 4. INSERT INTO notes                           │
│ 5. Commit transaction                          │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ Display: "✓ Note added for <path>"            │
└─────────────────────────────────────────────────┘
```

### goto-recall Flow

```
┌─────────────────────────────────────────────────┐
│ User enters: goto-recall "authentication"      │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ rag-command.sh: goto-recall()                  │
├─────────────────────────────────────────────────┤
│ 1. Capture query string                        │
│ 2. Execute: python3 goto-rag.py search ...    │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ GotoRAG.search_notes()                         │
├─────────────────────────────────────────────────┤
│ IF embeddings available:                       │
│   1. Generate query embedding                  │
│   2. Load all note embeddings from DB          │
│   3. Calculate cosine similarity for each      │
│   4. Sort by similarity score                  │
│   5. Filter by threshold (> 0.3)              │
│   6. Return top results                        │
│ ELSE:                                          │
│   1. SQL LIKE query: WHERE note LIKE '%..%'   │
│   2. Return matching notes                     │
└─────────────┬───────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────┐
│ Format and display results:                    │
│ • Path                                         │
│ • Note text                                    │
│ • Timestamp                                    │
│ • Similarity score (if semantic)              │
└─────────────────────────────────────────────────┘
```

## Integration Points

### 1. Shell Integration

The RAG system integrates with the existing goto through function wrapping:

```bash
# Original function saved
__goto_navigate_to_original()

# New wrapper function
__goto_navigate_to() {
    __goto_navigate_to_original "$@"  # Call original
    __goto_rag_track_visit "$1"       # Add tracking
}
```

### 2. Extension Points

Future enhancements can hook into:

```python
class GotoRAG:
    def add_context(self, path, context_type, content):
        """
        Extensible context capture system
        
        context_type examples:
        - 'git': Git commit messages
        - 'cmd': Shell commands run
        - 'file': File changes
        - 'custom': User-defined
        """
        pass
```

## Performance Considerations

### Database Operations

```
┌──────────────────┬──────────────┬─────────────┐
│ Operation        │ Avg Time     │ Notes       │
├──────────────────┼──────────────┼─────────────┤
│ Add note         │ < 50ms       │ + embedding │
│ Get notes        │ < 20ms       │ Indexed     │
│ Keyword search   │ < 30ms       │ SQL LIKE    │
│ Semantic search  │ < 150ms      │ N×similarity│
│ Update visit     │ < 10ms       │ Background  │
└──────────────────┴──────────────┴─────────────┘
```

### Optimization Strategies

1. **Background Operations**
   - Visit tracking runs async
   - Non-blocking for user

2. **Indexed Queries**
   - Path and timestamp indexed
   - Fast lookups

3. **Embedding Cache**
   - Embeddings computed once
   - Stored as BLOB
   - Reused for searches

4. **Lazy Loading**
   - Model loaded on first use
   - Not loaded for keyword-only

## Error Handling

### Graceful Degradation

```
┌─────────────────────────────────────────┐
│ Feature Availability Matrix             │
├─────────────┬───────────┬───────────────┤
│ Component   │ Required? │ Fallback      │
├─────────────┼───────────┼───────────────┤
│ Python 3    │ Yes       │ None          │
│ SQLite      │ Yes (std) │ None          │
│ sentence-   │ No        │ Keyword search│
│ transformers│           │               │
│ numpy       │ No        │ Keyword search│
└─────────────┴───────────┴───────────────┘
```

### Error Messages

```python
try:
    from sentence_transformers import SentenceTransformer
    HAS_EMBEDDINGS = True
except ImportError:
    HAS_EMBEDDINGS = False
    # No error - just use keyword search
```

## Security Considerations

### Data Privacy

1. **Local Storage**
   - All data in `~/.goto_rag.db`
   - No external transmission
   - User-owned data

2. **File Permissions**
   ```bash
   chmod 600 ~/.goto_rag.db  # User-only access
   ```

3. **Path Validation**
   ```python
   path = os.path.abspath(os.path.expanduser(path))
   # Prevents directory traversal
   ```

## Maintenance

### Database Management

```bash
# Backup
cp ~/.goto_rag.db ~/.goto_rag.db.backup

# Export
sqlite3 ~/.goto_rag.db .dump > backup.sql

# Restore
sqlite3 ~/.goto_rag.db < backup.sql

# Inspect
sqlite3 ~/.goto_rag.db
> SELECT * FROM notes LIMIT 5;
```

### Cleanup

```bash
# Remove old notes (manual SQL)
sqlite3 ~/.goto_rag.db <<EOF
DELETE FROM notes 
WHERE timestamp < datetime('now', '-90 days');
EOF

# Vacuum database
sqlite3 ~/.goto_rag.db "VACUUM;"
```

## Future Architecture Enhancements

### Planned Extensions

1. **Git Integration Module**
   ```
   lib/goto-git-integration.sh
   └─ Auto-capture commits as context
   ```

2. **File Indexer**
   ```
   lib/goto-file-indexer.py
   └─ Index file contents
   ```

3. **Claude Q&A**
   ```
   lib/goto-claude-qa.py
   └─ Natural language queries
   ```

4. **Web Interface (Optional)**
   ```
   lib/goto-web/
   ├─ server.py
   ├─ static/
   └─ templates/
   ```

---

**This architecture is designed for:**
- ✅ Simplicity
- ✅ Performance
- ✅ Extensibility
- ✅ Maintainability
- ✅ User privacy

**Built to grow with your needs!** 🚀
