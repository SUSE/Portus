#!/bin/bash
# This script is designed to be run in travis build, as a after_sucess script
#
# This script expects certain variables to exist and to have certain values
#
# The ones that start with TRAVIS are set by travis itself. See:
# http://docs.travis-ci.com/user/ci-environment/#Environment-variables
#
# The other ones are set per project basis by the user in travis. See:
# http://docs.travis-ci.com/user/environment-variables/#Using-Settings

if [ $TRAVIS_PULL_REQUEST == "false" ] && [ $OBS_BRANCH ] && [ $TRAVIS_COMMIT ] && [ $OSC_CREDENTIALS ] && [ $OBS_REPO ] && [ $TRAVIS_BRANCH == $OBS_BRANCH ];then
  # Clean up the environment
  rm -r build
  rm -r *.orig
  git checkout -- .

  packaging/suse/make_spec.sh portus
  curl -X PUT -T packaging/suse/portus.spec -u $OSC_CREDENTIALS https://api.opensuse.org/source/$OBS_REPO/portus/portus.spec?comment=update_portus.spec\_to_commit_$TRAVIS_COMMIT\_from_branch_$OBS_BRANCH
  for p in packaging/suse/patches/*.patch;do
      curl -X PUT -T $p -u $OSC_CREDENTIALS https://api.opensuse.org/source/$OBS_REPO/portus/$(basename $p)?comment=update_patches\_to_commit_$TRAVIS_COMMIT\_from_branch_$OBS_BRANCH
  done

  # Get the yarn.lock file from OBS and compare it. If they differ, then push a
  # new node_modules.tar.gz file.
  curl -u $OSC_CREDENTIALS https://api.opensuse.org/source/$OBS_REPO/portus/yarn.lock > obs-yarn.lock
  if ! diff -q yarn.lock obs-yarn.lock &>/dev/null; then
      tar czvf node_modules.tar.gz node_modules
      curl -X PUT -T node_modules.tar.gz -u $OSC_CREDENTIALS https://api.opensuse.org/source/$OBS_REPO/portus/node_modules.tar.gz?comment=update_node_modules.tar.gz\_to_commit_$TRAVIS_COMMIT\_from_branch_$OBS_BRANCH
      curl -X PUT -T yarn.lock -u $OSC_CREDENTIALS https://api.opensuse.org/source/$OBS_REPO/portus/yarn.lock?comment=update_yarn.lock\_to_commit_$TRAVIS_COMMIT\_from_branch_$OBS_BRANCH
  fi
else
  echo "Didn't package nor commit to obs"
  echo "Reasons"
  if [ $TRAVIS_PULL_REQUEST != "false" ];then
    echo "This is a pull request"
  fi
  if [ ! $OBS_BRANCH ];then
    echo "No OBS_BRANCH variable"
  fi
  if [ ! $TRAVIS_COMMIT ];then
    echo "No TRAVIS_COMMIT"
  fi
  if [ ! $OSC_CREDENTIALS ];then
    echo "No OSC_CREDENTIALS"
  fi
  if [ ! $OBS_REPO ];then
    echo "No OBS_REPO"
  fi
  if [ $TRAVIS_BRANCH != $OBS_BRANCH ];then
    echo "TRAVIS_BRANCH $TRAVIS_BRANCH differs from OBS_BRANCH $OBS_BRANCH"
  fi
  exit -1
fi
