from dataflows import *
from lib import dump_to_postgis, rename_field
import os
import csv
import sys
from pathlib import Path
import re
from utils import url, fields, geo_flow, get_the_geom, quick_clean, get_hnum, get_sname

csv.field_size_limit(sys.maxsize)

table_name = 'doe_lcgms'
doe_lcgms = Flow(
    load(url, resources = table_name, force_strings=True),
    # cacheing table
    checkpoint(table_name),
    # datasource
    add_field('datasource', 'string', table_name),


    ################## geospatial ###################
    ###### Make sure the following columns ##########
    ###### exist before geo_flows          ########## 
    #################################################
    add_computed_field([dict(target=dict(name = 'address', type = 'string'),
                                            operation=lambda row: quick_clean(row['primary_address'])
                                            ),
                            dict(target=dict(name = 'hnum', type = 'string'),
                                    operation = lambda row: get_hnum(row['address'])
                                        ),
                                dict(target=dict(name = 'sname', type = 'string'),
                                        operation=lambda row: get_sname(row['address'])
                                        )
                            ]),
    rename_field('zip', 'zipcode'),
    add_field('boro', 'string'),
    
    geo_flow,
    
    add_computed_field([dict(target=dict(name = 'the_geom', type = 'string'),
                            operation=lambda row: get_the_geom(row['geo_longitude'], row['geo_latitude'])
                            )
                        ]),
    printer(num_rows=3),
    dump_to_postgis()
)

doe_lcgms.process()
