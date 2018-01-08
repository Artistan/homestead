#!/bin/bash
if [[ "$2" == 'destroy' ]] && [[ -f ./.created ]] ;
 then

    sudo security delete-certificate -n "$1 Root CA" /Library/Keychains/System.keychain
    rm -f ./.created

fi