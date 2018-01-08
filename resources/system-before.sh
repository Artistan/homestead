#!/bin/bash

# If you would like to do some extra work on the host you may
# add any commands you wish to this file and they will
# be run before the Homestead machine is provisioned.


if [[ "$2" == 'up' || "$2" == 'provision' ]] && [[ ! -f ./.created ]] ;
then

    echo "Creating a new box $0 $1 $2"

    pluginsData="$(vagrant plugin list)"

    $(echo "$pluginsData"|grep -q triggers)
    if [[ $? -eq 1  ]]; then
        vagrant plugin install vagrant-triggers
    fi
    $(echo "$pluginsData"|grep -q host-shell)
    if [[ $? -eq 1  ]]; then
        vagrant plugin install vagrant-host-shell
    fi
    $(echo "$pluginsData"|grep -q bindfs)
    if [[ $? -eq 1  ]]; then
        vagrant plugin install vagrant-bindfs
    fi
    $(echo "$pluginsData"|grep -q hostsupdater)
    if [[ $? -eq 1  ]]; then
        vagrant plugin install vagrant-hostsupdater
    fi
    $(echo "$pluginsData"|grep -q vbguest)
    if [[ $? -eq 1  ]]; then
        vagrant plugin install vagrant-vbguest
    fi

fi