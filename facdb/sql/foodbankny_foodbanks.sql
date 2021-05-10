DROP TABLE IF EXISTS _foodbankny_foodbanks;

SELECT
    uid,
    source,
    name as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    address,
    city,
    zip_code as zipcode,
    NULL as boro,
    NULL as borocode,
    NULL as bin,
    NULL as bbl,
    (CASE
		WHEN program_type ~* 'pantry' THEN 'Food Pantry'
		WHEN program_type ~* 'Soup Kitchen' THEN 'Soup Kitchen'
	END) as factype,
    'Soup Kitchens and Food Pantries' as facsubgrp,
    name as opname,
    'Non-public' as opabbrev,
    'Non-public' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    NULL as wkb_geometry,
    geo_1b,
    NULL as geo_bl,
    NULL as geo_bn
INTO _foodbankny_foodbanks
FROM foodbankny_foodbanks
WHERE program_type !~* 'senior';

CALL append_to_facdb_base('_foodbankny_foodbanks');
