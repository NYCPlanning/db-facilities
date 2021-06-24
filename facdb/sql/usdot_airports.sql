DROP TABLE IF EXISTS _usdot_airports;
SELECT
    uid,
    source,
    fac_name as facname,
    NULL as addressnum,
    NULL as streetname,
    NULL as address,
    city,
    NULL as zipcode,
    county as boro,
    NULL as borocode,
    NULL as bin,
    NULL as bbl,
    fac_type as factype,
    'Airports and Heliports' as facsubgrp,
    (CASE
        WHEN owner_type = 'Pr' THEN fac_name
        ELSE 'Public'
    END) as opname,
    (CASE
        WHEN owner_type = 'Pr' THEN 'Non-public'
        ELSE 'Public'
    END) as opabbrev,
    'USDOT' as overabbrev,
    NULL as capacity,
    NULL as captype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    NULL geo_bl,
    NULL geo_bn
INTO _usdot_airports
FROM usdot_airports;

CALL append_to_facdb_base('_usdot_airports');
