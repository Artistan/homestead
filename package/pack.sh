#!/bin/bash

# make sure we run from this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";  cd "$DIR";

rm -rf "${DIR}/builds/${1}.virtualbox.box" > /dev/null
echo "<---<--- if virtualbox pops up, do not touch it --->--->"
packer build -only=virtualbox-iso "homestead.json" >> "${DIR}/build.txt"
vagrant box add --force "${1}" "file://localhost${DIR}/bento/builds/${1}.virtualbox.box"