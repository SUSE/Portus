FROM rails:4.2.2
MAINTAINER Flavio Castelli <fcastelli@suse.com>

RUN mkdir /portus
WORKDIR /portus
ADD . /portus
RUN bundle install

ENV COMPOSE=1

EXPOSE 3000
