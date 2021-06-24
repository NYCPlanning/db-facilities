DROP TABLE IF EXISTS _dsny_fooddrop;
SELECT uid,
    source,
    CONCAT(food_scrap_drop_off_site, ' Food Drop-off Site') as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    location as address,
    NULL as city,
    zip_code as zipcode,
    borough as boro,
    NULL as borocode,
    NULL as bin,
    NULL as bbl,
    'Compost' as factype,
    'DSNY Drop-off Facility' as facsubgrp,
    serviced_by as opname,
    NULL as opabbrev,
    'NYCDSNY' as overabbrev,
    NULL as capacity,
    NULL as captype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    NULL as geo_bl,
    NULL as geo_bn
INTO _dsny_fooddrop
FROM dsny_fooddrop;

CALL append_to_facdb_base('_dsny_fooddrop');
