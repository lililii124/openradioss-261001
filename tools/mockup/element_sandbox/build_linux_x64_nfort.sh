#!/usr/bin/env bash
run_file='exec/element_linux_x64_nfort'

mkdir -p exec

rm -f "${run_file}"

nfort -O3 -fopenmp -fextend-source -fassume-contiguous -fno-matrix-multiply \
      -mno-vector-fma -fno-associative-math -fno-outerloop-unroll \
      -Isource/include source/*.F -o "${run_file}"
