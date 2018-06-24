#!/bin/sh
_=$(command -v docker);
if [ "$?" != "0" ]; then
  printf -- "You don\'t seem to have Docker installed.\n";
  printf -- "Get it: https://www.docker.com/community-edition\n";
  printf -- "Exiting with code 127...\n";
  exit 127;
fi;
