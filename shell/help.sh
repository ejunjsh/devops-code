#!/bin/sh
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- '...help...\n';
  exit 0;
fi;
