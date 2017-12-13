#!/usr/bin/env bash

if [ ! -d /etc/cron.d ]; then
    mkdir /etc/cron.d
fi

SITE_DOMAIN=$1
SITE_PUBLIC_DIRECTORY=$2

cron="* * * * * vagrant /usr/bin/php $SITE_PUBLIC_DIRECTORY/../artisan schedule:run >> /dev/null 2>&1"

echo "$cron" > "/etc/cron.d/homestead-schedule-$SITE_DOMAIN"
