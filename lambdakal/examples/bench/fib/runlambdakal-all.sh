#!/usr/bin/env bash
# set -euo pipefail

FILE=./examples/bench/fib/fib.lk

# Warmup run
cabal run lambdakal -- -f "$FILE" -o0 > /dev/null 2>&1

for N in 38 39 40 41 42 43 44 45 46; do
  for OPT in 0 3; do
    echo "Running with N=$N and optimization level $OPT"

    # Modify input file
    awk -v LINE="fib($N);" '
      NR>1 {print prev}
      {prev=$0}
      END {print LINE}
    ' "$FILE" > "$FILE.tmp"

    total=0
    runs=10
    for i in $(seq 1 $runs); do
      out=$( { time cabal run lambdakal -- -f "$FILE.tmp" -o"$OPT" >/dev/null; } 2>&1 )
      # extract "real" line, convert mXs to seconds
      t=$(echo "$out" | awk '/^real/ {
        split($2, a, "m");
        sec=a[1]*60;
        gsub("s","",a[2]);
        sec+=a[2];
        print sec
      }')
      total=$(awk -v a="$total" -v b="$t" 'BEGIN {print a+b}')
    done

    avg=$(awk -v t="$total" -v r="$runs" 'BEGIN {printf "%.6f", t/r}')
    echo "Average time over $runs runs: $avg seconds"
    echo
  done
done
