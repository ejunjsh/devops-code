#!/bin/sh
# ...
if [ "$?" != "0" ]; then
  printf -- 'X happened. Exiting with status code 1.\n';
  exit 1;
fi;
# ...
if [ "$?" != "0" ]; then
  printf -- 'Y happened. Exiting with status code 2.\n';
  exit 2;
fi;
