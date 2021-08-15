#!/bin/bash

DAYCOUNT_UNTIL_UPDATE=7
WEBUSER="nginx"
PHP="php"
NEXTCLOUD_ROOT="/var/www/nextcloud"

echo "NC_UPGRADE: Starting Nextcloud check & upgrade."

if [ ! -e "./daycountfile" ]
then
  touch ./daycountfile
  echo "0" > "./daycountfile"
fi

daycounter=$(<daycountfile)

update_available=$(sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ update:check | grep Nextcloud)
wait

function check_daycount()
{
  if [ $daycounter -ge $DAYCOUNT_UNTIL_UPDATE ]
  then
    echo "NC_UPGRADE: Invoking Nextcloud upgrade (waited $daycounter days after update was available)."
    sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/updater/updater.phar --no-interaction
    sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ upgrade --no-interaction
    sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ db:add-missing-indices --no-interaction
    sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ db:add-missing-columns --no-interaction
    sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ db:convert-filecache-bigint --no-interaction
    daycounter=0
  else
    let daycounter=daycounter+1
    echo "NC_UPGRADE: Skipping Nextcloud upgrade ($daycounter/$DAYCOUNT_UNTIL_UPDATE)."
  fi
  echo "$daycounter" > "./daycountfile"
}

if [ ! -z "$update_available" ]
then 
  check_daycount
else
  echo "NC_UPGRADE: No Nextcloud upgrade available."
  echo "NC_UPGRADE: Update all Nextcloud apps."
  sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ app:update --all --no-interaction
fi