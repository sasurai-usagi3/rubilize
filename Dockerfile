FROM ubuntu:latest
MAINTAINER Takumu Uyama
ARG APP_NAME=rubilize
ARG MODE=development
RUN apt-get update && apt-get -y upgrade && apt-get -y install software-properties-common tzdata
RUN apt-get -y install libcurl4-openssl-dev libapr1-dev libaprutil1-dev libxml2 libxslt-dev libffi-dev build-essential patch libssl-dev git libreadline-dev curl libmecab2 libmecab-dev mecab mecab-ipadic mecab-ipadic-utf8 mecab-utils
RUN cd /usr/local && git clone https://github.com/sstephenson/rbenv.git .rbenv && git clone https://github.com/sstephenson/ruby-build.git .rbenv/plugins/ruby-build
ENV RBENV_ROOT=/usr/local/.rbenv PATH="/usr/local/.rbenv/bin:$PATH"
RUN rbenv install 2.5.0 && rbenv global 2.5.0 && rbenv rehash && eval "$(rbenv init -)" && gem install bundler passenger --no-document && passenger-install-nginx-module --auto
RUN echo 'export RBENV_ROOT=/usr/local/.rbenv\nexport PATH="/usr/local/.rbenv/bin:$PATH"\neval "$(rbenv init -)"' >> ~/.bashrc
COPY ./$MODE/nginx.conf /opt/nginx/conf
RUN mkdir -p /var/www/html/$APP_NAME && /opt/nginx/sbin/nginx -t
RUN useradd -b /bin/false $APP_NAME
WORKDIR /var/www/html/$APP_NAME
CMD /opt/nginx/sbin/nginx && tail -f /dev/null
