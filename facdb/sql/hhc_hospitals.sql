DROP TABLE IF EXISTS _hhc_hospitals;

SELECT
    uid,
    source,
    facility_name as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    regexp_replace(split_part(location_1, '(', 1), '.{6}$', '') as address,
    NULL as city,
    postcode as zipcode,
    borough as boro,
    NULL as borocode,
    bin,
    bbl,
    facility_type as factype,
    'Hospitals and Clinics' as facsubgrp,
    'NYC Health and Hospitals Corporation' as opname,
    'NYCHHC' as opabbrev,
    'NYSDOH' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _hhc_hospitals
FROM hhc_hospitals
WHERE facility_type <> 'Nursing Home';

CALL append_to_facdb_base('_hhc_hospitals');
