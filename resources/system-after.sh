#!/bin/bash

# If you would like to do some extra work on the host you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

if [[ "$2" == 'up' || "$2" == 'provision' ]] && [[ ! -f ./.created ]] ;
then

    # https://github.com/laravel/homestead/pull/773
    # https://stackoverflow.com/questions/45263265/use-ssl-on-laravel-homestead
    # https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
    echo "adding cert $1  to trusted root certs"

    if [[ $( sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "ca.$1.crt" ) ]]
    then
        echo "killing chrome to get the new certificate"
        pkill -a -i "Google Chrome"
    fi

    touch ./.created

fi