#!/bin/bash
set -ex
cd $(dirname $0)

usage_and_exit() {
  echo "usage $0 X.Y.Z"
  echo "Where X.Y.Z is the new release number"
  exit -1
}

if [ $# != 1 ];then
  usage_and_exit
fi
if [ $1 == "help" ];then
  usage_and_exit
fi
if [ $1 == "-h" ];then
  usage_and_exit
fi
if [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]];then
 usage_and_exit
fi 

RELEASE=$1
VERSION_2D=$(echo $RELEASE | rev | cut -d. -f1 --complement | rev)
BRANCH="v$VERSION_2D"
ORIG_PROJECT=Virtualization:containers:Portus
DEST_PROJECT=$ORIG_PROJECT:$VERSION_2D
API=https://api.opensuse.org
OSC="osc -A $API"
PKG_DIR=/tmp/$0/$RANDOM

create_subproject() {
  $OSC ls $DEST_PROJECT > /dev/null 2>&1
  if [ "$?" == "0" ];then
    echo "Project $DEST_PROJECT already exists."
    return
  fi

  echo "Setting version $VERSION_2D in project config template"
  sed -e "s/__VERSION__/$VERSION_2D/g" project.xml.template > project.xml

  echo "Creating new subproject $DEST_PROJECT"
  $OSC meta prj $DEST_PROJECT --file=project.xml

  echo "Copying packages to the new project"
  for package in $($OSC ls $ORIG_PROJECT );do $OSC copypac -e $ORIG_PROJECT $package $DEST_PROJECT; done
}

update_package() {
  echo "Checking out portus package"
  pushd $PKG_DIR
  $OSC checkout $DEST_PROJECT portus

  echo "Setting version in _service file"
  cd $DEST_PROJECT/portus
  sed -e "s/master.tar.gz/$RELEASE.tar.gz/g" -i _service

  echo "Getting tarball"
  $OSC service run

  echo "Generate spec file"
  mv _service\:download_url\:$RELEASE.tar.gz $RELEASE.tar.gz
  tar zxvf $RELEASE.tar.gz
  cd Portus-$RELEASE/packaging/suse
  TRAVIS_COMMIT=$RELEASE TRAVIS_BRANCH=$BRANCH ./make_spec.sh
  cd -
  # in 2.0.3, Portus is still uppercase
  if [ -f Portus-$RELEASE/packaging/suse/Portus.spec ];then
    cp Portus-$RELEASE/packaging/suse/Portus.spec portus.spec
  # in version >= 2.1, portus is downcase
  elif [ -f Portus-$RELEASE/packaging/suse/portus.spec ];then
    cp Portus-$RELEASE/packaging/suse/portus.spec portus.spec
  fi

  echo "Setting version $RELEASE in spec file"
  # We set the BRANCH to the RELEASE tag
  sed -e "s/%define branch $BRANCH/%define branch $RELEASE/g" -i portus.spec
  # We set the Version to the RELEASE tag
  sed -e "s/Version: .*/Version:        $RELEASE/g" -i portus.spec
  popd
}

commit_all() {
  pushd $PKG_DIR
  cd $DEST_PROJECT/portus
  echo "Commiting new project"
  $OSC commit -m "set release to $RELEASE"
  popd
}

clean() {
  echo "Cleaning..."
  rm -rf $PKG_DIR
}

mkdir -p $PKG_DIR
create_subproject
update_package
commit_all
clean



