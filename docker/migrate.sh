#!/bin/bash
while true; do
  mysqladmin ping -h mysql && break
  sleep 1
done

bundle exec rails db:create db:migrate
