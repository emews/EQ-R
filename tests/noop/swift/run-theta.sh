#!/bin/sh
set -eu

THIS=$( cd $( dirname $0 ); /bin/pwd )
export EMEWS_PROJECT_ROOT=$( cd $THIS/.. ; /bin/pwd )

SWIFT=$HOME/Public/sfw/theta/swift-t/2020-03-03
EQR=$HOME/Public/sfw/theta/EQ-R

export TURBINE_RESIDENT_WORK_WORKERS=1

export PROJECT=CSC249ADOA01 # CANDLE_ECP # ecp-testbed-01
# CVD_Research
export QUEUE=debug-cache-quad
# export QUEUE=debug-flat-quad
export WALLTIME=00:02:00

R=/home/wozniak/Public/sfw/theta/R-3.4.0/lib64/R
LLP=$R/lib

PATH=$SWIFT/stc/bin:$PATH

export TURBINE_RESIDENT_WORK_WORKERS=1

set -x
swift-t -n 3 -p -I $EQR -r $EQR -m theta -t w \
        -e LD_LIBRARY_PATH=$LLP \
        -e TURBINE_RESIDENT_WORK_WORKERS \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift  \
        --algo_file=$EMEWS_PROJECT_ROOT/R/algorithm.R
