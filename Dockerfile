FROM rails:4.2.2
MAINTAINER Flavio Castelli <fcastelli@suse.com>

ENV COMPOSE=1
EXPOSE 3000

RUN mkdir /portus
WORKDIR /portus

# install supervisord, this is required to run cronos
RUN apt-get update && apt-get install -y supervisor
RUN ln -s /portus/docker/crono-supervisord.conf /etc/supervisor/conf.d/crono.conf

ADD Gemfile* /portus/
RUN bundle install --retry=3

ADD . /portus