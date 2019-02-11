FROM ruby:2.4

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:jonathonf/vim -y
RUN apt install -y vim-gtk3 exuberant-ctags xvfb

RUN mkdir /vim-test
WORKDIR /vim-test

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

ENV DISPLAY :99.0
