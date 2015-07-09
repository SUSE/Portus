FROM ruby:2.1

RUN echo mysql-server-10.0 mysql-server/root_password password 'PASS' | debconf-set-selections
RUN echo mysql-server-10.0 mysql-server/root_password_again password 'PASS' | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && apt-get install -y \
  nodejs \
  mariadb-server \
  apache2 \
  apache2-dev

COPY . /portus
COPY docker-entrypoint.sh /

WORKDIR /portus
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

RUN gem install passenger -v 5.0.7
RUN passenger-install-apache2-module -a

COPY docker/config/sysconfig_apache2    /etc/sysconfig/apache2
COPY docker/config/httpd.conf.local     /etc/apache2/mods-enabled/passenger.conf
COPY docker/config/portus.test.lan.conf /etc/apache2/conf-enabled/portus.conf

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
