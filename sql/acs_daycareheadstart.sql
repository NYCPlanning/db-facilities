--select w.status::text, count(*) 
--from (select geo::json->'status' as status from doe_busroutesgarages) w
--group by w.status::text;

ALTER TABLE acs_daycareheadstart
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

update acs_daycareheadstart as t
SET hash =  md5(CAST((t.*)AS text)), 
	facname = initcap(program_name),
	factype = 'Day Care',
	facsubgrp = 'Day Care',
	facgroup = NULL,
	facdomain = NULL,
	servarea = NULL,
	opname = initcap(contractor_name),
	opabbrev = NULL,
	optype = 'Non-public',
	overagency = 'NYC Administration for Childrens Services',
	overabbrev = 'NYCACS',
	overlevel = NULL,
	capacity = total,
	captype = 'Seats in ACS Contract',
	proptype = NULL
;
