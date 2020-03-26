#!/bin/sh
set -eu

THIS=$( readlink --canonicalize $( dirname $0 )  )
export EMEWS_PROJECT_ROOT=$( cd $THIS/.. ; /bin/pwd )

ROOT=/projects/Swift-T/public/sfw/theta/aprun

# SWIFT=$HOME/Public/sfw/theta/swift-t/2020-03-03
# EQR=$HOME/Public/sfw/theta/EQ-R

SWIFT=$ROOT/swift-t/2020-03-26
EQR=$ROOT/EQ-R
R=$ROOT/R-3.6.0/lib64/R

export PROJECT=CVD_Research
# export PROJECT=CSC249ADOA01
export QUEUE=CVD_Research
# export QUEUE=debug-flat-quad
export WALLTIME=00:02:00

LLP=$R/lib

PATH=$SWIFT/stc/bin:$PATH

export TURBINE_RESIDENT_WORK_WORKERS=1

export TURBINE_DEBUG=0
export ADLB_DEBUG=0

set -x
swift-t -n 3 -p -I $EQR -r $EQR -m theta -t w \
        -e LD_LIBRARY_PATH=$LLP \
        -e TURBINE_RESIDENT_WORK_WORKERS \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift  \
        --algo_file=$EMEWS_PROJECT_ROOT/R/algorithm.R
