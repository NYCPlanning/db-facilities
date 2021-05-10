DROP TABLE IF EXISTS _nycha_communitycenters;

SELECT
    uid,
    source,
    development as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    address as address,
    NULL as city,
    NULL as zipcode,
    borough as boro,
    NULL as borocode,
    bin,
    bbl,
    (CASE
		WHEN program_type = 'NORC' THEN 'NORC Services'
		ELSE 'NYCHA Community Center - '|| initcap(program_type)
	END) as factype,
    (CASE
		WHEN program_type = 'NORC' THEN 'Senior Services'
		ELSE 'Community Centers and Community School Programs'
	END) as facsubgrp,
    'NYC Housing Authority' as opname,
    'NYCHA' as opabbrev,
    'NYCHA' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _nycha_communitycenters
FROM nycha_communitycenters;

CALL append_to_facdb_base('_nycha_communitycenters');
