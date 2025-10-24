#!/bin/bash
# unix-goto benchmark examples
# Demonstrates benchmark suite usage

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║         UNIX-GOTO BENCHMARK USAGE EXAMPLES                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Example 1: Quick benchmark
echo "Example 1: Run quick navigation benchmark"
echo "──────────────────────────────────────────"
echo "Command: goto benchmark navigation unix-goto 5"
echo ""
echo "This tests:"
echo "  - Uncached navigation (cold start, filesystem scan)"
echo "  - Cached navigation (warm start, O(1) lookup)"
echo "  - Calculates speedup ratio"
echo "  - Target: <100ms cached, 20-50x speedup"
echo ""
echo "Press Enter to continue..."
read

# Example 2: Cache performance
echo ""
echo "Example 2: Test cache performance"
echo "──────────────────────────────────"
echo "Command: goto benchmark cache typical"
echo ""
echo "This tests:"
echo "  - Cache build time for 50 folders"
echo "  - Cache hit rate (target >90%)"
echo "  - Validates cache efficiency"
echo ""
echo "Press Enter to continue..."
read

# Example 3: Parallel search
echo ""
echo "Example 3: Compare sequential vs parallel search"
echo "─────────────────────────────────────────────────"
echo "Command: goto benchmark parallel 10"
echo ""
echo "This tests:"
echo "  - Sequential search across all paths"
echo "  - Parallel search using background jobs"
echo "  - Calculates speedup from parallelization"
echo ""
echo "Press Enter to continue..."
read

# Example 4: Complete suite
echo ""
echo "Example 4: Run complete benchmark suite"
echo "────────────────────────────────────────"
echo "Command: goto benchmark all"
echo ""
echo "This runs:"
echo "  1. Navigation benchmark (5 iterations)"
echo "  2. Cache benchmark (5 iterations)"
echo "  3. Parallel search benchmark (5 iterations)"
echo "  4. Generates comprehensive report"
echo ""
echo "Press Enter to continue..."
read

# Example 5: Workspace management
echo ""
echo "Example 5: Create and manage test workspaces"
echo "─────────────────────────────────────────────"
echo "Commands:"
echo "  goto benchmark workspace create large    # 200+ folders, 4 levels deep"
echo "  goto benchmark workspace stats           # Show workspace info"
echo "  goto benchmark workspace clean           # Remove workspace"
echo ""
echo "Workspace types: small (10), typical (50), large (200+)"
echo ""
echo "Press Enter to continue..."
read

# Example 6: Standalone execution
echo ""
echo "Example 6: Standalone benchmark execution"
echo "──────────────────────────────────────────"
echo "Command: benchmark-goto all"
echo ""
echo "Benefits:"
echo "  - No need to reload shell"
echo "  - Can run from any directory"
echo "  - Ideal for CI/CD pipelines"
echo "  - Same functionality as 'goto benchmark'"
echo ""
echo "Press Enter to continue..."
read

# Example 7: Report generation
echo ""
echo "Example 7: Generate performance report"
echo "───────────────────────────────────────"
echo "Command: goto benchmark report"
echo ""
echo "Output includes:"
echo "  - System information"
echo "  - Navigation benchmark summary"
echo "  - Cache performance metrics"
echo "  - Parallel search results"
echo "  - CSV data location"
echo ""
echo "Press Enter to continue..."
read

# Example 8: CI/CD Integration
echo ""
echo "Example 8: CI/CD integration example"
echo "────────────────────────────────────"
cat << 'EOF'
#!/bin/bash
# .github/workflows/benchmark.yml

# Run benchmarks
benchmark-goto all

# Extract cache hit rate
hit_rate=$(grep "hit_rate" ~/.goto_benchmarks/results.csv | tail -1 | cut -d',' -f4)

# Validate against target
if [ "$hit_rate" -lt 90 ]; then
    echo "❌ Cache hit rate below target: ${hit_rate}%"
    exit 1
fi

echo "✓ All performance targets met"
EOF
echo ""
echo "Press Enter to continue..."
read

# Example 9: Baseline comparison
echo ""
echo "Example 9: Before/after optimization comparison"
echo "───────────────────────────────────────────────"
cat << 'EOF'
# Establish baseline
benchmark-goto all > baseline.txt

# Make optimization changes
# ... your code changes ...

# Re-benchmark
benchmark-goto all > optimized.txt

# Compare results
diff baseline.txt optimized.txt
EOF
echo ""
echo "Press Enter to continue..."
read

# Example 10: Custom iterations
echo ""
echo "Example 10: Custom iteration counts"
echo "───────────────────────────────────"
echo "Commands:"
echo "  goto benchmark navigation unix-goto 20   # 20 iterations"
echo "  goto benchmark cache large 15            # 15 iterations"
echo "  goto benchmark parallel 25               # 25 iterations"
echo ""
echo "Or set environment variable:"
echo "  export GOTO_BENCHMARK_ITERATIONS=30"
echo "  goto benchmark all"
echo ""
echo "Press Enter to finish..."
read

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    EXAMPLES COMPLETE                             ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Quick reference:"
echo "  goto benchmark --help          Show benchmark help"
echo "  goto benchmark all             Run complete suite"
echo "  goto benchmark report          Generate summary"
echo "  benchmark-goto all             Standalone execution"
echo ""
echo "Full documentation: BENCHMARKS.md"
echo ""
