FROM library/rails:4.2.2
MAINTAINER Flavio Castelli <fcastelli@suse.com>

# ENV COMPOSE=1
ENV RAILS_ENV=production
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

RUN /bin/echo -e "-----BEGIN CERTIFICATE-----\nMIIFSTCCAzGgAwIBAgIIC0CI0K4TvpMwDQYJKoZIhvcNAQEFBQAwMjEUMBIGA1UE\nAwwLU0JLU0FkbWluQ0ExDTALBgNVBAoMBFNCS1MxCzAJBgNVBAYTAkNaMB4XDTEz\nMTExMzE1MjczOVoXDTIzMTExMTE1MjczOVowMjEUMBIGA1UEAwwLU0JLU0FkbWlu\nQ0ExDTALBgNVBAoMBFNCS1MxCzAJBgNVBAYTAkNaMIICIjANBgkqhkiG9w0BAQEF\nAAOCAg8AMIICCgKCAgEAq32CZfc7fqoMFM1dekE1SZOzlEgDkIHahYYlz66BrhXq\nVvx9xlIUAwqVyvdDmiBl988vzTs5j9NfEdGrBkhEJHtmaPlHOh+DU6xyhymGS96m\nhtfWxmVRasFy0SYPexBmqnjU0QOtoDgED0JbkZNJ6+38mYTr0F0A0kxItuZOyetx\nUFHRd1p5hmF6zruf6S79lz95BHcXkZqIQS+w2eEZDU82HOTzhm3W/GMg6zStEaoS\nRzVhFz0XGeGbLXcGQQWYHS/m2j+bzjd/ep8uZPo6EOfU6tkYzRG9FkAbsADCAnwN\npRX4+2oeXByerSKNcr/eUXyxzrnS7WhUP9PMSvSsBiD7qQFV4h6PTtCrk9NXSLgv\neqrZDfAhf6kRNGLKwFKKKy3y1o2PGVbpK9ZlLpwkv1HCv8K4OMBJmOuPo0ooNyB/\nZoCU83SBio5NzQ0+w0u6NAgJJConTD5KQsDI1lg+8Ij584DsjVuHhrDgZBmXK6Nb\nOsO2HwN9AbCnWd1J+cMvoi9aATytYLMCjKu166xuSJZNGkgU5iamJXcbnPuGtex8\nv2iNwYr4v7/4Z9ThGtnylN7Nd086L0NVMLif5OkW9xtdyRaeh6e58ICCmNPITNd5\najLHWR5ZjmrTlm8CrYRdtqwrXPNBG5f1bInaHhlbX24ulAC2xHLZv0aWkKR7s8cC\nAwEAAaNjMGEwHQYDVR0OBBYEFKhkZ43c15JJY6elMZ1+ldKZjx7sMA8GA1UdEwEB\n/wQFMAMBAf8wHwYDVR0jBBgwFoAUqGRnjdzXkkljp6UxnX6V0pmPHuwwDgYDVR0P\nAQH/BAQDAgGGMA0GCSqGSIb3DQEBBQUAA4ICAQCoNaF18guCrOeXBO+Tkdyzg2md\nnTPluEST7iZbDA+ntHrY0djBVOL3DRgSLIb+Y7w3VdWljx57B+tr5amjZ5zosAzI\nOC6T00hQnuhW6tvD3vMUxL0tyaRa22y+3Bq8IGQ9IJ0WrRQUtzpHe4dqVFT6jxbL\nBRJ0LmZ9zE/U9PweV2T9xqZPcn6m/oUFWZYDzBT/sOwnKZuZUI03Cqyb5Pyez83a\nkJ/1ZZYpV9UdiZAo7SitwqRaEXnCk0nLgy4esGcflV5pfAb8hfD88skFR/i+xUBk\nJx0XgzVfNJ29PIaxgyz66ot3gJg7xK/qvVpYr15cwDHnRIqQDKc7Vs6iCSIJ7gdg\n2n8Sq+GxCIyjlJN2AOELZ86zeZTw2uxkrEALZgOReS9uB8fdjg9rjx8kVaRrF2gG\no+qppn7QKh8+FWJZeB8cjoqAl8vAoCN6qnDMW6fq39XxPK3uzRpWvCPrsQFBTCtU\nI9QV28g4VOwviGenC/nBKwFXryUcTAT1h3pitLiAumdUqP23+u3BJIDXx2p1Robg\nGjlev4HJybJE2tlx1+dke5teZWDg+vXAZ56XVZjJQDC6j+SbB2gTgRaBhJzHYdfM\nVLbFuihJxzSzAc3NbSImIWu/vUGnu0PweMtzmuZtDrwf5kX9joKaEJsIHQq7PwXC\nM1xAkvoMCDw5llOb1A==\n-----END CERTIFICATE-----\n" > /usr/local/share/ca-certificates/SBKSAdminCA.crt && /usr/sbin/update-ca-certificates

ADD . .
