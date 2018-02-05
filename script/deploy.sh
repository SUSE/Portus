#!/usr/bin/env bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
pushd $DIR

# Perform the build.
chmod +x ./script/build.sh
./script/build.sh

# Move the contents of _site into a temporary directory, change to the gh-pages
# branch and finally move the contents into the current directory.
tmp=$(mktemp -d)
mv _site/* $tmp
git checkout gh-pages
ls -a | grep -wv ".git" | grep -wv "." | xargs rm -rf
cp -r $tmp/* .
rm -r $tmp
