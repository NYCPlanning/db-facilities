#!/bin/bash
CURRENT_DIR=$(dirname "$(readlink -f "$0")")
source $CURRENT_DIR/config.sh
max_bg_procs 5

mkdir -p output && (
    cd output
    echo "*" > .gitignore
    CSV_export facdb facilities
    SHP_export facdb POINT
)
