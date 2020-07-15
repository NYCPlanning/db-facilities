ALTER TABLE nysed_activeinstitutions 
DROP COLUMN IF EXISTS ogc_fid;

SELECT 
	md5(CAST((t.*)AS text)) AS hash,
	(CASE
		WHEN wkb_geometry IS NULL 
		AND "gis_longitute_(x)" != '0' 
		AND "gis_latitude_(y)" != '0'
		THEN ST_SetSRID(
				ST_Point("gis_longitute_(x)"::DOUBLE PRECISION, "gis_latitude_(y)"::DOUBLE PRECISION), 4326)
		ELSE wkb_geometry
	END) as wkb_geometry,
	(CASE 
		WHEN wkb_geometry is not NULL 
			THEN geo_house_number || ' ' || geo_street_name
		ELSE physical_address_line1             
	END) as address,
	popular_name as facname,
	(CASE
		WHEN inst_sub_type_description LIKE '%CHARTER SCHOOL%'

			THEN 'Charter School'

		WHEN inst_type_description = 'CUNY'

			THEN CONCAT('CUNY - ', initcap(right(inst_sub_type_description,-5)))

		WHEN inst_type_description = 'SUNY' 

			THEN CONCAT('SUNY - ', initcap(right(inst_sub_type_description,-5)))

		WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'

			AND (prek::numeric+halfk::numeric+fullk::numeric+gr1::numeric+gr2::numeric+gr3::numeric+gr4::numeric+gr5::numeric+uge::numeric)>0

			THEN 'Elementary School - Non-public'

		WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'

			AND (gr6::numeric+gr7::numeric+gr8::numeric)>0

			THEN 'Middle School - Non-public'

		WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'

			AND (gr9::numeric+gr10::numeric+gr11::numeric+gr12::numeric+ugs::numeric)>0

			THEN 'High School - Non-public'

		WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'

			AND inst_sub_type_description NOT LIKE 'ESL'

			AND inst_sub_type_description NOT LIKE 'BUILDING'

			THEN 'Other School - Non-public'

		WHEN inst_sub_type_description LIKE '%AHSEP%'

			THEN initcap(split_part(inst_sub_type_description,'(',1))

		ELSE initcap(inst_sub_type_description)

	END) as factype,

	(CASE
		WHEN inst_sub_type_description LIKE '%GED-ALTERNATIVE%' THEN 'GED and Alternative High School Equivalency'

		WHEN inst_sub_type_description LIKE '%CHARTER SCHOOL%'

			THEN 'Charter K-12 Schools'

		WHEN inst_sub_type_description LIKE '%MUSEUM%' THEN 'Museums'

		WHEN inst_sub_type_description LIKE '%HISTORICAL%' THEN 'Historical Societies'

		WHEN inst_type_description LIKE '%LIBRARIES%' THEN 'Academic and Special Libraries'

		WHEN inst_type_description LIKE '%CHILD NUTRITION%' THEN 'Child Nutrition'

		WHEN inst_sub_type_description LIKE '%PRE-SCHOOL%' AND (inst_sub_type_description LIKE '%DISABILITIES%' OR inst_sub_type_description LIKE '%SWD%')

			THEN 'Preschools for Students with Disabilities'

		WHEN (inst_type_description LIKE '%DISABILITIES%')

			THEN 'Public and Private Special Education Schools'

		WHEN inst_sub_type_description LIKE '%PRE-K%' THEN 'City Government Offices'

		WHEN (inst_type_description LIKE 'PUBLIC%') OR (inst_sub_type_description LIKE 'PUBLIC%') THEN 'Public K-12 Schools'

		WHEN (inst_type_description LIKE '%COLLEGE%') OR (inst_type_description LIKE '%CUNY%') OR 

			(inst_type_description LIKE '%SUNY%') OR (inst_type_description LIKE '%SUNY%')

			THEN 'Colleges or Universities'

		WHEN inst_type_description LIKE '%PROPRIETARY%'

			THEN 'Proprietary Schools'

		WHEN inst_type_description LIKE '%NON-IMF%'

			THEN 'Public K-12 Schools'

		ELSE 'Non-Public K-12 Schools'

	END) as facsubgrp,
	NULL as facgroup,
	NULL as facdomain,
	NULL as servarea,
	(CASE
		WHEN inst_type_description = 'PUBLIC SCHOOLS' THEN 'NYC Department of Education'

		WHEN inst_type_description LIKE '%NON-IMF%' THEN 'NYC Department of Education'

		WHEN inst_type_description = 'CUNY' THEN 'City University of New York'

		WHEN inst_type_description = 'SUNY' THEN 'State University of New York'

		ELSE initcap(legal_name)

	END) as opname,

	(CASE
			
		WHEN inst_type_description = 'PUBLIC SCHOOLS' THEN 'NYCDOE'
		
		WHEN inst_type_description = 'CUNY' THEN 'CUNY'

		WHEN inst_type_description = 'SUNY' THEN 'SUNY'

		ELSE 'Non-public'

	END) as opabbrev,

	(CASE
			
		WHEN inst_type_description = 'PUBLIC SCHOOLS' THEN 'Public'

		WHEN inst_type_description LIKE '%NON-IMF%' THEN 'Public'

		WHEN inst_type_description = 'CUNY' THEN 'Public'

		WHEN inst_type_description = 'SUNY' THEN 'Public'

		ELSE 'Non-public'

	END) as optype,
	'NYC Department of Education' as overagency,
	'NYCDOE' as overabbrev, 
	NULL as overlevel, 
	NULL as capacity, 
	NULL as captype, 
	NULL as proptype
	INTO _nysed_activeinstitutions
	FROM nysed_activeinstitutions as t
	WHERE
		(inst_type_description = 'PUBLIC SCHOOLS' AND inst_sub_type_description LIKE '%GED%')
		OR inst_sub_type_description LIKE '%CHARTER SCHOOL%'
		OR (inst_type_description <> 'PUBLIC SCHOOLS'
		AND inst_type_description <> 'NON-IMF SCHOOLS'
		AND inst_type_description <> 'GOVERNMENT AGENCIES' -- MAY ACTUALLY WANT TO USE THESE
		AND inst_type_description <> 'INDEPENDENT ORGANIZATIONS'
		AND inst_type_description <> 'LIBRARY SYSTEMS'
		AND inst_type_description <> 'LOCAL GOVERNMENTS'
		AND inst_type_description <> 'SCHOOL DISTRICTS'
		AND inst_sub_type_description <> 'PUBLIC LIBRARIES'
		AND inst_sub_type_description <> 'HISTORICAL RECORDS REPOSITORIES'
		AND inst_sub_type_description <> 'CHARTER CORPORATION'
		AND inst_sub_type_description <> 'HOME BOUND'
		AND inst_sub_type_description <> 'HOME INSTRUCTED'
		AND inst_sub_type_description <> 'NYC BUREAU'
		AND inst_sub_type_description <> 'NYC NETWORK'
		AND inst_sub_type_description <> 'OUT OF DISTRICT PLACEMENT'
		AND inst_sub_type_description <> 'BUILDINGS UNDER CONSTRUCTION')
	;

DROP TABLE IF EXISTS nysed_activeinstitutions;

ALTER TABLE _nysed_activeinstitutions
RENAME TO nysed_activeinstitutions;