FROM ruby:3.3-alpine

RUN apk add --no-cache --virtual \
        build-dependencies \
        build-base \
        cargo \
        clang17-libclang \
        clang-dev \
        curl \
        git \
        ruby-dev \
        rust \
        postgresql-dev \
        yaml-dev

WORKDIR /srv/app

ADD Gemfile Gemfile.lock ./
RUN bundle config --global silence_root_warning 1
RUN bundle install

ADD . ./

EXPOSE 9000
