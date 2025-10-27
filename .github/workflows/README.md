# Standard Development Workflow

## Quick Start for Development

```bash
cd /path/to/unix-goto
source goto.sh
```

All features are now loaded. No complex installation needed for testing.

## Standard Commands

### Cache System (CET-77)
```bash
goto index rebuild    # Build cache
goto index status     # Check cache
goto index clear      # Clear cache
goto index --help     # Help
```

### Benchmarks (CET-85)
```bash
goto benchmark --help              # See all options
goto benchmark navigation <target> <iterations>
goto benchmark cache <workspace> <iterations>
goto benchmark report              # Summary
```

### Regular Navigation
```bash
goto HALCON          # Instant with cache
goto chatz           # Instant with cache
goto <any-folder>    # Fast cached lookup
```

## Testing New Features

1. **Source the loader:**
   ```bash
   source goto.sh
   ```

2. **Test your feature:**
   ```bash
   goto <your-command>
   ```

3. **Run automated tests:**
   ```bash
   bash test-cache.sh
   bash test-benchmark.sh
   ```

4. **Commit:**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

## Standard File Structure

```
unix-goto/
├── goto.sh                    # ONE-LINE LOADER (use this!)
├── lib/
│   ├── cache-index.sh        # Cache system
│   ├── benchmark-command.sh  # Benchmarks
│   ├── goto-function.sh      # Main goto
│   └── ...other modules
├── test-cache.sh             # Cache tests
├── test-benchmark.sh         # Benchmark tests
└── QUICKSTART.md             # Simple instructions
```

## For End Users

**Installation is ONE line:**
```bash
echo "source /path/to/unix-goto/goto.sh" >> ~/.bashrc
```

**That's it.** No complex installation, no multi-step process.

## Key Principles

1. **Simple:** ONE line to load everything
2. **Fast:** Cache provides 8x speedup
3. **Lean:** No bloat, minimal dependencies
4. **Tested:** 27 automated tests (100% passing)

Keep it simple. Keep it fast. Keep it lean.
