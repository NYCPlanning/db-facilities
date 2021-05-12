#!/bin/bash
function init {
    docker-compose up -d
    docker-compose exec -T facdb facdb init
}

function facdb_execute {
    docker-compose exec -T facdb facdb $@
}

function facdb_upload {
    local branchname=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    local DATE=$(date "+%Y-%m-%d")
    local PATH=edm-publishing/db-facilities/$branchname
    echo "$PATH"
    mc rm -r --force spaces/$PATH/latest
    mc rm -r --force spaces/$PATH/$DATE
    mc cp -r output spaces/$PATH/latest
    mc cp -r output spaces/$PATH/$DATE
}

case $1 in
    init) init ;;
    upload) facdb_upload ;;
    *) facdb_execute $@ ;;
esac
