
# osx-64 (Intel) BUILD SH
# Simply calls build-generic.
# `conda build` calls this as Bash.

echo "build.sh: START"

DEV_CONDA=$( cd $RECIPE_DIR/.. ; /bin/pwd -P )

(
  set -eu

  SDK=$( xcrun --show-sdk-path )
  LDFLAGS="-L$SDK/usr/lib -lSystem "
  LDFLAGS+="-F$SDK/System/Library/Frameworks"



  # This is needed for osx-64
  LDFLAGS+=" -L$BUILD_PREFIX/lib -ltcl8.6"
  export LDFLAGS

  echo "build.sh: calling build-generic.sh ..."
  $DEV_CONDA/build-generic.sh
)

echo "build.sh: STOP"
