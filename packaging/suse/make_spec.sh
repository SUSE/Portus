#!/bin/bash

##
# Requirements

BUNDLER_VERSION="1.16.0"

##
# Helper functions

log()   { (>&2 echo ">>> [make_spec] $@") ; }
debug() { log "DEBUG: $@" ; }
error() { log "ERROR: $@" ; exit 1 ; }

# Depending on the given gem, it will append its native build requirements.
additional_native_build_requirements() {
  # NOTE: all echo'ed strings must start with a "\n" character.
  if [ $1 == "nokogiri" ];then
    echo "\nBuildRequires: libxml2-devel libxslt-devel"
  elif [ $1 == "mysql2" ];then
    echo "\n%if 0%{?suse_version} <= 1320\nBuildRequires: libmysqlclient-devel < 10.1\nRequires: libmysqlclient18 < 10.1\n%else\nBuildRequires: libmysqlclient-devel\nRequires: libmysqlclient18\n%endif\nRecommends: mariadb"
  elif [ $1 == "ethon" ];then
    echo "\nBuildRequires: libcurl-devel\nRequires: libcurl4"
  elif [ $1 == "ffi" ];then
    echo "\nBuildRequires: libffi-devel"
  elif [ $1 == "pg" ];then
    echo "\nBuildRequires: postgresql-devel\nRequires: postgresql-devel"
  fi
}

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

bundler_version=$(bundle version 2>/dev/null | awk '{ print $3 }')
if [ "$bundler_version" != "$BUNDLER_VERSION" ];then
  error "Bundler $BUNDLER_VERSION required!"
fi

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
cp -v ../../Gemfile* build/$packagename-$branch
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

  # Generate the Gemfile.lock file while ignoring some unnecessary groups.
  debug "Generate the Gemfile.lock for packaging"
  export BUNDLE_GEMFILE=$PWD/Gemfile
  cp Gemfile.lock Gemfile.lock.orig
  bundle config build.nokogiri --use-system-libraries
  bundle install --retry=3 --deployment --without assets test development

  debug "Diff of old and new Gemfile.lock file"
  diff Gemfile.lock Gemfile.lock.orig

  debug "Getting requirements from Gemfile.lock"
  IFS=$'\n' # do not split on spaces
  build_requires="# Dependencies extracted from the defined Gemfile."

  # Bundle's show command will list you the installed gems (the real ones, not
  # the ones installed on the Gemfile.lock). We use tail to skip the first line,
  # which is irrelevant. Then, with awk, we model the output to be "$gem
  # $version", but this $version is inside of parenthesis, so we remove them
  # with tr. This way, fetching the name and version is as easy as awk'ing again.
  for gem in $(bundle show | tail -n +2 | awk '{ print $2 " " $3 }' | tr -d '()');do
    gem_name=$(echo $gem | awk '{ print $1 }')
    gem_version=$(echo $gem | awk '{ print $2 }')
    build_requires="$build_requires\nBuildRequires: %{rubygem $gem_name} = $gem_version"
    build_requires="$build_requires$(additional_native_build_requirements $gem_name)"
  done

  # Extract the JS dependencies. Yarn will list dependencies in the following
  # format (when in depth=0): "├─ NAME@VERSION". So, we have to replace @ by an
  # empty space, and this way we'll be able to awk it away.
  js_provides="# Provides extracted from the yarn.lock file."
  for js in $(NODE_ENV=production yarn -s list --depth=0 | tr "@" " "); do
    js_name=$(echo $js | awk '{ print $2 }')
    js_version=$(echo $js | awk '{ print $3 }')
    js_provides="$js_provides\nProvides: bundled($js_name) = $js_version"
  done
popd

debug "Creating ${packagename}.spec based on ${packagename}.spec.in"
cp ${packagename}.spec.in ${packagename}.spec
sed -e "s/__BRANCH__/$branch/g" -i ${packagename}.spec
sed -e "s/__RUBYGEMS_BUILD_REQUIRES__/$build_requires/g" -i ${packagename}.spec
sed -e "s/__NODEJS_BUILD_PROVIDES__/$js_provides/g" -i ${packagename}.spec
sed -e "s/__DATE__/$date/g" -i ${packagename}.spec
sed -e "s/__COMMIT__/$commit/g" -i ${packagename}.spec
sed -e "s/__VERSION__/$version/g" -i ${packagename}.spec
sed -e "s/__CURRENT_YEAR__/$year/g" -i ${packagename}.spec
sed -e "s/__PATCHSOURCES__/$patchsources/g" -i ${packagename}.spec
sed -e "s/__PATCHEXECS__/$patchexecs/g" -i ${packagename}.spec

if [ -f ${packagename}.spec ];then
  echo "Done!"
  exit 0
else
  error "A problem occured creating the spec file."
fi
