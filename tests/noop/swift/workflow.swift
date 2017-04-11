
/**
   workflow.swift
   noop project
*/

import io;
import location;
import sys;
import files;

import EQR;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string algo_file = argv("algo_file");

(void v) loop(location loc)
{
  printf("Beginning loop.");
  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    result = EQR_get(loc);
    boolean c;
    if (result == "FINAL")
    {
      printf("setting void") =>
        v = propagate() =>
        c = false;
    }
    else if (result == "EQR_ABORT") {
      printf("EQR aborted: see output for R error") =>
      string why = EQR_get(loc);
      printf("%s", why) =>
      v = propagate() =>
      c = false;
    }
    else
    {
      printf("swift: result: %s", result);
      data = fromint(toint(result) + 1);
      printf("swift: data: %s", data);
      EQR_put(loc, data) => c = true;
    }
  }
}

main() {
  printf("WORKFLOW!");
  location L = locationFromRank(1);
  EQR_init_script(L, algo_file) =>
  loop(L) =>
  EQR_stop(L);
}
