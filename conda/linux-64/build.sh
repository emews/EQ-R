
# linux-64 BUILD SH
# Simply calls build-generic.
# `conda build` calls this as Bash.

echo "build.sh: START"

EQR_CONDA=$( cd $RECIPE_DIR/.. ; /bin/pwd -P )

(
  set -x
  $EQR_CONDA/build-generic.sh
)

echo "build.sh: STOP"
