#!/bin/bash

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.

version="7.3"

#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
#git config --global --add oh-my-zsh.hide-status 1

# add profile source if not exists.
(grep -q '.profile' /home/vagrant/.zshrc)
if [[ $? -eq 1 ]]
then
    printf "\nsource ~/.profile\n" | tee -a ~/.zshrc
fi

# symlink the executable.
if [[ ! -e /usr/local/bin/php ]]
then
	sudo ln -s /usr/bin/php /usr/local/bin/php
fi

sudo apt-get install gcc make autoconf libc-dev pkg-config libmcrypt-dev php-memcache "php$version-ldap" -y
sudo pecl channel-update pecl.php.net
printf "\n" | sudo pecl install mcrypt-1.0.2

################## PHP UPDATES ##################
# add mcrypt to the list...
sudo bash -c "echo extension=/usr/lib/php/20180731/mcrypt.so > /etc/php/$version/fpm/conf.d/mcrypt.ini"
sudo bash -c "echo extension=/usr/lib/php/20180731/mcrypt.so > /etc/php/$version/cli/conf.d/mcrypt.ini"

# add xdebug settings if not exists.
(grep -q 'profiler_enable_trigger' "/etc/php/$version/mods-available/xdebug.ini")
if [[ $? -eq 1 ]]
then
    if [[ -f "/etc/php/$version/mods-available/xdebug.ini" ]]
    then
        #ip=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(192.([0-9]*\.){2}[0-9]*).*/\2/p'`
        xdebug="\n\nxdebug.profiler_enable_trigger=1;\nxdebug.profiler_output_dir=\"~/code/xdebug\"\nxdebug.trace_enable_trigger=1\nxdebug.trace_output_dir=\"~/code/xdebug\"\nxdebug.remote_host=\"192.168.10.1\"\nxdebug.remote_mode=\"jit\""
        printf "$xdebug" | sudo tee -a "/etc/php/$version/mods-available/xdebug.ini"
    fi

    if [[ -f "/etc/php/$version/mods-available/cli-xdebug.ini" ]]
    then
        # try to autostart
        sudo sed -i "s/xdebug.so/xdebug.so\nxdebug.remote_autostart=1/" "/etc/php/$version/mods-available/cli-xdebug.ini"
        sudo ln -s "/etc/php/$version/mods-available/cli-xdebug.ini" "/etc/php/$version/mods-available/20-xdebug.ini"
    fi
    # could use manual install, but why?
    # https://www.jetbrains.com/help/phpstorm/configuring-remote-php-interpreters.html#d37011e361
    # section 8. -d command...., still need xdebug enabled via php.ini!!!
fi

# add sql_mode settings if not exists.
(grep -q 'sql_mode' "/etc/mysql/mysql.conf.d/mysqld.cnf")
if [[ $? -eq 1 ]]
then
    sudo sed -i "s/\[mysqld\]/\[mysqld\]\nsql_mode = \"STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo service mysql restart
fi

# updates to php, so restart fpm.
sudo service "php${version}-fpm" restart

# restart the webservice. Nginx or Apache.
ps auxw | grep apache2 | grep -v grep > /dev/null
if [[ $? -ne 1 ]]
then
    echo "$? apache restart"
    sudo service apache2 restart > /dev/null
else
    echo "$? nginx restart"
    sudo service nginx restart > /dev/null
fi

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
