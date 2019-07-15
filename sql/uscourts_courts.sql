--select w.status::text, count(*) 
--from (select geo::json->'status' as status from dpr_parksproperties) w
--group by w.status::text;

ALTER TABLE uscourts_courts
	ADD hash text,
	ADD facname text,
	ADD factype text,
	ADD facsubgrp text,
	ADD facgroup text,
	ADD facdomain text, 
	ADD servarea text,
	ADD opname text,
	ADD opabbrev text,
	ADD optype text,
	ADD overagency text,
	ADD overabbrev text,
	ADD overlevel text,
	ADD capacity text,
	ADD captype text,
	ADD proptype text;

UPDATE uscourts_courts as t
SET hash = md5(CAST((t.*)AS text)),
    address = (CASE 
                        WHEN the_geom is not NULL 
                            THEN geo_house_number || ' ' || geo_street_name
                        ELSE buildingaddress             
                    END),
	facname = buildingname,
	factype = courttype,
	facsubgrp = 
	(CASE 
		WHEN upper(courttype) LIKE '%COURT%' THEN 'Courthouses and Judicial'
		ELSE 'Legal and Intervention Services'
	END),
	facgroup = NULL,
	facdomain = NULL,
	servarea = NULL,
	opname = officename,
	opabbrev = NULL,
	optype = 'Public',
	overagency = 'US Courts',
	overabbrev = 'USCOURTS',
	overlevel = NULL,
	capacity = NULL,
	captype = NULL,
	proptype = NULL