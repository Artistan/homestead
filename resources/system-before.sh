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
        vagrant plugin install vagrant-hostsupdater
        cat >/tmp/vagrant_hostsupdater <<EOL
# Allow passwordless startup of Vagrant with vagrant-hostsupdater.
# change admin to sudo for non-Mac users.
Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c 'echo "*" >> /etc/hosts'
Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/env sed -i -e /*/ d /etc/hosts
%admin ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE
EOL
        sudo chown root:wheel /tmp/vagrant_hostsupdater
        sudo mv -f /tmp/vagrant_hostsupdater /etc/sudoers.d/vagrant_hostsupdater
    fi
    $(echo "$pluginsData"|grep -q vbguest)
    if [[ $? -eq 1  ]]; then
        vagrant plugin install vagrant-vbguest
    fi

fi