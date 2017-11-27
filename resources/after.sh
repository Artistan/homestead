#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

if [ -f 'aftermath' ]; then
        echo "you have already been through the aftermath"
        sudo apt-get update;
        sudo systemctl restart elasticsearch
        echo "update complete"
else
	# Install oh-my-zsh
        apt-get install zsh jq -y
        git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh
        git clone https://github.com/Artistan/powerlevel9k.git /home/vagrant/.oh-my-zsh/custom/themes/powerlevel9k
        cd /home/vagrant/.oh-my-zsh/custom/themes/powerlevel9k; git checkout color_names;
        sudo cp /vagrant/resources/.zshrc /home/vagrant/.zshrc
        sudo cp /vagrant/resources/.my.cnf /home/vagrant/.my.cnf
        # change the default shell for vagrant
        sudo chsh -s $(which zsh) vagrant

        # setup xdebug
        sudo phpenmod xdebug;
        sudo dir -p ~/Code/xdebug
        sudo cp /vagrant/xdebug.ini /etc/php/7.1/fpm/conf.d/20-xdebug.ini
        sudo nginx -s reload
        sudo service php7.1-fpm restart;
        # install some helpers and required stuff for laravel && elasticsearch
        sudo apt-get --assume-yes install default-jre;
        sudo apt-get --assume-yes install htop;
        sudo apt-get --assume-yes install mytop;
        sudo apt-get --assume-yes install memcached;
        sudo apt-get --assume-yes install php-memcached;
        # install elasticsearch
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -;
        sudo echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list;
        sudo apt-get update && sudo apt-get --assume-yes install elasticsearch;
        sudo systemctl enable elasticsearch.service;
        sudo chmod -R 777 /etc/elasticsearch;
        sudo echo 'cluster.name: Homestead' >> /etc/elasticsearch/elasticsearch.yml;
        sudo echo 'network.host: ["_local_","_site_"]' >> /etc/elasticsearch/elasticsearch.yml;
        sudo echo 'path.repo: "/tmp/repositories"' >> /etc/elasticsearch/elasticsearch.yml;
        sudo chmod 644 /etc/elasticsearch/*;
        sudo chmod 755 /etc/elasticsearch;
        sudo systemctl restart elasticsearch
        touch 'aftermath'
        echo "installation complete"
        # make sure memcached will start
        systemctl start memcached.service
        systemctl enable memcached.service
        systemctl status memcached.service

        # own it.
        chown -R vagrant:vagrant /home/vagrant
        echo "install complete"
fi
sudo apt-get upgrade
echo "upgrade complete"

