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
MAJOR_VERSION=$(echo $RELEASE | rev | cut -d. -f1 --complement | rev)
BRANCH="v$MAJOR_VERSION"
ORIG_PROJECT=Virtualization:containers:Portus
DEST_PROJECT=$ORIG_PROJECT:Release:$RELEASE
API=https://api.opensuse.org
OSC="osc -A $API"

echo "Setting release $RELEASE in project config template"
sed -e "s/__RELEASE__/$RELEASE/g" project.xml.template > project.xml

echo "Creating new subproject $DEST_PROJECT"
$OSC meta prj $DEST_PROJECT --file=project.xml

echo "Copying packages to the new project"
for package in $($OSC ls $ORIG_PROJECT );do $OSC copypac -e $ORIG_PROJECT $package $DEST_PROJECT; done

echo "Checking out Portus package"
DIR=/tmp/$0/$RANDOM
mkdir -p $DIR
pushd $DIR
$OSC checkout $DEST_PROJECT Portus

echo "Setting version in _service file"
cd $DEST_PROJECT/Portus
sed -e "s/master.tar.gz/$RELEASE.tar.gz/g" -i _service

echo "Getting tarball"
$OSC service run

echo "Generate spec file"
mv _service\:download_url\:$RELEASE.tar.gz $RELEASE.tar.gz
tar zxvf $RELEASE.tar.gz
cd Portus-$RELEASE/packaging/suse
TRAVIS_COMMIT=$RELEASE TRAVIS_BRANCH=$BRANCH ./make_spec.sh
cd -
cp Portus-$RELEASE/packaging/suse/Portus.spec .

echo "Setting version $RELEASE in spec file"
sed -e "s/%define branch master/%define branch $RELEASE/g" -i Portus.spec
sed -e "s/Version: .*/Version:        $RELEASE/g" -i Portus.spec

echo "Commiting new project"
$OSC commit -m "set release to $RELEASE"

echo "Cleaning..."
rm -rf $DIR
popd


