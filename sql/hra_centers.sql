--select w.status::text, count(*) 
--from (select geo::json->'status' as status from doe_busroutesgarages) w
--group by w.status::text;

ALTER TABLE hra_centers
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

update hra_centers as t
SET hash =  md5(CAST((t.*)AS text)), 
	facname = facility_name,
	factype = type,
	facsubgrp = (CASE 
                        WHEN type = 'Job Center' THEN 'Workforce Development'
                        ELSE 'Financial Assistance and Social Services'
                END),
	facgroup = NULL,
	facdomain = NULL,
	servarea = NULL,
	opname = 'NYC Human Resources Administration',
	opabbrev = 'NYCHRA',
	optype = 'Public',
	overagency = 'NYC Human Resources Administration',
	overabbrev = 'NYCHRA', 
	overlevel = NULL, 
	capacity = NULL, 
	captype = NULL, 
	proptype = NULL
;
