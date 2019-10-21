from facdb.helper.engines import facdb_engine
from facdb.helper.exporter import exporter
from facdb.helper.importer import importer
from multiprocessing import Pool, cpu_count
from facdb.helper.geocode import geocode, get_hnum, get_sname, quick_clean
import pandas as pd
import numpy as np

if __name__ == "__main__":
    table_name = 'usdot_ports'
    df = importer(table_name, from_url=False, 
                sql=f'''
                select state_post, county_nam, street_add, 
                    operators, nav_unit_n, wkb_geometry, owners
                from {table_name}.latest
                ''')
    df['datasource'] = table_name
    df = df[df.state_post == 'NY']
    df = df[df.county_nam.str.lower().isin(['kings', 
                            'new york',
                            'bronx', 
                            'queens',
                            'richmond'])]
    df['address'] = df['street_add'].apply(quick_clean)
    df['sname'] = df['address'].apply(get_sname)
    df['hnum'] = df['address'].apply(get_hnum)
    df['boro'] = df['county_nam']
    df = df.rename(columns={'wkb_geometry':'point_location'})
    records = df.to_dict('records')

    ## geocode
    with Pool(processes=cpu_count()) as pool:
        it = pool.map(geocode, records, 1000)
    
    df = pd.DataFrame(it)

    # Export to build engine
    exporter(df, table_name)