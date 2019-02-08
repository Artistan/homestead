#!/bin/bash

DEBIAN_FRONTEND=noninteractive

# symlink php to bin/php
ln -s /usr/local/bin/php /bin/php

#apt-get update
#apt-get upgrade

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git config --global --add oh-my-zsh.hide-status 1

if [[ ! -e /usr/local/bin/php ]]
then
	ln -s /usr/bin/php /usr/local/bin/php
fi

# mcrypt
apt-get install gcc make autoconf libc-dev pkg-config libmcrypt-dev php-memcache php7.1-ldap php7.2-ldap php7.3-ldap -y
printf "\n" | pecl install mcrypt-1.0.2

## declare an array variable
declare -a versions_list=("7.1" "7.2" "7.3")

## now loop through the above array
for version in "${versions_list[@]}"
do
    # update the includes path
    includespath="\n\ninclude_path = \".:/usr/share/php:./include:/usr/local/lib/php\"\n"
    printf "$includespath" | tee -a "/etc/php/$version/fpm/php.ini"
    printf "$includespath" | tee -a "/etc/php/$version/cli/php.ini"

    # add mcrypt to the list...
    bash -c "echo extension=/usr/lib/php/20180731/mcrypt.so > /etc/php/$version/fpm/conf.d/mcrypt.ini"
    bash -c "echo extension=/usr/lib/php/20180731/mcrypt.so > /etc/php/$version/cli/conf.d/mcrypt.ini"

    # add xdebug settings if not exists.
    (grep -q 'profiler_enable_trigger' "/etc/php/$version/mods-available/xdebug.ini")
    if [[ $? -eq 1 ]]
    then
        xdebug="\n\nxdebug.profiler_enable_trigger=1;\nxdebug.profiler_output_dir=\"~/code/xdebug\"\nxdebug.trace_enable_trigger=1\nxdebug.trace_output_dir=\"~/code/xdebug\"\nxdebug.remote_host=\"192.168.10.1\"\nxdebug.remote_mode=\"jit\""
        printf "$xdebug" | tee -a "/etc/php/$version/mods-available/xdebug.ini"
        cp -f "/etc/php/$version/mods-available/xdebug.ini" "/etc/php/$version/mods-available/cli-xdebug.ini"
        # try to autostart
        sed -i "s/xdebug.so/xdebug.so\nxdebug.remote_autostart=1/" "/etc/php/$version/mods-available/cli-xdebug.ini"
        ln -s "/etc/php/$version/mods-available/cli-xdebug.ini" "/etc/php/$version/mods-available/20-xdebug.ini"
        # could use manual install, but why?
        # https://www.jetbrains.com/help/phpstorm/configuring-remote-php-interpreters.html#d37011e361
        # section 8. -d command...., still need xdebug enabled via php.ini!!!
        service "php${version}-fpm restart"
    fi
done
#nginx gzip...
#sed -i "s/#gzip/gzip/" "/etc/nginx/nginx.conf"
service apache2 restart
service nginx restart

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

# https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
# copy the cert to your vagrant directory so you cant trust it...
cp -f "/etc/nginx/ssl/ca.homestead.$(hostname).crt" "/vagrant/ca.homestead.$(hostname).crt"
echo "add ca.homestead.$(hostname).crt to your trusted certificates https://www.comodo.com/support/products/authentication_certs/setup/mac_chrome.php"



echo "--------------------------------"
echo "--------------------------------"
echo "    restart apache or nginx     "
echo "--------------------------------"
echo "--------------------------------"
