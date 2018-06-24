#!/bin/sh
if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
  stty -echo;
fi;
# ...
# before point of intended output:
stty echo && printf -- 'intended output\n';
# silence it again till end of script
stty -echo;
# ...
stty echo;
exit 0;
