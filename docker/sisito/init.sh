#!/usr/bin/dumb-init /bin/bash
mailcatcher --http-ip 0.0.0.0
/usr/local/bin/bundle exec rails server -b 0.0.0.0
