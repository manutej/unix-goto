# Performance Benchmarks (Developer Tools)

These are optional development/testing tools for measuring unix-goto performance.

## Not Loaded by Default

Benchmark commands are **not loaded** in standard unix-goto installations to keep the core tool lean and fast.

## Enabling Benchmarks

To use benchmarking tools, uncomment the benchmark loader in `goto.sh`:

```bash
# In goto.sh, add after the core modules:
source "$(dirname "$GOTO_LIB_DIR")/dev-tools/benchmarks/benchmark-command.sh"
source "$(dirname "$GOTO_LIB_DIR")/dev-tools/benchmarks/benchmark-workspace.sh"
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## Running Benchmarks

Once enabled, you can run:

```bash
# Run all benchmarks
./dev-tools/benchmarks/run-benchmarks.sh --all

# Run specific benchmark
./dev-tools/benchmarks/run-benchmarks.sh directory-lookup

# Generate performance report
./dev-tools/benchmarks/run-benchmarks.sh --report
```

## What's Measured

- Navigation performance (cached vs uncached)
- Cache hit rates and effectiveness
- Bookmark lookup speed
- Search depth impact
- Workspace scalability

## Why Optional?

Keeping benchmarks optional ensures:
- Faster shell startup time
- Smaller core codebase
- Clear separation between user features and dev tools
- Easier maintenance

Most users don't need performance benchmarking - they just want fast navigation.
