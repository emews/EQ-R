#!/bin/zsh
set -eu

# CONDA BUILD
# Generic wrapper around `conda build'
# Generates meta.yaml and runs `conda build'
# Many exported environment variables here
#      are substituted into meta.yaml
# This script runs in the PLATFORM subdirectory
#      and should not change directories from there
# A LOG is produced named PLATFORM/conda-build.log
# You can only run 1 job concurrently
#     because of the log and
#     because of meta.yaml

help()
{
  cat <<END

Options:
   -C configure-only- generate meta.yaml and settings.sed, then stop
   -r for the R version
   CONDA_PLATFORM BUILD_NUMBER

Arguments:
   CONDA_PLATFORM : platform (linux-64, osx-arm64, etc)
   BUILD_NUMBER   : conda build number (integer)

END
  exit
}

C="" R=""
zparseopts -D -E -F h=HELP C=C r=R

if (( ${#HELP} )) help

# The EQ/R Conda script directory (absolute):
EQR_CONDA=${0:A:h}
# Get the top-level git clone directory :
export EQR_HOME=${EQR_CONDA:h}

source $EQR_CONDA/helpers.zsh

# For log()
LOG_LABEL="conda-build:"

# Require CONDA_PLATFORM and BUILD_NUMBER as positional args
if (( ${#*} != 2 )) abort "Provide CONDA_PLATFORM BUILD_NUMBER"

# The PLATFORM under Anaconda naming conventions:
export CONDA_PLATFORM=$1
# The conda build number (substituted into meta.yaml):
export BUILD_NUMBER=$2
# Must be a non-negative integer: catches swapped arguments, etc.
if [[ $BUILD_NUMBER != <-> ]] \
  abortf "conda-build.sh: invalid BUILD_NUMBER, got: '%s'\n" \
         $BUILD_NUMBER

shift 2

export PKG_NAME=EQ-R
export EQR_VERSION=1.3
export SWIFT_T_R_VERSION=1.6.9

log "CONDA-BUILD ($CONDA_PLATFORM)" \
    "EQ-R=$EQR_VERSION swift-t-r=$SWIFT_T_R_VERSION"
log "BUILD_NUMBER:    $BUILD_NUMBER"

source $EQR_CONDA/get-python-version.sh

log "PYTHON_VERSION: $PYTHON_VERSION   SERIES: $PYTHON_SERIES"

if [[ ! -d $EQR_CONDA/$CONDA_PLATFORM ]] \
  abortf "No such platform: '%s'\n" $CONDA_PLATFORM

cd $EQR_CONDA/$CONDA_PLATFORM

# Check that the conda-build tool in use is in the
#       selected Python installation
if ! which conda-build >& /dev/null
then
  log "could not find tool: conda-build"
  log "                     run ./setup-conda.sh"
  return 1
fi
# Look up executable:
CONDA_BUILD_TOOL=( =conda-build )
# Get its directory:
TOOLDIR=${CONDA_BUILD_TOOL:h}
# Look up executable:
PYTHON_EXE=( =python )
# Get its directory:
PYTHON_BIN=${PYTHON_EXE:h}
if [[ ${TOOLDIR} != ${PYTHON_BIN} ]] {
  log "conda-build is not in your python directory!"
  log "            this is probably wrong!"
  log "            run ./setup-conda.sh"
  return 1
}

# We must set CONDA_PREFIX:
# https://github.com/ContinuumIO/anaconda-issues/issues/10156
export CONDA_PREFIX=${PYTHON_BIN:h}

# Check if a package with this BUILD_NUMBER already exists locally.
# This warns the user they may be rebuilding with a stale build number.
BLD_DIR=$CONDA_PREFIX/conda-bld/$CONDA_PLATFORM
if [[ -d $BLD_DIR ]] {
  EXISTING_PKGS=( $BLD_DIR/*_${BUILD_NUMBER}.conda(N) )
  if (( ${#EXISTING_PKGS} > 0 )) {
    log "ERROR: BUILD_NUMBER=$BUILD_NUMBER found in $BLD_DIR:"
    for f in $EXISTING
    do
      log "  ${f:t}"
    done
    log "You must bump the build number."
    log "This avoids cache hits and package reuse on GitHub."
    return 1
  }
}

COMMON_M4=common.m4
META_TEMPLATE=$EQR_CONDA/meta-template.yaml

# Default dependencies:
export USE_GCC=${USE_GCC:-1}
export USE_LIBSTDCXX=${USE_LIBSTDCXX:-0}
export USE_TK=${USE_TK:-1}

if [[ ! -e $EQR_HOME/src/configure ]]
then
  log "running bootstrap ..."
  (
    cd $EQR_HOME/src
    ./bootstrap
  )
fi

# Allow platform to modify dependencies
source $EQR_CONDA/$CONDA_PLATFORM/deps.sh

export DATE=${(%)DATE_FMT_S}
m4 -P -I $EQR_CONDA $COMMON_M4 $META_TEMPLATE > meta.yaml
log "wrote $PWD/meta.yaml"

if (( ${#C} )) {
  log "configure-only: exit."
  exit
}

# Backup the old log
LOG=conda-build.log
log "LOG: $LOG"
if [[ -f $LOG ]] {
  mv -v $LOG $LOG.bak
  print
}

# We always depend on swift-t-r now:
CHANNEL_SWIFT=( -c swift-t )

# Disable
# "UserWarning: The environment variable 'X' is being passed through"
export PYTHONWARNINGS="ignore::UserWarning"

{
  log "START: ${(%)DATE_FMT_S}"
  print
  () {
    # Anonymous function for set -x

    log "using python: " $( which python )
    log "using conda:  " $( which conda  )

    BUILD_ARGS=(
      -c conda-forge
      # We always rely on swift-t::swift-t-r now: 2025-04-22
      -c swift-t
      --dirty
      .
    )

    # For 'set -x' including newline:
    PS4="
+ "
    set -x
    # This purge-all is extremely important:
    conda build purge-all

    # Build the package!
    conda build $BUILD_ARGS
  }
  log "BUILD: STOP: ${(%)DATE_FMT_S}"
} |& tee $LOG
print

# Find the "upload" text for the PKG in the LOG,
#      this will give us the PKG file name
log "looking for upload line in ${LOG:a} ..."
UPLOAD=( $( grep -A 1 "anaconda upload" $LOG ) )
PKG=${UPLOAD[-1]}

# Print metadata about the PKG
{
  print
  zmodload zsh/mathfunc zsh/stat
  print PKG=$PKG
  zstat -H A -F "%Y-%m-%d %H:%M" $PKG
  log  "TIME: ${A[mtime]}"
  printf -v T "SIZE: %.1f MB" $(( float(${A[size]}) / (1024*1024) ))
  log $T
  log "HASH:" $( checksum $PKG )
} | tee -a $LOG
print
