#!/bin/sh
CURR_DIR="$(dirname $0)"
printf -- 'moving application to /opt/app.jar';
mv "${CURR_DIR}/application.jar" /opt/app.jar;
