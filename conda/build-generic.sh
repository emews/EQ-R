#!/bin/bash
set -eu
set -o pipefail

# BUILD GENERIC SH
# Generic builder for all platforms
# RECIPE_DIR is the PLATFORM directory
# Called internally by
#        "conda build" -> PLATFORM/build.sh -> build-generic.sh
# The EQ/R build output goes into PLATFORM/build-eqr.log
# Puts some metadata in PLATFORM/build-generic.log
#      link to work directory is important,
#      contains meta.yaml and Swift/T source
# If PLATFORM-specific settings are needed, put them in
#    PLATFORM/build.sh

# Environment notes:
# Generally, environment variables are not inherited into here.

# PREFIX is provided by Conda
# ENABLE_R may be set by meta.yaml

TIMESTAMP=$( date '+%Y-%m-%d %H:%M:%S' )
echo "BUILD-GENERIC.SH START $TIMESTAMP"

# This is in the builder RECIPE_DIR source tree
EQR_CONDA=$( cd $RECIPE_DIR/.. ; /bin/pwd -P )

{
  echo "TIMESTAMP:  $TIMESTAMP"
  echo "PLATFORM:   $PLATFORM"
  echo "BUILD_PWD:  $PWD"
  echo "RECIPE_DIR: $RECIPE_DIR"
  echo "SRC_DIR:    $SRC_DIR"
  echo "PREFIX:     $PREFIX"
} > $RECIPE_DIR/build-generic.log

# Cf. helpers.zsh
if [[ $PLATFORM =~ osx-* ]]
then
  NULL=""
  ZT=""
  if [[ $PLATFORM == osx-arm64 ]]
  then
    # These variables affect the mpicc/mpicxx wrappers
    export MPICH_CC=clang
    export MPICH_CXX=clang++
    # osx-arm64 sets this to "-ltcl8.6" for some reason
    unset LDFLAGS
  fi
else
  NULL="--null"
  ZT="--zero-terminated"
fi
printenv ${NULL} | sort ${ZT} | tr '\0' '\n' > \
                                   $RECIPE_DIR/build-env.log

if [[ ! -d $SRC_DIR ]]
then
  # This directory disappears under certain error conditions
  # The user must clean up the work directory
  echo "Cannot find SRC_DIR=$SRC_DIR under $PWD"
  echo "Delete this directory and the corresponding work_moved"
  echo $PWD
  echo "See build-generic.log for SRC_DIR"
  exit 1
fi

# Start build!
cd $SRC_DIR

if [[ $PLATFORM != "osx-arm64" ]]
then
  echo
  echo "build-generic.sh: Checking R ..."
  if ! which R
  then
    echo "build-generic.sh: Could not find R!"
    exit 1
  fi

  echo "build-generic.sh: Installing RInside ..."
  Rscript $SRC_DIR/conda/install-RInside.R 2>&1 | \
    tee $RECIPE_DIR/install-RInside.log
  if ! grep -q "EQR-RInside-SUCCESS" $RECIPE_DIR/install-RInside.log
  then
    echo "build-generic.sh: Installing RInside failed."
    exit 1
  fi
  echo "build-generic.sh: Installing RInside done."
fi

# Determine configuration for EQ/R build:
export R_HOME=$( R RHOME )
echo "build-generic.sh: R_HOME=$R_HOME"
CFG_ARGS=(
  # Cannot install libeqr.so to $PREFIX on osx-64
  # Use subdirectory:
  --prefix=$PREFIX/lib
  --with-r=$R_HOME
  --with-tcl=$PREFIX
  )
echo "CFG_ARGS:" ${CFG_ARGS[@]}

# Build it!
# Merge output streams to try to prevent buffering
#       problems with conda build
{
  echo "BUILD EQ/R START: $( date '+%Y-%m-%d %H:%M:%S' )"
  (
    # set -x does not seem to work here on osx-64
    set -eu
    echo "PWD:"
    pwd -P
    echo "TOOLS:"
    which Rscript R swig
    swig -version
    set -x
    cd src
    ./configure ${CFG_ARGS[@]} 2>&1
    make 2>&1
    make install 2>&1
  )
  echo "BUILD EQ/R STOP:  $( date '+%Y-%m-%d %H:%M:%S' )"
} | tee $RECIPE_DIR/build-eqr.log

echo "BUILD-GENERIC.SH STOP $( date '+%Y-%m-%d %H:%M:%S' )"
