
/**
   EQR.cpp
   Implementation of C++ functionality,
   including using of queues, thread, and R
 */

#include <fstream>
#include <iostream>
#include <random>
#include <thread>

#include "BlockingQueue.h"
#include "EQR.h"

#include "RInside.h"

using namespace std;
using namespace Rcpp;

static RInside* r = nullptr;
static thread worker;

static BlockingQueue<string> IN, OUT;

#define ENABLE_LOGGING 0
#if ENABLE_LOGGING
#define LOG(x) cout << x << endl
#else
#define LOG(x)
#endif

static void do_work(RInside& r_inside, const string& script_file) {

  LOG("do_work()...");
  ifstream t(script_file);
  string str((istreambuf_iterator<char>(t)),
                  istreambuf_iterator<char>());

  if (! t.good())
  {
    cout << "ERROR with script file: " << script_file << endl;
    exit(1);
  }

  LOG("parseEvalQ()...");
  r_inside.parseEvalQ(str);
  LOG("parseEvalQ(): done.");
}

// To be called from R
void OUT_put(const string& value);

// To be called from R
string IN_get();

void initR(string script_file) {
  int argc = 0;
  char** argv = 0;

  LOG("initR: " << script_file);

  if (r == nullptr) {
    r = new RInside(argc, argv);
    (*r)["OUT_put"] = Rcpp::InternalFunction(&OUT_put);
    (*r)["IN_get"]  = Rcpp::InternalFunction(&IN_get);
  }

  worker = thread(do_work, ref(RInside::instance()), script_file);
}

bool EQR_is_initialized() {
  return r != nullptr;
}

// To be called from R
void OUT_put(const string& value) {
  LOG("OUT_put: " << value);
  OUT.push(value);
}

// To be called from R
string IN_get() {
  LOG("IN_get()...");
  string value = IN.pop();
  LOG("IN_get:  " << value);
  return value;
}

// To be called from client code (e.g., Swift/T)
string OUT_get() {
  LOG("OUT_get()");
  string s = OUT.pop();
  LOG("OUT_get: " << s);
  return s;
}

// To be called from client code (e.g., Swift/T)
void IN_put(string val) {
  LOG("IN_put(): " << val);
  IN.push(val);
}

// To be called from client code (e.g., Swift/T)
void stopIt() {
  LOG("stopIt()");
  worker.join();
}

void deleteR() {
  LOG("deleteR()");
  delete r;
}
