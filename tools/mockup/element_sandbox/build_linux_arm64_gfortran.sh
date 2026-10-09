#!/usr/bin/env bash
run_file='exec/element_linux_arm64_gfortran_sve'

mkdir -p exec

rm -f "${run_file}"

gfortran -O3 -march=armv8-a+sve -fdec-math -fstack-arrays -fopenmp \
         -frounding-math -g -fbacktrace -ffixed-line-length-none \
         -D COMP_GFORTRAN -I source/include source/*.F -o "${run_file}"
