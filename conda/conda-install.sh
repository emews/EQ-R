#!/bin/zsh
set -eu

# CONDA INSTALL
# Install script for use by maintainers when testing PKGs.
# Normally you will want to use a different fresh Conda
#          from the Conda you used to build the PKG.
# Provide the PKG on the command line.
# NOTE: conda install from file does not install dependencies!
#       Cf. https://docs.anaconda.com/free/anaconda/packages/install-packages
#       Thus this script installs dependencies using PLATFORM/deps.sh
# NOTE: Keep LIST in sync with meta.yaml

help()
{
  cat <<EOF
USAGE: Provide PKG
       Provide -D to skip installing dependencies
       Provide -P PLATFORM to change the PLATFORM
               (else auto-detected from PKG directory)
               This is used when e.g. installing a PKG
               from a failed conda-build that is left in conda-bld/broken/
       Provide -s SOLVER to change the conda solver [classic,mamba]
EOF
}

# Parse the user options!
zparseopts -D -E h=H D=D P:=P r=R s:=S

# Default behavior:
INSTALL_DEPS=1
SOLVER=()

# Handle user flags:
if (( ${#H} )) { help ; return }
if (( ${#D} )) INSTALL_DEPS=0
if (( ${#S} )) SOLVER=( --solver ${S[2]} )

if (( ${#*} != 1 )) abort "conda-install.sh: Provide PKG!"
PKG=$1

# Report information about given PKG:
print "PKG=$PKG"
# PKG is of form
# ANACONDA/conda-bld/PLATFORM/eqr-V.V.V-pyVVV.tar.bz2
if (( ${#P} )) {
  PLATFORM=${P[2]}
} else {
  # Pull out PLATFORM directory (head then tail):
  PLATFORM=${PKG:h:t}
}

# Force solver=classic on osx-arm64
if [[ $PLATFORM == "osx-arm64" ]] SOLVER=( --solver classic )

# Bring in utilities
# Get this directory (absolute):
EQR_CONDA=${0:A:h}
# The EQ/R Git clone:
EQR_TOP=${EQR_CONDA:h:h}
source $EQR_CONDA/helpers.zsh

# Echo back platform and package statistics to the user
print "PLATFORM=$PLATFORM"
zmodload zsh/stat zsh/mathfunc
zstat -H A -F "%Y-%m-%d %H:%M" $PKG
printf "PKG: timestamp: %s size: %.1f MB\n" \
       ${A[mtime]} $(( float(${A[size]}) / (1024*1024) ))
printf "md5sum: "
# In DEV_CONDA/helpers.zsh:
checksum $PKG
print

# Report information about active Python/Conda:
if ! which conda >& /dev/null
then
  print "No conda!"
  return 1
fi

print "using python:" $( which python )
print "using conda: " $( which conda )
print

conda env list

# Defaults:
USE_ANT=1
USE_GCC=1
USE_ZSH=1

source $EQR_CONDA/$PLATFORM/deps.sh

# Build dependency list:
LIST=( python )
if (( USE_GCC )) LIST+=gcc

# R switch
if [[ $PLATFORM == "osx-arm64" ]] {
  LIST+="swift-t::emews-rinside"
} else {
  # Use plain r on all other platforms:
  LIST+=r
}

# Run conda install!
set -x
if (( INSTALL_DEPS )) conda install --yes $SOLVER -c conda-forge $LIST
conda install --yes $SOLVER $PKG
