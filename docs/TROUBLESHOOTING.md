# goto RAG - Troubleshooting Guide

Quick fixes for common issues.

## ⚠️ "goto-rag.py not found"

**Problem:** Can't find the Python script

**Solution:**
```bash
# Verify file exists
ls -lah ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py

# If missing, you may be in wrong directory
cd ~/Documents/LUXOR/Git_Repos/unix-goto

# Re-run setup
./setup-rag.sh
```

**Why it happens:** The script is in `lib/` directory, not root.

---

## ⚠️ "Command not found: goto-note"

**Problem:** RAG commands not available

**Solution:**
```bash
# Re-source your shell config
source ~/.zshrc

# Or manually load RAG
source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/rag-command.sh

# Verify it loaded
type goto-note
# Should show: "goto-note is a function"
```

---

## ⚠️ "Python 3 is required"

**Problem:** Python not installed or not in PATH

**Solution:**
```bash
# Check if Python is installed
which python3

# If not found, install it
brew install python3

# Verify version
python3 --version
# Should be Python 3.7 or higher
```

---

## ⚠️ Semantic search not working

**Problem:** Searches work but don't seem "smart"

**This is normal!** You're using keyword search mode.

**Optional Enhancement:**
```bash
# Install semantic search dependencies
pip3 install sentence-transformers numpy

# This enables AI-powered semantic search
# File size: ~50MB download
# Takes 2-3 minutes to install
```

**Keyword search still works great for:**
- Exact word matches
- Tag searches
- File path searches

---

## ⚠️ "Database is locked"

**Problem:** Multiple processes accessing database

**Solution:**
```bash
# Wait a moment and try again
# OR kill background processes
pkill -f goto-rag.py

# Try your command again
goto-note "test"
```

---

## ⚠️ No results when searching

**Problem:** `goto-recall` returns no results

**Check:**
```bash
# 1. Do you have any notes?
sqlite3 ~/.goto_rag.db "SELECT COUNT(*) FROM notes;"
# Should be > 0

# 2. Add a test note
goto-note "test note for debugging"

# 3. Search for it
goto-recall "test"
# Should find it now

# 4. View all notes
sqlite3 ~/.goto_rag.db "SELECT path, note FROM notes;"
```

---

## ⚠️ Slow searches (> 1 second)

**Possible causes:**

1. **Too many notes** (> 10,000)
   ```bash
   # Check note count
   sqlite3 ~/.goto_rag.db "SELECT COUNT(*) FROM notes;"
   
   # Clean old notes (optional)
   sqlite3 ~/.goto_rag.db "DELETE FROM notes WHERE timestamp < datetime('now', '-90 days');"
   ```

2. **Embedding model loading**
   - First search after install loads model (one-time delay)
   - Subsequent searches are fast

---

## ⚠️ Installation fails

**Problem:** `./setup-rag.sh` fails

**Manual installation:**
```bash
# 1. Make scripts executable
chmod +x ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py
chmod +x ~/Documents/LUXOR/Git_Repos/unix-goto/lib/rag-command.sh

# 2. Add to ~/.zshrc manually
echo 'source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/rag-command.sh' >> ~/.zshrc

# 3. Reload shell
source ~/.zshrc

# 4. Test
goto-note "test"
```

---

## ⚠️ Commands work but no output

**Problem:** Commands run but show nothing

**Check:**
```bash
# Test Python script directly
python3 ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py --help

# Should show help menu
# If error, check Python installation

# Test with verbose output
python3 ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py note /tmp/test "test" 2>&1
```

---

## ⚠️ Visit tracking not working

**Problem:** `goto-summary` shows no visits

**This is normal if:**
- You haven't used `goto` to navigate (manual `cd` doesn't track)
- You just installed (no history yet)

**Solution:**
```bash
# Navigate using goto to generate visits
goto luxor
goto halcon
goto docs

# Now check
goto-summary
# Should show visits
```

---

## 🔍 Advanced Debugging

### Check Database

```bash
# Open database
sqlite3 ~/.goto_rag.db

# List all tables
.tables

# Check notes
SELECT * FROM notes LIMIT 5;

# Check visits
SELECT * FROM folder_meta LIMIT 5;

# Exit
.quit
```

### Check Logs

```bash
# Test with Python errors visible
python3 ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py note /tmp/test "test note" 2>&1

# Check for Python import errors
python3 -c "import sqlite3; print('SQLite OK')"
python3 -c "import json; print('JSON OK')"
```

### Reset Everything

```bash
# ⚠️  WARNING: Deletes all notes!

# Delete database
rm ~/.goto_rag.db

# Test fresh start
goto-note "fresh start"
goto-recall "fresh"
# Should work
```

---

## 📞 Still Having Issues?

### Quick Diagnostics

Run this diagnostic script:
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
./test-rag.sh
```

**If all tests pass:** System is working correctly!  
**If tests fail:** Check error messages above

### Verify Installation

```bash
# 1. Python available?
which python3

# 2. Script exists?
ls -lah ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py

# 3. Commands loaded?
type goto-note

# 4. Can run directly?
python3 ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-rag.py --help

# All should succeed ✓
```

---

## 💡 Tips

### Performance
- First search loads model (slow once)
- Subsequent searches are fast (< 150ms)
- Keyword search is always fast (< 30ms)

### Best Practices
- Add notes as you work (don't wait!)
- Use tags for organization
- Keep notes concise
- Search regularly to find patterns

### Maintenance
- Database grows ~1KB per note
- Clean old notes if needed (optional)
- Backup: `cp ~/.goto_rag.db ~/backup.db`

---

## ✅ Common False Alarms

**"Semantic search dependencies (Optional)"**
→ This is normal! Keyword search still works great.

**"No notes yet"**
→ You haven't added notes yet. Try `goto-note "test"`

**First search is slow**
→ Normal! Loading model. Subsequent searches are fast.

---

**Still stuck?** 
1. Run `./test-rag.sh` for diagnostics
2. Check `RAG-README.md` for detailed docs
3. Review error messages carefully

**Most issues are fixed by:**
- `source ~/.zshrc`
- Being in the right directory
- Running the test script

🎉 **Happy troubleshooting!**
