#!/usr/bin/env bash
run_file='exec/element_linux_arm64_armflang_sve'

mkdir -p exec

rm -f "${run_file}"

armflang -Ofast -march=armv8.2-a+sve -fno-stack-arrays -mcpu=a64fx -fopenmp \
         -g -ffixed-line-length-none -armpl=sve  -static-arm-libs \
         -D COMP_ARMFLANG -I source/include source/*.F -o "${run_file}"

