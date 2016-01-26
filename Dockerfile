FROM library/rails:4.2.2
MAINTAINER Flavio Castelli <fcastelli@suse.com>

ENV COMPOSE=1
EXPOSE 3000

WORKDIR /portus
COPY Gemfile* ./
RUN bundle install --retry=3

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
