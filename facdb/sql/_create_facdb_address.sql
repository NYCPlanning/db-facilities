DROP TABLE IF EXISTS facdb_address;
WITH _facdb_address AS (
    SELECT
        uid,
        addressnum,
        streetname,
        nullif(geo_1b->'result'->>'geo_house_number','') as geo_house_number,
        nullif(geo_1b->'result'->>'geo_street_name','') as geo_street_name,
        nullif(geo_1b->'result'->>'geo_grc','') as geo_grc,
        nullif(geo_1b->'result'->>'geo_grc2','') as geo_grc2,
        geo_1b->'inputs'->>'input_hnum' as input_hnum,
        geo_1b->'inputs'->>'input_sname' as input_sname,
        address as raw_address
    FROM facdb_base
)
SELECT
    COALESCE(nullif(geo_house_number||' '||geo_street_name,''), UPPER(raw_address)) as address,
    *
FROM _facdb_address
INTO facdb_address
;
