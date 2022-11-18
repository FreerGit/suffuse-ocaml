#!/bin/bash
export BENCHMARKS_RUNNER=TRUE
export BENCH_LIB=suffuse
exec dune exec -- ./main.exe -fork -run-without-cross-library-inlining "$@" -quota 10 -stabilize-gc