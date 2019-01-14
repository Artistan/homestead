#!/bin/bash

DEBIAN_FRONTEND=noninteractive

apt-get --yes --force-yes update
# sudo apt-get --yes --force-yes upgrade

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git config --global --add oh-my-zsh.hide-status 1

if [[ ! -e /usr/local/bin/php ]]
then
	ln -s /usr/bin/php /usr/local/bin/php
fi

# mcrypt
apt-get -y install gcc make autoconf libc-dev pkg-config
apt-get -y install libmcrypt-dev
printf "\n" | pecl install mcrypt-1.0.1
bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/fpm/conf.d/mcrypt.ini"
bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/cli/conf.d/mcrypt.ini"

# memcache -- old, for billing
apt-get --yes --force-yes install php-memcache -y

# ldap authentication
#apt-get --yes --force-yes install php5.6-ldap
#apt-get --yes --force-yes install php7.0-ldap
#apt-get --yes --force-yes install php7.1-ldap
#apt-get --yes --force-yes install php7.2-ldap

## declare an array variable
declare -a versions_list=("5.6" "7.0" "7.1" "7.2")

## now loop through the above array
for version in "${versions_list[@]}"
do
    # add xdebug settings if not exists.
    (grep -q 'profiler_enable_trigger' "/etc/php/$version/mods-available/xdebug.ini")
    if [[ $? -eq 1 ]]
    then
        xdebug="\n\nxdebug.profiler_enable_trigger=1;\nxdebug.profiler_output_dir=\"~/code/xdebug\"\nxdebug.trace_enable_trigger=1\nxdebug.trace_output_dir=\"~/code/xdebug\"\nxdebug.remote_host=\"192.168.10.1\"\nxdebug.remote_mode=\"jit\""
        printf "$xdebug" | tee -a "/etc/php/$version/mods-available/xdebug.ini"
        cp -f "/etc/php/$version/mods-available/xdebug.ini" "/etc/php/$version/mods-available/cli-xdebug.ini"
        # try to autostart
        sed -i "s/xdebug.so/xdebug.so\nxdebug.remote_autostart=1/" "/etc/php/$version/mods-available/cli-xdebug.ini"
        ln -s /etc/php/7.1/mods-available/cli-xdebug.ini "/etc/php/$version/mods-available/20-xdebug.ini"
        # could use manual install, but why?
        # https://www.jetbrains.com/help/phpstorm/configuring-remote-php-interpreters.html#d37011e361
        # section 8. -d command...., still need xdebug enabled via php.ini!!!
        service "php${version}-fpm restart"
    fi
done
#nginx gzip...
sed -i "s/#gzip/gzip/" "/etc/nginx/nginx.conf"
service nginx restart
service apache2 restart

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



