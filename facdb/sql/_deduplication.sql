-- For factype NYCHA COMMUNITY CENTER - CHILD CARE,
-- if dohmh_daycare has a site with the same BIN, delete the nycha record
DELETE FROM facdb
WHERE factype = 'NYCHA COMMUNITY CENTER - CHILD CARE'
AND datasource = 'nycha_communitycenters'
AND bin in (
	SELECT distinct bin FROM facdb
	WHERE datasource = 'dohmh_daycare'
);

-- For factype NYCHA COMMUNITY CENTER - SENIOR CENTER,
-- If dfta_contracts has a site with the same BIN, delete the nycha record
DELETE FROM facdb
WHERE factype = 'NYCHA COMMUNITY CENTER - SENIOR CENTER'
AND datasource = 'nycha_communitycenters'
AND bin in (
	SELECT distinct bin FROM facdb
	WHERE datasource = 'dfta_contracts'
);
