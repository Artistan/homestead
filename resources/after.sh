#!/bin/bash

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git config --global --add oh-my-zsh.hide-status 1

# add profile source if not exists.
(grep -q '.profile' /home/vagrant/.zshrc)
if [[ $? -eq 1 ]]
then
    printf "\nsource ~/.profile\n" | tee -a /home/vagrant/.zshrc
fi

# add profile source if not exists.
(grep -q 'PHP_IDE_CONFIG' /home/vagrant/.zshrc)
if [[ $? -eq 1 ]]
then
    printf "\nexport PHP_IDE_CONFIG=\"serverName=$(hostname)\"\n" | tee -a /home/vagrant/.zshrc
fi
