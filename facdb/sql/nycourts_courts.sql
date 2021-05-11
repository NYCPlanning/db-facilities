DROP TABLE IF EXISTS _nycourts_courts;

SELECT
    uid,
    source,
    name as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    address as address,
    NULL as city,
    zipcode,
    borough as boro,
    NULL as borocode,
    NULL as bin,
    NULL as bbl,
    'Courthouse' as factype,
    'Courthouses and Judicial' as facsubgrp,
    'NYS Unified Court System' as opname,
    'NYCOURTS' as opabbrev,
    'NYCOURTS' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    NULL as wkb_geometry,
    geo_1b,
    NULL as geo_bl,
    NULL as geo_bn
INTO _nycourts_courts
FROM nycourts_courts
WHERE uid IN (
SELECT min(uid)
FROM nycourts_courts
GROUP BY REPLACE(
            REPLACE(
                REPLACE(name,
                    ' (Summons Court)',''),
            ' (Summons Court )',''),
        'The ','')
    , address);

CALL append_to_facdb_base('_nycourts_courts');
