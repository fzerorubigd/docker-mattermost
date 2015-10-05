#!/bin/bash

#set -euo pipefail

DB_TYPE=${DB_TYPE:-postgres}
DB_HOST=${DB_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
DB_PORT=${DB_PORT:-${POSTGRESQL_PORT_5432_TCP_PORT}}

# support for linked official postgres image
DB_USER=${DB_USER:-${POSTGRESQL_ENV_POSTGRES_USER:-${POSTGRESQL_ENV_DB_USER}}}
DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_POSTGRES_PASSWORD:-${POSTGRESQL_ENV_DB_PASS}}}
DB_NAME=${DB_NAME:-${POSTGRESQL_ENV_DB_PASS:-${DB_USER}}}

DB_USER=${DB_USER:-${POSTGRESQL_ENV_}}
DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_POSTGRES_PASSWORD}}

POSTGRESQL_HOST=${DB_HOST}
POSTGRESQL_PORT=${DB_PORT}
FILE=$1
if [ "${FILE: -5}" == ".json" ]; then
    if [ ! -f ${FILE} ]; then
        cp /home/mattermost/mattermost/config/config.json ${FILE}
    fi
    # overwrite all the keys 
    
    JSON=$(cat $FILE | jq '.SqlSettings.DriverName="postgres"' | jq ".SqlSettings.DataSource=\"postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable&connect_timeout=10\"")
    ENVLIST=$(env | grep MATTERMOST_)
    ALL_ARR=($ENVLIST)
    for KEY in ${ALL_ARR[@]};
        do
        JSON_KEY=$(echo $KEY | cut -d= -f1 | tr '[:upper:]' '[:lower:]' |sed 's/mattermost/./g' | sed -r 's/(^|_)([a-z])/\U\2/g' | sed 's/_/./g')
        JSON_VALUE=$(echo $KEY | cut -d= -f2)
        TMP=$(echo $JSON| jq "del($JSON_KEY)")
        JSON=$(echo $TMP | jq "$JSON_KEY=\"$JSON_VALUE\"")
        echo $JSON_KEY
        echo $JSON_VALUE
    done;
    
    echo $JSON > ${FILE}
    /home/mattermost/mattermost/bin/platform -config=${FILE}
else
    exec "$@"
fi;
