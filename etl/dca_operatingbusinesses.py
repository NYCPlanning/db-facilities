# take 20m+ to run for 2019 data
from dataflows import *
from lib import dump_to_postgis, rename_field
import os
import csv
import sys
from pathlib import Path
from utils import url, fields, geo_flow, get_the_geom, quick_clean, get_hnum, get_sname

csv.field_size_limit(sys.maxsize)
        
def get_address(hnum, sname):
    '''
    This function is used to generate
    the facility address by combining
    house number and street name
    '''
    try:
        address = hnum + ' ' + sname
        return address
    except:
        return None

table_name = 'dca_operatingbusinesses'
dca_operatingbusinesses = Flow(
    load(url, resources = table_name, force_strings=False),
    checkpoint(table_name),
         
    filter_rows(not_equals = [
            dict(address_borough = 'Outside NYC'),
            ]),
            
    add_field('datasource', 'string', table_name),


    ################## geospatial ###################
    ###### Make sure the following columns ##########
    ###### exist before geo_flows          ########## 
    #################################################

    add_field('boro', 'string', ''),

    rename_field('address_zip','zipcode'),

    add_computed_field([dict(target=dict(name = 'address', type = 'string'),
                                    operation=lambda row: quick_clean(get_address(row['address_building'],
                                                            row['address_street_name']))
                                    ),
                        dict(target=dict(name = 'hnum', type = 'string'),
                                operation = lambda row: get_hnum(row['address'])
                                    ),
                        dict(target=dict(name = 'sname', type = 'string'),
                                    operation=lambda row: get_sname(row['address'])
                                    )
                        
                            ]),

    geo_flow,
    add_computed_field([dict(target=dict(name = 'the_geom_tmp', type = 'string'),
                            operation=lambda row: get_the_geom(row['geo_longitude'], row['geo_latitude'])
                            ),
                        dict(target=dict(name = 'the_geom', type = 'string'),
                            operation=lambda row: row['the_geom_tmp']
                                if row['the_geom_tmp'] != None
                                else get_the_geom(row['longitude'], row['latitude']) 
                            )
                        ]),
    dump_to_postgis(table_name)
)

dca_operatingbusinesses.process()