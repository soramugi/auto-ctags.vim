FROM ruby:2.4

RUN add-apt-repository ppa:jonathonf/vim -y && apt update && apt install vim-gtk3 && apt install exuberant-ctags && apt install xvfb

RUN mkdir /vim-test
WORKDIR /vim-test

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

ENV DISPLAY :99.0
