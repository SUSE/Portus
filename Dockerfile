FROM rails:4.2.2
MAINTAINER Flavio Castelli <fcastelli@suse.com>

RUN mkdir /portus
WORKDIR /portus
ADD . /portus
RUN bundle install
RUN mv /portus/config/database-docker-compose.yml /portus/config/database.yml

EXPOSE 3000
