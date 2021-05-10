DROP TABLE IF EXISTS _dsny_textiledrop;
SELECT uid,
    source,
    CONCAT(vendor_name, ' Textile Drop-off Site') as facname,
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
    vendor_name as opname,
    NULL as opabbrev,
    'NYCDSNY' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _dsny_textiledrop
FROM dsny_textiledrop;

CALL append_to_facdb_base('_dsny_textiledrop');
