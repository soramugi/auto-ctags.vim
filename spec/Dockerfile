FROM ruby:2.4

RUN apt-get update && apt-get install -y vim-gtk exuberant-ctags xvfb

RUN mkdir /vim-test
WORKDIR /vim-test

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

ENV DISPLAY :99.0
