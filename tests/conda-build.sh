#!/bin/zsh
set -eu

# TESTS CONDA BUILD
# Interactive script for conda build
# Activate an Anaconda environment then run this

export R_HOME=$( R RHOME )

A=(
  --prefix=$CONDA_PREFIX/lib
  --with-r=$R_HOME
  --with-tcl=$CONDA_PREFIX
#   --enable-conda
)

# Find the src directory
cd ${0:h:A}
cd ../src

set -x
./configure $A
make
