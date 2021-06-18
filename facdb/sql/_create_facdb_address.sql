DROP TABLE IF EXISTS facdb_address;
SELECT
	uid,
	source,
	(CASE WHEN source = 'dcp_colp' then addressnum else geo_house_number END) as addressnum,
	(CASE WHEN source = 'dcp_colp' then streetname else geo_street_name END) as streetname,
	UPPER(CASE
		WHEN source = 'dcp_colp' then address
		WHEN geo_grc in ('00', '01') and geo_grc2 in ('00', '01')
		THEN nullif(geo_house_number||' '||geo_street_name,'')
	ELSE address END) as address
INTO facdb_address
FROM (
	SELECT
        uid,
        source,
        addressnum,
        TRIM(regexp_replace(facdb_address.streetname, '\s+', ' ', 'g')) as streetname,
        nullif(geo_1b->'result'->>'geo_house_number','') as geo_house_number,
        nullif(geo_1b->'result'->>'geo_street_name','') as geo_street_name,
        nullif(geo_1b->'result'->>'geo_grc','') as geo_grc,
        nullif(geo_1b->'result'->>'geo_grc2','') as geo_grc2,
        geo_1b->'inputs'->>'input_hnum' as input_hnum,
        geo_1b->'inputs'->>'input_sname' as input_sname,
        address
    FROM facdb_base
) a;
