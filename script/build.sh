#!/usr/bin/env bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
pushd $DIR

# Clean up previous build.
rm -rf _site

# Build && test.
bundle exec jekyll build
bundle exec rake

cat <<EOF
Your "_site" directory has been properly built. You can now move the contents
into the "gh-pages" branch.
EOF
