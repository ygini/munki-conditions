#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run this script as root"
  exit 1
fi

requested_condition="$1"
REPO_PATH="$2"

if [ -z "$REPO_PATH" ]
then
    REPO_PATH=$(cd `dirname $0` && pwd)
fi

condition_path="$REPO_PATH/$requested_condition"

if [ -z "$requested_condition" ]
then
    echo "You must provide a condition to package as first argument"
    exit 2
elif [ ! -e "$condition_path" ]
then
    echo "Requested condition does not exist in this repo"
    echo "Repo location: $REPO_PATH"
    echo "You can specifiy an alternative repo as second argument"
    exit 3
fi

BUILD_DIR=$(mktemp -d)
echo "Working folder: $BUILD_DIR"

building_condition_path="$BUILD_DIR/usr/local/munki/conditions"
mkdir -p "$building_condition_path"

cp -X "$condition_path" "$building_condition_path"

chown -R root:wheel "$BUILD_DIR"

pkgbuild --root "$BUILD_DIR" --identifier "com.github.ygini.munki-conditions.$requested_condition" --version $(date +%Y.%m.%d.%H.%M.%S) "$condition_path-MunkiCondition.pkg"

echo "Cleaning temp folder"

rm -rf "$BUILD_DIR"

exit 0
