#!/usr/bin/env bash
# Version 1.0

set -e

#echo "Removing Widget parameter.yml"
#rm --force app/config/parameters.yml
echo "Calling PHP Composer"
composer install --prefer-dist --optimize-autoloader --no-interaction
