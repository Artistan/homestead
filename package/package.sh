#!/bin/bash

# make sure we run from this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";  cd "$DIR";

vagrant package --output homestead.box --base "Chuck-Dev"

