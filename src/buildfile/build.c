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
  char script[] = "\
  #/bin/bash\n\
  julia --project -e \"using Jot; Jot.main(\\\"%s\\\")\" \
  ";
  char command[2048];
  sprintf(command, script, argstring);
  /*printf("COMMAND %s\n", command);*/
  return system(command);
}
