#!/bin/bash

apt-get install -y apt-transport-https
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get update && apt-get install -y yarn nodejs && \
    yarn add global webpack && \
    /usr/bin/npm install webpack -g && \
    webpack --config config/webpack.js
