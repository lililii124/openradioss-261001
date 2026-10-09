#!/usr/bin/env bash
run_file='exec/element_linux_x64_gfortran'

mkdir -p exec

rm -f "${run_file}"

echo "building with gfortran - ${run_file}"
gfortran -O3 -fdec-math -fstack-arrays -fopenmp -frounding-math -g \
         -fbacktrace -ffixed-line-length-none -D COMP_GFORTRAN \
         -I source/include source/*.F -o "${run_file}"
#
echo "done"
