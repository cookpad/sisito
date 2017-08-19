FROM ubuntu:xenial-20170802

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y tzdata
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -y build-essential ruby ruby-dev libxml2-dev libxslt-dev wget mysql-client libmysqlclient-dev curl nodejs

RUN gem install bundler

ARG ENTRYKIT_VERSION=0.4.0
RUN wget -O- -q https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zxf - && \
    mv entrykit /bin/entrykit && \
    chmod +x /bin/entrykit && \
    entrykit --symlink

RUN mkdir /tmp/sisito
COPY Gemfile /tmp/sisito
COPY Gemfile.lock /tmp/sisito
RUN cd /tmp/sisito && bundle install -j4 --deployment

RUN mkdir -p /var/www/sisito/tmp/pids
COPY . /var/www/sisito

RUN cp -a /tmp/sisito/.bundle /tmp/sisito/vendor /var/www/sisito/

COPY docker/ /

WORKDIR /var/www/sisito

ENTRYPOINT [ \
  "switch", \
    "shell=/bin/bash", \
  "--", \
  "prehook", \
    "bash /migrate.sh", \
  "--", \
  "/usr/local/bin/bundle", "exec", "rails", "server", "-b", "0.0.0.0" \
]