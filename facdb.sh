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
    local SPACES="spaces/edm-publishing/db-facilities/$branchname"
    mc rm -r --force $SPACES/latest
    mc cp -r output $SPACES/latest
    mc rm -r --force $SPACES/$DATE
    mc cp -r output $SPACES/$DATE
}

case $1 in
    init) init ;;
    upload) facdb_upload ;;
    *) facdb_execute $@ ;;
esac
