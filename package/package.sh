#!/bin/bash

# make sure we run from this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";  cd "$DIR";
source ./yaml.sh

eval $(parse_yaml ../homestead.yaml)
hostname="$(echo $hostname | sed 's/\"//g')"
name="$(echo $name | sed 's/\"//g')"

packIt="vagrant package --output \"${hostname}.box\" --base \"$name\""

echo $packIt
eval $packIt
