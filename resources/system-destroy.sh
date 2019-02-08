#!/bin/bash
if [[ "$2" == 'destroy' ]] && [[ -f ./.created ]] ;
 then

    sudo security delete-certificate -c "$1 Root CA" /Library/Keychains/System.keychain
    rm -f ./.created
    rm -f "./ca.homestead.$(hostname).crt"

fi
