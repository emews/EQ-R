
# EQ.R
# CONFIGURE.AC

# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT([EQ.R], [0.1], [wozniak@mcs.anl.gov])
AC_CONFIG_SRCDIR([BlockingQueue.h])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CPP
AC_PROG_MAKE_SET

# SWIG
AC_PATH_PROG([SWIG],[swig],[nope])
[[ ${SWIG} == "nope" ]] && AC_MSG_ERROR([Could not find SWIG!])

# Tcl, adapted from turbine configure.ac

DPKG_ARCH=
# Debian distros may put in architecture-specific subdirectory
if which dpkg-architecture > /dev/null 2>&1
then
  DPKG_ARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)
  AC_MSG_RESULT([dpkg-architecture: ${DPKG_ARCH}])
fi

# Set shared object suffix (.so on Linux, .dylib on Mac)
SO_SUFFIX=so
if [[ $(uname) = "Darwin" ]]
then
   SO_SUFFIX=dylib
fi

# Tcl version is initially unknown (needed by find-tcl.sh)
export TCL_VERSION=0

# In order from most to least preferred
TCL_VERSION_PREFS="8.6 8.5"

AC_ARG_WITH(tcl-version,
    AS_HELP_STRING([--with-tcl-version],
                   [Tcl version. Minimum is 8.5. If not specified,
                    use highest version we can find]),
    [
        TCL_VERSION=${withval}
        AC_MSG_NOTICE([user specified Tcl version ${TCL_VERSION}])
        LIBTCL=libtcl${TCL_VERSION}.${SO_SUFFIX}
    ],
    [
        AC_MSG_NOTICE([Tcl version is not specified.])
    ]
)

USE_TCL=0
# Set USE_TCL
AC_ARG_WITH(tcl,
    AS_HELP_STRING([--with-tcl], [location of Tcl]),
    [
        AC_MSG_RESULT([using Tcl: ${withval}])
        USE_TCL=${withval}
    ],
    [
      AC_MSG_NOTICE([Tcl location not specified, trying to find tclsh on path])
      for TCLVER in ${TCL_VERSION_PREFS}
      do
        AC_MSG_CHECKING([for tclsh${TCLVER} on path])
        program=$( which tclsh${TCLVER} 2>&1 )
        if [[ ${?} == 0 ]]
        then
          AC_MSG_RESULT([yes: ${program}])
          USE_TCL=$( cd $(dirname ${program})/.. ; /bin/pwd )
          AC_MSG_RESULT([Found Tcl at ${USE_TCL}]);
          break
        else
          AC_MSG_RESULT([no])
        fi
      done

      if [[ ${USE_TCL} == 0 ]]
      then
        AC_MSG_ERROR([Could not find tclsh for any version: ${TCL_VERSION_PREFS}!])
      fi
    ]
)

USE_TCL_LIB_DIR=0

AC_ARG_WITH(tcl-lib-dir,
    AC_HELP_STRING([--with-tcl-lib-dir],
                   [directory containing Tcl shared library]),
    [
        USE_TCL_LIB_DIR=${withval}
        AC_MSG_RESULT([using Tcl lib dir: ${USE_TCL_LIB_DIR}])
    ])

if [[ ${TCL_VERSION} != 0 ]]
then
  # We have locked in a version choice
  TCL_VERSION_PREFS=${TCL_VERSION}
fi

USE_LIBTCL_SO=

# Check in order from most to least preferred
for TCLVER in ${TCL_VERSION_PREFS}
do

  if [[ ${USE_TCL_LIB_DIR} == 0 ]]
  then
    LIB_DIR_OPTS="${USE_TCL}/lib ${USE_TCL}/lib64"

    # Debian distros may put in architecture-specific subdirectory
    if [[ ! -z "${DPKG_ARCH}" ]]
    then
      LIB_DIR_ARCH_OPTS=""
      for opt in $LIB_DIR_OPTS
      do
        LIB_DIR_ARCH_OPTS+=" $opt/${DPKG_ARCH}"
      done
      LIB_DIR_OPTS="$LIB_DIR_OPTS $LIB_DIR_ARCH_OPTS"
    fi
  else
    LIB_DIR_OPTS="${USE_TCL_LIB_DIR}"
  fi


  for LIB_DIR in ${LIB_DIR_OPTS}
  do
    test -d ${LIB_DIR} || continue
    LIB_DIR=$( cd ${LIB_DIR} ; /bin/pwd ) # Canonicalize
    LIBTCL_PREFIX=libtcl${TCLVER}
    LIBTCL=${LIBTCL_PREFIX}.${SO_SUFFIX}
    AC_MSG_CHECKING([for Tcl library at ${LIB_DIR}/${LIBTCL}])
    if [[ -r ${LIB_DIR}/${LIBTCL} ]]
    then
    AC_MSG_RESULT([yes])
    TCL_VERSION=${TCLVER}
    USE_TCL_LIB_DIR=${LIB_DIR}

    # We found the library - work out which variants are present
    MAYBE_LIBTCL_SO="${LIB_DIR}/${LIBTCL_PREFIX}.${SO_SUFFIX}"
    if [[ -r "${MAYBE_LIBTCL_SO}" ]]
    then
      USE_LIBTCL_SO="${MAYBE_LIBTCL_SO}"
    fi
    break 2
    else
      AC_MSG_RESULT([no])
    fi
  done
done

if [[ -z "${USE_LIBTCL_SO}" ]]
then
    AC_MSG_ERROR([could not find libtcl!])
fi

AC_MSG_RESULT([using Tcl version: ${TCL_VERSION}])
AC_MSG_RESULT([Tcl shared library: ${USE_LIBTCL_SO}])

# Set USE_TCL_CFG_DIR: location of tclConfig.sh
USE_TCL_CFG_DIR=0

# This is a location used e.g. by the APT tcl8.6-dev package.
# Put first to maximize chance of getting Tcl version correct
TCL_CFG_DIR_ALTS="${USE_TCL_LIB_DIR}/tcl${TCL_VERSION}"
# This location is for Tcl installation from source
TCL_CFG_DIR_ALTS+=" ${USE_TCL_LIB_DIR}"

for TCL_CFG_DIR_ALT in $TCL_CFG_DIR_ALTS
do
  AC_MSG_CHECKING([for tclConfig.sh at ${TCL_CFG_DIR_ALT}])
  if [[ -r "$TCL_CFG_DIR_ALT/tclConfig.sh" ]]
  then
    USE_TCL_CFG_DIR="${TCL_CFG_DIR_ALT}"
    AC_MSG_RESULT([found])
    break
  else
    AC_MSG_RESULT([no])
  fi
done

if [[ ${USE_TCL_CFG_DIR} == 0 ]]
then
    AC_MSG_ERROR([Could not find tclConfig.sh!])
fi
AC_MSG_RESULT([using tclConfig.sh in: ${USE_TCL_CFG_DIR}/])

# Make copy of old version since it can be clobbered by tclConfig.sh
TCL_OLD_VERSION="$TCL_VERSION"

# Source tclConfig.sh to obtain Tcl settings
source ${USE_TCL_CFG_DIR}/tclConfig.sh
if [[ ${?} != 0 ]]
then
    AC_MSG_ERROR([could not source: ${USR_TCL_CFG_DIR}/tclConfig.sh])
fi
if [[ "$TCL_VERSION" != "$TCL_OLD_VERSION" ]]
then
  AC_MSG_ERROR([${USE_TCL_CFG_DIR}/tclConfig.sh is not for appropriate \
      Tcl version.  Expected ${TCL_OLD_VERSION} but got ${TCL_VERSION}])
fi

# Find tclsh binary name (may be tclsh8.5)
AC_MSG_RESULT([checking for Tcl executable in ${USE_TCL} ...])
USE_TCLSH=$( ./find-tcl.sh ${USE_TCL} )
if [[ ${?} != 0 ]]
then
    AC_MSG_ERROR([Could not find Tcl ${TCL_VERSION} executable in ${USE_TCL}!])
fi

AC_MSG_RESULT([using Turbine Tcl executable: ${USE_TCLSH}])

# Now, allow user to override Tcl include
AC_ARG_WITH(tcl-include,
            AS_HELP_STRING(
               [--with-tcl-include],
               [directory containing tcl.h]),
            [AC_CHECK_FILE(${withval}/tcl.h,[],[FAIL=1])
             [[ ${FAIL} == 1 ]] &&
               AC_MSG_ERROR(Could not find tcl.h in ${withval})
             AC_MSG_RESULT([using Tcl include: ${withval}/tcl.h])
             TCL_INCLUDE_SPEC=-I${withval}
            ],
            [])

AC_SUBST(USE_TCL_LIB_DIR)
AC_SUBST(USE_TCLSH)
AC_SUBST(TCL_INCLUDE_SPEC)
AC_SUBST(TCL_LIB_SPEC)

AC_PREFIX_DEFAULT($PWD/..)

# We only need C++
AC_LANG(C++)

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL

# R, adapted from turbine configure.ac

HAVE_R=0
USE_R=0
USE_R_INCLUDE=0
RCPP_PATH=0
RINSIDE_PATH=0

AC_ARG_WITH(rinside,
   AS_HELP_STRING([--with-rinside],
                   [Use this RInside directory]),
   [
      HAVE_R=1
      RINSIDE_PATH=${withval}
   ])

AC_ARG_WITH(rcpp,
   AS_HELP_STRING([--with-rcpp],
                   [Use this Rcpp directory]),
   [
      HAVE_R=1
      RCPP_PATH=${withval}
   ])

AC_ARG_WITH(r,
   AS_HELP_STRING([--with-r],
                   [Use this R directory]),
  [
      HAVE_R=1
      USE_R=${withval}
  ])

if (( ${HAVE_R} == 0 ))
then
    # Look for R in PATH
    AC_MSG_RESULT([Looking for R in PATH ...])
    TRY=$( which R )
    if [[ -x ${TRY} ]]
    then
        HAVE_R=1
        AC_MSG_RESULT([Found executable: ${TRY}])
        USE_R=$( readlink --canonicalize $( dirname ${TRY} )/.. )
        AC_MSG_RESULT([Setting R location: ${USE_R}])
    fi
fi

if (( ${HAVE_R} == 1 ))
then
  R_BIN=$( readlink --canonicalize ${USE_R}/../../bin )
  AC_MSG_RESULT([Adding to PATH: ${R_BIN}])
  PATH=${R_BIN}:${PATH}

  AC_CHECK_FILE(${USE_R}/include/R.h,
                [USE_R_INCLUDE=${USE_R}/include])
  if [[ ${USE_R_INCLUDE} = 0 ]]
  then
      # This is in APT package r-base-core:
      AC_CHECK_FILE(${USE_R}/lib64/R/include/R.h,
                    [USE_R_INCLUDE=${USE_R}/lib64/R/include])
  fi

  if [[ ${USE_R_INCLUDE} = 0 ]]
  then
      # This is in APT package r-base-core:
      AC_CHECK_FILE(${USE_R}/share/R/include/R.h,
                    [USE_R_INCLUDE=${USE_R}/share/R/include])
  fi

  if [[ ${USE_R_INCLUDE} = 0 ]]
  then
      AC_MSG_WARN([Never found R header!])
  fi

  AC_MSG_RESULT([Setting: USE_R_INCLUDE=${USE_R_INCLUDE}])

  if [[ ${RINSIDE_PATH} == 0 ]]
  then
    AC_CHECK_PROG(RSCRIPT, Rscript, Rscript)
    if [[ ! -z ${RSCRIPT} ]]
    then
      R_LIB_PATHS=" ${USE_R} "
      # returned in order of precedence so we want to
      # reverse so that the last overrides the first
      R_LIB_PATHS+="$(Rscript -e 'cat(rev(.libPaths()))')"
      for p in $R_LIB_PATHS
      do
        AC_CHECK_FILE(${p}/RInside, [RINSIDE_PATH=${p}/RInside], [])
      done
    else
      RINSIDE_PATH=${USE_R}/RInside
    fi
  fi

  if [[ ${RCPP_PATH} == 0 ]]
  then
    AC_CHECK_PROG(RSCRIPT, Rscript, Rscript)
    if [[ "${RSCRIPT:-}" != "" ]]
    then
      R_LIB_PATHS="${USE_R} "
      # returned in order of precedence so we want to
      # reverse so that the last overrides the first
      R_LIB_PATHS+="$(Rscript -e 'cat(rev(.libPaths()))')"
      for p in ${R_LIB_PATHS}
      do
        AC_CHECK_FILE(${p}/Rcpp, [RCPP_PATH=${p}/Rcpp], [])
      done
    else
      RCPP_PATH=${USE_R}/Rcpp
    fi
  fi

  AC_CHECK_FILE(${RINSIDE_PATH}/include/RInside.h, [],
                 [AC_MSG_ERROR([Could not find RInside header!])])
  AC_CHECK_FILE(${RCPP_PATH}/include/Rcpp.h, [],
                 [AC_MSG_ERROR([Could not find Rcpp header!])])

  # C++ is only required if we enable R
  AC_PROG_CXX
  LD=${CXX}
else # ! HAVE_R
  AC_MSG_WARN([Never found R!])
fi # if HAVE_R
AC_DEFINE_UNQUOTED([HAVE_R],$HAVE_R,[Enables R])
AC_SUBST(USE_R)
AC_SUBST(USE_R_INCLUDE)
AC_SUBST(RINSIDE_PATH)
AC_SUBST(RCPP_PATH)

AC_CONFIG_FILES([Makefile settings.mk])
AC_OUTPUT
