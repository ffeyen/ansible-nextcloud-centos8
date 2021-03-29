#!/bin/sh

WEBUSER="nginx"
PHP="php"
NEXTCLOUD_ROOT="/var/www/nextcloud"

sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/updater/updater.phar --no-interaction
sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ upgrade --no-interaction
sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ db:add-missing-indices --no-interaction
sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ db:add-missing-columns --no-interaction
sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ db:convert-filecache-bigint --no-interaction
sudo -u $WEBUSER $PHP $NEXTCLOUD_ROOT/occ app:update --all --no-interaction