#!/bin/bash

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.

version="7.2"
extensions="/usr/lib/php/20170718"
mcrypt="1.0.2"
blitz="0.10.4-PHP7"

# vagrant user zsh plugins enabled ... git, laravel, directory cycle, npm and rsync
sudo chsh -s /usr/bin/zsh vagrant
sudo sed -i "s/plugins=(git)/plugins=(git laravel5 dircycle npm rsync)/" ~/.zshrc

# symlink php to bin/php
sudo ln -s /usr/local/bin/php /bin/php

if [[ ! -e /usr/local/bin/php ]]
then
        ln -s /usr/bin/php /usr/local/bin/php
fi

# update default php version to "$version"
sudo update-alternatives --set php /usr/bin/"php$version"
sudo update-alternatives --set phar "/usr/bin/phar$version"
sudo update-alternatives --set phar.phar "/usr/bin/phar.phar$version"
sudo update-alternatives --set phpize "/usr/bin/phpize$version"
sudo update-alternatives --set php-config "/usr/bin/php-config$version"

sudo DEBIAN_FRONTEND=noninteractive apt install -y --allow-unauthenticated -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold gcc make autoconf libc-dev libmcrypt-dev htmldoc pkg-config "php$version-ldap" "php$version-memcache" "php$version-imagick" "php$version-gmp" "php$version-apc"

# update the includes path
includespath="\n\ninclude_path = \".:/usr/share/php:./include:/usr/local/lib/php\"\n"
printf "$includespath" | sudo tee -a "/etc/php/$version/fpm/php.ini"
printf "$includespath" | sudo tee -a "/etc/php/$version/cli/php.ini"

# install mcrypt module (compiled via PHP $version)
sudo pecl channel-update pecl.php.net
sudo pecl install "mcrypt-$mcrypt"

# PHP $version -- $extensions directory
sudo bash -c "echo extension=$extensions/mcrypt.so > /etc/php/$version/mods-available/mcrypt.ini"

sudo ln -s "/etc/php/$version/mods-available/mcrypt.ini" "/etc/php/$version/cli/conf.d/20-mcrypt.ini"
sudo ln -s "/etc/php/$version/mods-available/mcrypt.ini" "/etc/php/$version/fpm/conf.d/20-mcrypt.ini"

# add elasticsearch settings if not found.
if [[ -e /etc/elasticsearch/elasticsearch.yml ]] && ! sudo grep -Fq '_local_,_site_' /etc/elasticsearch/elasticsearch.yml;
then
    echo 'Configuring Elasticsearch ...';
    sudo bash -c 'echo network.host: ["_local_","_site_"] >> /etc/elasticsearch/elasticsearch.yml';
    sudo bash -c 'echo path.repo: "/home/vagrant/elasticsnaps" >> /etc/elasticsearch/elasticsearch.yml';
    sudo mkdir ~/elasticsnaps;
    sudo chown elasticsearch:elasticsearch ~/elasticsnaps;
    sudo service elasticsearch restart;
fi

# add blitz if does not exist
if ! php -m | grep -q 'blitz';
then
    echo 'Installing Blitz ...';
    sudo git clone https://github.com/alexeyrybak/blitz.git ~/blitz;
    cd ~/blitz;
    sudo git checkout -b "$blitz" "$blitz";
    sudo phpize;
    sudo ./configure;
    sudo make;
    sudo make install;
    sudo bash -c "echo extension=blitz.so > /etc/php/$version/mods-available/blitz.ini";
    sudo ln -s "/etc/php/$version/mods-available/blitz.ini"  "/etc/php/$version/cli/conf.d/20-blitz.ini";
    sudo ln -s "/etc/php/$version/mods-available/blitz.ini"  "/etc/php/$version/fpm/conf.d/20-blitz.ini";
fi


# add xdebug settings if not exists.
(grep -q 'profiler_enable_trigger' "/etc/php/$version/mods-available/xdebug.ini")
if [[ $? -eq 1 ]]
then
   xdebug="\n\nxdebug.profiler_enable_trigger=1;\nxdebug.profiler_output_dir=\"~/code/xdebug\"\nxdebug.trace_enable_trigger=1\nxdebug.trace_output_dir=\"~/code/xdebug\"\nxdebug.remote_host=\"192.168.10.1\"\nxdebug.remote_mode=\"jit\""
   printf "$xdebug" | tee -a "/etc/php/$version/mods-available/xdebug.ini"
   sudo cp -f "/etc/php/$version/mods-available/xdebug.ini" "/etc/php/$version/mods-available/cli-xdebug.ini"

   # try to autostart
   sudo sed -i "s/xdebug.so/xdebug.so\nxdebug.remote_autostart=1/" "/etc/php/$version/mods-available/cli-xdebug.ini"
   sudo ln -s "/etc/php/$version/mods-available/cli-xdebug.ini" "/etc/php/$version/mods-available/20-xdebug.ini"
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

sudo systemctl restart "php$version-fpm"
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

# https://apple.stackexchange.com/questions/80623/import-certificates-into-the-system-keychain-via-the-command-line
# copy the cert to your vagrant directory so you cant trust it...
sudo cp -f "/etc/nginx/ssl/ca.homestead.$(hostname).crt" "/vagrant/ca.homestead.$(hostname).crt"


echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "    restarted apache and php$version-fpm    "
echo "    add ca.homestead.$(hostname).crt to your trusted certificates https://www.comodo.com/support/products/authentication_certs/setup/mac_chrome.php"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
