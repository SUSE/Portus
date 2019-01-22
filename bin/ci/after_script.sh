#!/usr/bin/env bash

set -ex

if [ "$PORTUS_CI" = "unit" ] || [ "$PORTUS_CI" = "all" ]; then
  ./cc-test-reporter after-build --exit-code $TRAVIS_TEST_RESULT
fi
