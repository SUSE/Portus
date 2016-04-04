FROM library/rails:4.2.2
MAINTAINER Steve Shipway <s.shipway@auckland.ac.nz>

ENV RAILS_ENV=production
ENV COMPOSE=1
ENV CATALOG_CRON="5.minutes"

WORKDIR /portus

EXPOSE 3000


# Install phantomjs, this is required for testing and development purposes
# There are no official deb packages for it, hence we built it inside of the
# open build service.
RUN echo "deb http://download.opensuse.org/repositories/home:/flavio_castelli:/phantomjs/Debian_8.0/ ./" >> /etc/apt/sources.list
RUN wget http://download.opensuse.org/repositories/home:/flavio_castelli:/phantomjs/Debian_8.0/Release.key && \
  apt-key add Release.key && \
  rm Release.key
RUN apt-get update && \
    apt-get install -y --no-install-recommends phantomjs && \
    rm -rf /var/lib/apt/lists/*

ADD . .

RUN apt-get update && apt-get install -y telnet ldap-utils
COPY Gemfile* ./
RUN bundle install --retry=3

RUN mkdir -p /etc/nginx/conf.d
VOLUME /etc/nginx/conf.d

# Run this command to start it up
ENTRYPOINT ["/bin/bash","/portus/startup.sh"]
# Default arguments to pass to puma
CMD ["-b","tcp://0.0.0.0:3000","-w","3"]

