#!/usr/bin/env bash

if [[ -n "$1" ]]; then
    cp -i resources/Homestead.json Homestead.json
else
    cp -i resources/Homestead.yaml Homestead.yaml
fi

cp -i resources/after.sh after.sh
cp -i resources/aliases aliases
cp -i resources/system-plugins.sh system-plugins.sh
cp -i resources/system-before.sh system-before.sh
cp -i resources/system-after.sh system-after.sh

echo "Homestead initialized!"
