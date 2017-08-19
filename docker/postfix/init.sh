#!/usr/bin/dumb-init /bin/bash
service rsyslog start
service postfix start

while true; do
  mysqladmin ping -h mysql >/dev/null 2> /dev/null && break
  sleep 1
done

while true; do
  wget -O- -q sisito:3000 >/dev/null 2> /dev/null && break
  sleep 1
done

while true; do
  TS=$(date +%s)
  echo hello-$TS | mailx -s subject-$TS user-$TS@a.b.c
  /collect.rb
  sleep 10
done
