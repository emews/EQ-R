#!/bin/bash -l
set -eu

THIS=$( readlink --canonicalize $( dirname $0 )  )
export EMEWS_PROJECT_ROOT=$( readlink --canonicalize $THIS/.. )

MED106=/gpfs/alpine/world-shared/med106
ROOT=$MED106/wozniak/sw/gcc-6.4.0

SWIFT=$ROOT/swift-t/2020-04-02
EQR=$ROOT/EQ-R
R=$ROOT/R-3.6.1/lib64/R

export PROJECT=med106
export QUEUE=${QUEUE:-batch}
# export QUEUE=debug-flat-quad
export WALLTIME=00:02:00

LLP=$R/lib

PATH=$SWIFT/stc/bin:$PATH

export TURBINE_RESIDENT_WORK_WORKERS=1

export TURBINE_DEBUG=0
export ADLB_DEBUG=0

set -x
which swift-t

swift-t -n 3 -p -I $EQR -r $EQR -m lsf \
        -e TURBINE_RESIDENT_WORK_WORKERS \
        $EMEWS_PROJECT_ROOT/swift/workflow.swift  \
        --algo_file=$EMEWS_PROJECT_ROOT/R/algorithm.R
