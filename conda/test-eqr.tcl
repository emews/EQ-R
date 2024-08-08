
# TEST EQR TCL
# Simple test that R loads correctly from Tcl stack
# This usage of libeqr.so is not totally legit,
# as the R object is used by the worker thread.

if { [ llength $argv ] != 1 } {
  puts "test-eqr: provide the /path/to/libeqr.so"
  exit 1
}

puts "test-eqr: load: $argv"

load $argv

initR /dev/null

testR HELLO

stopIt
puts "test-eqr: OK"
