# EQ-R
EMEWS Queues - R implementation

EQ-R is a Swift/T (http://swift-lang.org/Swift-T/) extension that
allows Swift/T workflows to communicate with a persistent embedded R interpreter
on a worker process via blocking queues. Using the mechanism an R model
exploration (ME) algorithm can be used to control and define an ensemble
of model runs.

File index
==========

``BlockingQueue.h``
  A queue for inter-thread communication.

``EQR.h EQR.cpp``
  The main functionality to enable EQ-R- thread and queue control
  interfaces for access from Tcl and Swift.

``EQR.i``
  The SWIG interface file for EQ-R.

``settings.template.sh``
  Contains example compilier settings for compling EQ-R.

``settings.mk.in``
  Filters into ``settings.mk`` at configure time.  This can be
  ``include`` <!--- --> by other Makefiles to obtain build settings, for
  example, to compile task code that will be called from Swift.

Build
=====

Outline
-------
``./bootstrap``

``cp settings.template.sh settings.sh`` and edit

``source settings.sh``

``./configure ...``

``make install``

Details
-------

Run ``./bootstrap``.  This runs ``autoconf`` and generates ``./configure``.

Then, you need to set ``CPPFLAGS``, ``CXXFLAGS``, and ``LDFLAGS``.
The recommended way to do this is to make a personal copy of
``settings.template.sh``, edit it to contain your settings, and source
it.

Then, run ``./configure``.  You can use ``./configure --help``.  Key
settings are:

* ``--prefix``: EQ.R install location. This defaults to $PWD/.. for
compatibility with EMEWS templates (https://github.com/emews/emews-lazybones-templates)
* ``--enable-mac-bsd-sed``: For Mac users
* ``--with-tcl-version=8.5``: If you are using Tcl 8.5

Then do ``make install``.

You can do ``make clean`` or ``make distclean``.

Troubleshooting
-------
**./configure halts with "checking whether the C++ compiler works... no"**

To inspect what went went wrong, you will have to look in the generated
config.log .  Check that your compiler settings in settings.sh are correct, the library locations in particular.
