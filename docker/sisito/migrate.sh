#!/bin/bash
while true; do
  mysqladmin ping -h mysql >/dev/null 2> /dev/null && break
  sleep 1
done

bundle exec rails db:create db:migrate
