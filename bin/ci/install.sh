#!/usr/bin/env bash

set -ex

if [ "$PORTUS_CI" = "unit" ] || [ "$PORTUS_CI" = "all" ]; then
  # Use the latest stable Node.js. We disable -x because the output gets really
  # ugly otherwise.
  set +x
  source ~/.nvm/nvm.sh
  nvm install stable
  nvm use stable
  set -x

  # Install Yarn
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install yarn
  yarn install

  # Intall Go, which is needed for git-validation
  eval "$(curl -sL https://raw.githubusercontent.com/travis-ci/gimme/master/gimme | GIMME_GO_VERSION=1.10.2 bash)"
  go get -u github.com/vbatts/git-validation
fi

if [ "$PORTUS_CI" = "integration" ] || [ "$PORTUS_CI" = "all" ]; then
  # Install bats.
  git clone https://github.com/sstephenson/bats.git
  cd bats
  sudo ./install.sh /usr/local
  cd .. && rm -rf bats
fi

# And finally install ruby gems.
bundle install --jobs=3 --retry=3
