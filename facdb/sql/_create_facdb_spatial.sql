DROP TABLE IF EXISTS facdb_spatial;
with boundary_geosupport as (
	SELECT
		uid,
		nullif(nullif(geo_1b->'result'->>'geo_borough_code',''), '0')::integer as borocode,
		nullif(geo_1b->'result'->>'geo_zip_code','') as zipcode,
		nullif(geo_1b->'result'->>'geo_bin','') as bin,
		nullif(nullif(geo_1b->'result'->>'geo_bbl',''), '0000000000') as bbl,
		nullif(geo_1b->'result'->>'geo_city','') as city,
		nullif(geo_1b->'result'->>'geo_commboard','') as commboard,
		nullif(geo_1b->'result'->>'geo_nta','') as nta,
		nullif(geo_1b->'result'->>'geo_council','') as council,
		nullif(geo_1b->'result'->>'geo_censtract','000000') as censtract,
		nullif(geo_1b->'result'->>'geo_policeprct','') as policeprct,
		nullif(geo_1b->'result'->>'geo_schooldist','') as schooldist,
		'geosupport' as boundarysource
	FROM facdb_base
	WHERE nullif(geo_1b->'result'->>'geo_grc','') IN ('00', '01')
	AND nullif(geo_1b->'result'->>'geo_grc2','') IN ('00', '01')
), boundary_spatial_join as (
	SELECT
		uid,
		coalesce(
			(select left(bbl::text, 1)::integer from dcp_mappluto b where st_intersects(b.wkb_geometry, a.geom)),
			(select borocode::integer from dcp_boroboundaries_wi b where st_intersects(b.wkb_geometry, a.geom))
		)as borocode,
		(select zipcode from doitt_zipcodeboundaries b where st_intersects(b.wkb_geometry, a.geom) limit 1) as zipcode,
		(select bin from doitt_buildingfootprints b where st_intersects(b.wkb_geometry, a.geom)) as bin,
		(select bbl::bigint::text from dcp_mappluto b where st_intersects(b.wkb_geometry, a.geom)) as bbl,
		(select UPPER(po_name) from doitt_zipcodeboundaries b where st_intersects(b.wkb_geometry, a.geom) limit 1) as city,
		(select borocd::text from dcp_cdboundaries b where st_intersects(b.wkb_geometry, a.geom)) as commboard,
		(select ntacode from dcp_ntaboundaries b where st_intersects(b.wkb_geometry, a.geom)) as nta,
		(select coundist::text from dcp_councildistricts b where st_intersects(b.wkb_geometry, a.geom)) as council,
		(select RIGHT(boroct2010::text, 6) from dcp_censustracts b where st_intersects(b.wkb_geometry, a.geom)) as censtract,
		(select precinct::text from dcp_policeprecincts b where st_intersects(b.wkb_geometry, a.geom)) as policeprct,
		(select schooldist::text from dcp_school_districts b where st_intersects(b.wkb_geometry, a.geom)) as schooldist,
		'spatial join' as boundarysource
	FROM facdb_geom a
	WHERE uid NOT IN (SELECT uid FROM boundary_geosupport) AND geom IS NOT NULL
)
SELECT
	uid,
	borocode,
	NULLIF(regexp_replace(LEFT(zipcode, 5), '[^0-9]+', '', 'g'), '0') as zipcode,
	(CASE WHEN bin LIKE '%000000' THEN NULL ELSE bin END) as bin,
	bbl,
	city,
	commboard,
	nta,
	council,
	censtract,
	policeprct,
	schooldist,
	boundarysource
INTO facdb_spatial
FROM (
    SELECT * FROM boundary_geosupport UNION
    SELECT * FROM boundary_spatial_join
) a;
