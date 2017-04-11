#!/bin/sh
set -eu

THIS=$( cd $( dirname $0 ); /bin/pwd )
export EMEWS_PROJECT_ROOT=$( cd $THIS/.. ; /bin/pwd )
EQR=$EMEWS_PROJECT_ROOT/ext/EQ-R

#export PYTHONPATH=$T_PROJECT_ROOT/python:$EQP
export TURBINE_RESIDENT_WORK_WORKERS=1

set -x
swift-t -n 3 -p -I $EQR -r $EQR $EMEWS_PROJECT_ROOT/swift/workflow.swift  \
  --algo_file=$EMEWS_PROJECT_ROOT/R/fail.R
