#!/bin/bash

# Run Shell profile
[ -f /etc/profile ] &&  source /etc/profile
[ -f ~/.profile ] &&  source ~/.profile

##
# Run command or php -fpm
#
# Source: https://github.com/docker-library/php/blob/master/8.0/alpine3.13/fpm/docker-php-entrypoint
##

set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"