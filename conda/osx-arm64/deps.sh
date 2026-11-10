
# osx-arm64 DEPS SH

# For OSX/ARM64, we rely on these in the system:
USE_ANT=0
USE_GCC=0
USE_ZSH=0

# For OSX/ARM64, this dependency must be explicit:
USE_TK=1

# Pin the one good tk 8.6.13 build (see swift-t deps.sh for why).
export SPEC_TK='tk==8.6.13=hbeba79b_4'
