--select w.status::text, count(*) 
--from (select geo::json->'status' as status from dot_bridgehouses) w
--group by w.status::text;

ALTER TABLE dot_bridgehouses
	ADD hash text, 
	ADD	facname text,
	ADD	factype text,
	ADD	facsubgrp text,
	ADD	facgroup text,
	ADD	facdomain text, 
	ADD	servarea text,
	ADD	opname text,
	ADD	opabbrev text,
	ADD	optype text,
	ADD	overagency text,
	ADD	overabbrev text,
	ADD	overlevel text,
	ADD	capacity text,
	ADD	captype text,
	ADD	proptype text;

update dot_bridgehouses as t
SET hash =  md5(CAST((t.*)AS text)), 
	address = (CASE 
                        WHEN geo_street_name is not NULL and geo_house_number is not NULL 
                            THEN geo_house_number || ' ' || geo_street_name
                        ELSE address             
                    END),
	facname = site,
	factype = 'Bridge House',
	facsubgrp = 'Other Transportation',
	facgroup = NULL,
	facdomain = NULL,
	servarea = NULL,
	opname = 'NYC Department of Transportation',
	opabbrev = 'NYCDOT',
	optype = 'Public',
	overagency = 'NYC Department of Transportation',
	overabbrev = 'NYCDOT', 
	overlevel = NULL, 
	capacity = NULL, 
	captype = NULL, 
	proptype = NULL
;