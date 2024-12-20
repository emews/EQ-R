
/**
   EQR.h
   Plain C++ API
   Some functions exposed directly to SWIG
   Some functions wrapped by QueueFuncsTcl
 */

#pragma once

#include <string>

void initR(std::string script_file);

std::string OUT_get(void);

void IN_put(std::string val);

bool EQR_is_initialized();

void stopIt(void);

void deleteR(void);

void testR(std::string s);
