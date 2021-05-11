DROP TABLE IF EXISTS _moeo_socialservicesitelocations;

WITH tmp AS(
    SELECT MIN(uid) AS uid
    FROM moeo_socialservicesitelocations
    GROUP BY program_name||provider_name, address_1
)
SELECT
    uid,
    source,
    CONCAT(provider_name, ' ' ,program_name) as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    address_1 as address,
    city,
    postcode as zipcode,
    borough as boro,
    LEFT(bin::text, 1) as borocode,
    bin,
    bbl,
    (CASE
        WHEN program_name = 'NORC SITES' THEN 'NORC Services'
        WHEN program_name = 'TRANSPORTATION ONLY' THEN 'Transportation'
        ELSE initcap(program_name)
    END) as factype,
    (CASE
        WHEN program_name = 'JOBS & INTERNSHIPS' THEN 'Workforce Development'
        WHEN program_name = 'GERIATRIC MENTAL HEALTH' THEN 'Mental Health'
        WHEN program_name = 'NORC SITES' THEN 'Senior Services'
        WHEN program_name = 'READING & WRITING' THEN 'Adult and Immigrant Literacy'
        WHEN program_name = 'IMMIGRANT SERVICES' THEN 'Immigrant Services'
        WHEN program_name = 'TRANSPORTATION ONLY' THEN 'Senior Services'
        WHEN program_name = 'AFTERSCHOOL PROGRAMS' THEN 'After-School Programs'
        ELSE 'Other Health Care'
    END) as facsubgrp,
    provider_name as opname,
    NULL as opabbrev,
    'NYC'||agency_name as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    NULL as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _moeo_socialservicesitelocations
FROM moeo_socialservicesitelocations
WHERE uid IN (SELECT uid FROM tmp)
AND program_name !~* 'Home Delivered Meals|senior center|CONDOM DISTRIBUTION SERVICES|GROWING UP NYC INITIATIVE SUPPORT SERVICES|PLANNING AND EVALUATION [BASE]|TO BE DETERMINED - UNKNOWN';

CALL append_to_facdb_base('_moeo_socialservicesitelocations');
