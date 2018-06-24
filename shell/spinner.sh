#!/bin/sh
i=0
sp='/-\|'
n=${#sp}
printf ' '
sleep 0.1
while true; do
    printf '\b%s' "${sp:i++%n:1}"
    sleep 0.1
done
