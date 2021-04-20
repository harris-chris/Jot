#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main( int argc, char *argv[] )
{
  char *buffer;
  char argstring[2048];
  int i = 1;
  for(i = 1; i < argc; i++){
    strcat(argstring, " ");
    strcat(argstring, argv[i]);
  }
  /*printf("ARGSTRING %s\n", argstring);*/
  char script[] = "\
  #/bin/bash\n\
  julia ./src/julia-for-aws-lambda.jl%s\
  ";
  char command[2048];
  sprintf(command, script, argstring);
  return system(command);
}
