#!/usr/bin/env bash
run_file='exec/element_linux_x64_pgi'

mkdir -p exec

rm -f "${run_file}"

pgfortran -O3 -Mextend -mp -I source/include -o "${run_file}" source/*.F
