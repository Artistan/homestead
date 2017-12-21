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

# add profile source if not exists.
(grep -q 'PHP_IDE_CONFIG' /home/vagrant/.zshrc)
if [[ $? -eq 1 ]]
then
    printf "\nexport PHP_IDE_CONFIG=\"serverName=SomeName\"\n" | tee -a /home/vagrant/.zshrc
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
        sudo printf "$xdebug" | sudo tee -a "/etc/php/$version/mods-available/xdebug.ini"
        sudo cp -f "/etc/php/$version/mods-available/xdebug.ini" "/etc/php/$version/mods-available/cli-xdebug.ini"
        # try to autostart
        sed -i "s/xdebug.so/xdebug.so\nxdebug.remote_autostart=1/" /etc/php/7.1/mods-available/cli-xdebug.ini
        sudo ln -s /etc/php/7.1/mods-available/cli-xdebug.ini /etc/php/7.1/mods-available/20-xdebug.ini
    fi
done

## cli execute with debug examples.
# https://confluence.jetbrains.com/display/PhpStorm/Debugging+PHP+CLI+scripts+with+PhpStorm

## phpstorm script run setup
# https://confluence.jetbrains.com/display/PhpStorm/Working+with+Remote+PHP+Interpreters+in+PhpStorm

## phpstorm xdebug setup
# https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html

## validate your configuration
# https://confluence.jetbrains.com/display/PhpStorm/Validating+Your+Debugging+Configuration

## server config in Homestead.yaml - so phpstorm knows which server it is dealing with.
# https://confluence.jetbrains.com/display/PhpStorm/Debugging+PHP+CLI+scripts+with+PhpStorm#DebuggingPHPCLIscriptswithPhpStorm-2.StarttheScriptwithDebuggerOptions
# variables:
#     - key: APP_ENV
#       value: number2
#     - key: PHP_IDE_CONFIG
#       value: serverName=number2