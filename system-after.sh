#!/bin/bash

# If you would like to do some extra work on the host you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

echo "adding cert to trusted root certs"
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.homestead.crt
