#!/bin/bash
CURRENT_DIR=$(dirname "$(readlink -f "$0")")
source $CURRENT_DIR/config.sh
max_bg_procs 5

import_public dcp_facilities &
import_public dcp_mappluto &
import_public dcp_boroboundaries_wi &
import_public dcp_censustracts &
import_public dcp_councildistricts &
import_public dcp_cdboundaries &
import_public dcp_ntaboundaries &
import_public dcp_policeprecincts &
import_public doitt_zipcodeboundaries &
import_public doitt_buildingfootprints &
import_public dcp_school_districts &

wait
