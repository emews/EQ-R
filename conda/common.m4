m4_dnl common.m4 : Reusable M4 functions
m4_dnl This file must have a newline at the end for OSX.
m4_dnl Simply remove this text:
m4_changecom(`dnl')m4_dnl
m4_define(`COMMENT', `')m4_dnl
m4_dnl This simply does environment variable substition when m4 runs:
m4_define(`m4_getenv',  `m4_esyscmd(printf -- "$`$1'")')m4_dnl
