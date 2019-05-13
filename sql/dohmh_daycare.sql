
--select w.status::text, count(*) 
--from (select geo::json->'status' as status from dohmh_daycare) w
--group by w.status::text;

ALTER TABLE dohmh_daycare
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

update dohmh_daycare as t
SET hash =  md5(CAST((t.*)AS text)), 
	facname = (CASE
				WHEN center_name LIKE '%SBCC%' THEN initcap(legal_name)
				WHEN center_name LIKE '%SCHOOL BASED CHILD CARE%' THEN initcap(legal_name)
				ELSE initcap(center_name)
			END),
	factype = (CASE
		
					WHEN (facility_type ~* 'camp') AND (program_type ~* 'All Age Camp') 
						THEN 'Camp - All Age'
		
					WHEN (facility_type ~* 'camp') AND (program_type ~* 'School Age Camp') 
						THEN 'Camp - School Age'
		
					WHEN (program_type ~* 'Preschool Camp') 
						THEN 'Camp - Preschool Age'
		
					WHEN (facility_type = 'GDC') AND (program_type = 'Child Care - Infants/Toddlers' OR program_type = 'INFANT TODDLER')
						THEN 'Group Day Care - Infants/Toddlers'
		
					WHEN (facility_type = 'GDC') AND (program_type = 'Child Care - Pre School' OR program_type = 'PRESCHOOL')
						THEN 'Group Day Care - Preschool'
		
					WHEN (facility_type = 'SBCC') AND (program_type = 'PRESCHOOL')
						THEN 'School Based Child Care - Preschool'
		
					WHEN (facility_type = 'SBCC') AND (program_type = 'INFANT TODDLER')
						THEN 'School Based Child Care - Infants/Toddlers'
						
					WHEN facility_type = 'SBCC'
						THEN 'School Based Child Care - Age Unspecified'
		
					WHEN facility_type = 'GDC'
						THEN 'Group Day Care - Age Unspecified'
						
					ELSE CONCAT(facility_type,' - ',program_type)
				END),
				
	facsubgrp = (CASE
					WHEN (facility_type ~* 'CAMP' OR program_type ILIKE '%CAMP%')
						THEN 'Camps'
					
					ELSE 'Day Care'
				END),

	facgroup = NULL,
	facdomain = NULL,
	servarea = NULL,
	opname = initcap(legal_name),
	opabbrev = 'Non-public',
	optype = 'Non-public',
	overagency = 'NYC Department of Health and Mental Hygiene',
	overabbrev = 'NYCDOHMH', 
	overlevel = NULL, 
	capacity = NULL, 
	captype = NULL, 
	proptype = NULL
;