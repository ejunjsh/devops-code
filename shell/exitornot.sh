#!/bin/sh
set +e;
./script-1;
./script-2; # does not depend on ./script-1
./script-3; # does not depend on ./script-2
set -e;
./script-4;
./script-5; # depends on success of ./script-4
# ...
