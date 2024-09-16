
# HELPERS ZSH
# Helpers for Anaconda stuff

@()
# Verbose operation
{
  print
  print ${*}
  print
  ${*}
}

DATE_FMT_S="%D{%Y-%m-%d} %D{%H:%M:%S}"
log()
# General-purpose log line
# You may set global LOG_LABEL to get a message prefix
{
  print ${(%)DATE_FMT_S} ${LOG_LABEL:-} ${*}
}

checksum()
{
  # Use redirection to suppress filename in md5 output
  local PKG=$1
  if [[ $PLATFORM =~ osx-* ]] {
    md5 -r < $PKG
  } else {
    md5sum < $PKG
  }
}
