#!/bin/bash

##
# Requirements

BUNDLER_VERSION="1.16.0"

##
# Helper functions

log()   { (>&2 echo ">>> [make_spec] $@") ; }
debug() { log "DEBUG: $@" ; }
error() { log "ERROR: $@" ; exit 1 ; }

##
# Initialization

if [ -z "$1" ]; then
  cat <<EOF
usage:
  ./make_spec.sh PACKAGENAME
EOF
  exit 1
fi

packagename=$1

cd $(dirname $0)

if [ $TRAVIS_BRANCH ];then
  branch=$TRAVIS_BRANCH
else
  branch=$(git rev-parse --abbrev-ref HEAD)
fi
if [ $TRAVIS_COMMIT ];then
  commit=$TRAVIS_COMMIT
else
  commit=$(git rev-parse HEAD)
fi
version=$(sed s/-/~/g ../../VERSION)
version="$version+git$commit"
date=$(date --rfc-2822)
year=$(date +%Y)

##
# Creating build environment

# Clean
[ ! -d build ] || rm -rf build

mkdir -p build/$packagename-$branch
cp -v ../../yarn.lock build/$packagename-$branch
if ls patches/*.patch >/dev/null 2>&1 ;then
    cp -v patches/*.patch build/$packagename-$branch
fi

##
# Generating spec file

pushd build/$packagename-$branch/
  debug "Apply patches if needed"
  if ls *.patch >/dev/null 2>&1 ;then
      patchsources="\n# Dynamically defined patches."
      for p in *.patch;do
          number=$(echo "$p" | cut -d"_" -f1)
          patchsources="$patchsources\nPatch$number: $p\n"
          patchexecs="$patchexecs\n%patch$number -p1\n"
          # skip applying rpm patches
          [[ $p =~ .rpm\.patch$ ]] && continue
          debug "Applying patch $p"
          echo "DEBUG"
          cat $p
          patch -p1 < $p || exit -1
      done
  fi

popd

debug "Creating ${packagename}.spec based on ${packagename}.spec.in"
cp ${packagename}.spec.in ${packagename}.spec
sed -e "s|__BRANCH__|$branch|g" -i ${packagename}.spec
sed -e "s|__RUBYGEMS_BUILD_REQUIRES__|$build_requires|g" -i ${packagename}.spec
sed -e "s|__NODEJS_BUILD_PROVIDES__|$js_provides|g" -i ${packagename}.spec
sed -e "s|__DATE__|$date|g" -i ${packagename}.spec
sed -e "s|__COMMIT__|$commit|g" -i ${packagename}.spec
sed -e "s|__VERSION__|$version|g" -i ${packagename}.spec
sed -e "s|__CURRENT_YEAR__|$year|g" -i ${packagename}.spec
sed -e "s|__PATCHSOURCES__|$patchsources|g" -i ${packagename}.spec
sed -e "s|__PATCHEXECS__|$patchexecs|g" -i ${packagename}.spec

if [ -f ${packagename}.spec ];then
  echo "Done!"
  exit 0
else
  error "A problem occured creating the spec file."
fi
