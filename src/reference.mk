
# Everyone's old build settings for reference

HOST = $(shell hostname)

INCLUDES :=
LIBS :=
RPATHS :=

# Ubuntu, R built from source
ifeq ($(HOST),umbra)
    # Run with export LD_LIBRARY_PATH=$HOME/sfw/R-3.0.1/lib/R/lib

    R_HOME = $(HOME)/sfw/R-3.0.1

    INCLUDES += -I $(R_HOME)/lib/R/include
    INCLUDES += -I $(R_HOME)/lib/R/library/RInside/include
    INCLUDES += -I $(R_HOME)/lib/R/library/Rcpp/include

    LIBS += -L $(R_HOME)/lib/R/library/RInside/lib -l RInside
    LIBS += -L $(R_HOME)/lib/R/lib -l R -l Rblas
    LIBS += -L $(R_HOME)/lib -l R -l Rblas

    RPATHS += -Wl,-rpath -Wl,$(R_HOME)/lib/R/library/RInside/lib
    RPATHS += -Wl,-rpath -Wl,$(R_HOME)/lib/R/lib

    TCL_HOME = $(HOME)/sfw/tcl-8.6.0
    TCL_INCLUDE = $(TCL_HOME)/include
    TCL_LIB     = $(TCL_HOME)/lib
    TCLSH       = $(TCL_HOME)/bin/tclsh8.6

    SED_I = sed -i
endif

# Ubuntu, R from APT package
ifeq ($(HOST),Aspire)
    R_LIBRARY = $(HOME)/R/i686-pc-linux-gnu-library/3.0
    INCLUDES += -I /usr/share/R/include
    INCLUDES += -I $(R_LIBRARY)/RInside/include
    INCLUDES += -I $(R_LIBRARY)/Rcpp/include
    LIBS += -L $(R_LIBRARY)/RInside/lib -l RInside
    LIBS += -l R -l blas
    RPATHS += -Wl,-rpath -Wl,$(R_LIBRARY)/RInside/lib

    TCL_HOME = $(HOME)/sfw/tcl-8.6.1
    TCL_INCLUDE = $(TCL_HOME)/include
    TCL_LIB     = $(TCL_HOME)/lib

    SED_I = sed -i
endif

# Mac, R built from source
ifeq ($(HOST),frisbee.mcs.anl.gov)
    R_HOME = $(HOME)/sfw/mac/R-3.2.2
    R_RESOURCES = $(R_HOME)/R.framework/Versions/3.2/Resources
    R_LIBRARY = $(R_RESOURCES)/library
    R_LIB = $(R_RESOURCES)/lib
    INCLUDES += -I $(R_RESOURCES)/include
    INCLUDES += -I $(R_LIBRARY)/RInside/include
    INCLUDES += -I $(R_LIBRARY)/Rcpp/include
    LIBS += -L $(R_LIBRARY)/RInside/lib -l RInside
    LIBS += -L $(R_LIB) -l R -l Rblas
    RPATHS += -Wl,-rpath -Wl,$(R_LIBRARY)/RInside/lib
    RPATHS += -Wl,-rpath -Wl,$(R_LIB)

    TCL_HOME = $(HOME)/sfw/tcl-8.5.11-mac
    TCLSH       = $(TCL_HOME)/bin/tclsh8.5
    TCL_INCLUDE = $(TCL_HOME)/include
    TCL_LIB     = $(TCL_HOME)/lib
    TCL_VERSION = 8.5

    SED_I = sed -i '' # Mac BSD weirdness
endif

# Cray, R built from source
ifneq ($(findstring beagle,$(HOST)),)
    # Run with export LD_LIBRARY_PATH=R_HOME/lib64/R/lib
    R_HOME = /home/wozniak/Public/sfw/x86_64/R-3.2.2
    R_LIBRARY = $(R_HOME)/lib64/R/library
    INCLUDES += -I $(R_HOME)/lib64/R/include
    INCLUDES += -I $(R_LIBRARY)/RInside/include
    INCLUDES += -I $(R_LIBRARY)/Rcpp/include
    LIBS += -L $(R_LIBRARY)/RInside/lib -l RInside
    R_LIB = $(R_HOME)/lib64/R/lib
    LIBS += -L $(R_LIB) -l R -l Rblas
    RPATHS += -Wl,-rpath -Wl,$(R_LIBRARY)/RInside/lib
    RPATHS += -Wl,-rpath -Wl,$(R_LIB)

    TCL_HOME = $(HOME)/Public/tcl-8.5.9
    TCL_VERSION = 8.5
    TCLSH       = $(TCL_HOME)/bin/tclsh$(TCL_VERSION)
    TCL_INCLUDE = $(TCL_HOME)/include
    TCL_LIB     = $(TCL_HOME)/lib

    SED_I = sed -i
endif

ifeq ($(HOST),XioMBP.local) #
    R_HOME = $(HOME)/sfw/mac/R-3.2.2
    R_RESOURCES = $(R_HOME)/R.framework/Versions/3.2/Resources
    R_LIBRARY = $(R_RESOURCES)/library
    R_LIB = $(R_RESOURCES)/lib

    R_HOME = /Library/Frameworks/R.framework/Versions/3.2/Resources
    R_USER_LIBS = ~/Library/R/3.2/library

    INCLUDES += -I $(R_HOME)/include
    INCLUDES += -I $(R_USER_LIBS)/RInside/include
    INCLUDES += -I $(R_USER_LIBS)/Rcpp/include

    LIBS += -L $(R_USER_LIBS)/RInside/lib -l RInside
    LIBS += -L $(R_HOME)/lib -l R -l Rblas

    RPATHS += -Wl,-rpath -Wl,$(R_USER_LIBS)/RInside/lib
    RPATHS += -Wl,-rpath -Wl,$(R_HOME)/lib/R/lib

    TCL_INCLUDE = /usr/local/include
    TCL_LIB     = /usr/local/lib
    TCLSH       = /usr/local/bin/tclsh8.6
    TCL_VERSION = 8.6

    SED_I = sed -i '' # Mac BSD weirdness
endif

ifeq ($(findstring blogin,$(HOST)),blogin) #
    R_HOME = /soft/R/src/R-3.2.2
    R_LIBRARY = $(R_HOME)/library
    R_LIB = $(R_HOME)/lib

    R_USER_LIBS = ~/R/x86_64-pc-linux-gnu-library/3.2

    INCLUDES += -I $(R_HOME)/include
    INCLUDES += -I $(R_USER_LIBS)/RInside/include
    INCLUDES += -I $(R_USER_LIBS)/Rcpp/include

#    LIBS += -L /soft/gcc/4.9.3/lib64/ -lstdc++
    LIBS += -L $(R_USER_LIBS)/RInside/lib -lRInside
    LIBS += -L $(R_HOME)/lib -l R -lRblas

   # RPATHS += -Wl,-rpath -Wl,/soft/gcc/4.9.3/lib64
    RPATHS += -Wl,-rpath -Wl,$(R_USER_LIBS)/RInside/lib
    RPATHS += -Wl,-rpath -Wl,$(R_HOME)/lib/R/lib

    TCL_INCLUDE = /usr/include
    TCL_LIB     = /usr/lib
    TCLSH       = /usr/bin/tclsh8.5
    TCL_VERSION = 8.5
    SED_I = sed -i
endif
