#!/bin/bash
function init {
    docker-compose up -d 
}

function facdb_execute {
    docker-compose exec facdb facdb $@
}

case $1 in
    init) init ;;
    *) facdb_execute $@;;
esac
