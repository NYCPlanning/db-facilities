DROP TABLE IF EXISTS _dsny_leafdrop;
SELECT uid,
    source,
    CONCAT(site_name, ' Leaf Drop-off Site') as facname,
    number as addressnum,
    street as streetname,
    address,
    NULL as city,
    zipcode,
    borough as boro,
    NULL as borocode,
    bin,
    bbl,
    'DSNY Drop-Off Facility' as factype,
    'Solid Waste Transfer and Carting' as facsubgrp,
    site_managed_by as opname,
    NULL as opabbrev,
    'NYCDSNY' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _dsny_leafdrop
FROM dsny_leafdrop;

CALL append_to_facdb_base('_dsny_leafdrop');
