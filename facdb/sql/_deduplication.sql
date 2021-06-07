-- For factype NYCHA COMMUNITY CENTER - CHILD CARE,
-- if dohmh_daycare has a site with the same BIN, delete the nycha record
DELETE FROM facdb
WHERE factype = 'NYCHA COMMUNITY CENTER - CHILD CARE'
AND datasource = 'nycha_communitycenters'
AND bin IS NOT NULL
AND bin in (
	SELECT distinct bin FROM facdb
	WHERE datasource = 'dohmh_daycare'
);

-- For factype NYCHA COMMUNITY CENTER - SENIOR CENTER,
-- If dfta_contracts has a site with the same BIN, delete the nycha record
DELETE FROM facdb
WHERE factype = 'NYCHA COMMUNITY CENTER - SENIOR CENTER'
AND datasource = 'nycha_communitycenters'
AND bin IS NOT NULL
AND bin in (
	SELECT distinct bin FROM facdb
	WHERE datasource = 'dfta_contracts'
);

-- Remove out of NYC zipcodes
DELETE FROM facdb WHERE zipcode NOT IN (SELECT zipcode::integer FROM doitt_zipcodeboundaries);

-- Remove records outside of NYC based on geometry
DELETE FROM facdb WHERE geom IS NOT NULL AND uid NOT IN (
    SELECT a.uid FROM facdb a, (
		SELECT ST_Union(wkb_geometry) As geom FROM dcp_boroboundaries_wi
	) b WHERE ST_Contains(ST_SetSRID(b.geom, 4326), a.geom)
 );
