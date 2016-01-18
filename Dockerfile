FROM library/rails:4.2.2
MAINTAINER Steve Shipway <s.shipway@auckland.ac.nz>

ENV RAILS_ENV=production
ENV COMPOSE=1
EXPOSE 3000

RUN apt-get update && apt-get install -y telnet ldap-utils

WORKDIR /portus
COPY Gemfile* ./
RUN bundle install --retry=3

ADD . .

VOLUME /conf /certs

ENV CATALOG_CRON="5.minutes"

# Run this command to start it up
ENTRYPOINT ["/bin/sh","/portus/startup.sh"]
# Default arguments to pass to puma
CMD ["-b","tcp://0.0.0.0:3000","-w","3"]

