#!/bin/sh
error_handle() {
  stty echo;
}
if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
  stty -echo;
  trap error_handle INT;
  trap error_handle TERM;
  trap error_handle KILL;
  trap error_handle EXIT;
fi;
# ...
