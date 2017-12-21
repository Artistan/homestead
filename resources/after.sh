#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# add profile source if not exists.
(grep -q '.profile' /home/vagrant/.zshrc)
if [[ $? -eq 1 ]]
then
    printf "\nsource ~/.profile\n" | tee -a /home/vagrant/.zshrc
fi

## declare an array variable
declare -a versions_list=("5.6" "7.0" "7.1")

## now loop through the above array
for version in "${versions_list[@]}"
do
    # add xdebug settings if not exists.
    (grep -q 'profiler_enable_trigger' "/etc/php/$version/mods-available/xdebug.ini")
    if [[ $? -eq 1 ]]
    then
        xdebug="\n\nxdebug.profiler_enable_trigger=1;\nxdebug.profiler_output_dir=\"~/Code/xdebug\"\nxdebug.trace_enable_trigger=1\nxdebug.trace_output_dir=\"~/Code/xdebug\"\nxdebug.remote_host=\"192.168.10.1\"\nxdebug.remote_mode=\"jit\""
        printf "$xdebug" | tee -a "/etc/php/$version/mods-available/xdebug.ini"
    fi
done
