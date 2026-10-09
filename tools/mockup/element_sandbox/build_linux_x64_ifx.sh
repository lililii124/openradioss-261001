#!/usr/bin/env bash
run_file='exec/element_linux_x64_ifx'

mkdir -p exec

rm -f "${run_file}"

ifx -O3 -fp-model precise -align array64byte -fimf-use-svml=true \
    -assume buffered_io -extend-source -qopenmp -traceback -g \
    -qopenmp-link=static -I source/include -o "${run_file}" source/*.F
