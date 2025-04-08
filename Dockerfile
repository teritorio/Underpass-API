FROM ruby:3.3-alpine

RUN apk add --no-cache --virtual \
        build-dependencies \
        build-base \
        git \
        ruby-dev \
        postgresql-dev \
        yaml-dev

WORKDIR /srv/app

ADD Gemfile Gemfile.lock ./
RUN bundle config --global silence_root_warning 1
RUN bundle install
RUN cd /usr/local/bundle/bundler/gems/overpass_parser-rb-*/ext/overpass_parser/ && make

ADD . ./

EXPOSE 9000
