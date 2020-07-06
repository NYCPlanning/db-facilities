ALTER TABLE nysed_activeinstitutions 
DROP COLUMN IF EXISTS ogc_fid;

ALTER TABLE nysed_nonpublicenrollment 
DROP COLUMN IF EXISTS ogc_fid;

CREATE TABLE nysed_activeinstitutions_tmp as (SELECT

		nysed_activeinstitutions.*,
		nysed_nonpublicenrollment.*,
		
		(CASE 

			WHEN (prek::numeric+half_k::numeric+full_k::numeric+gr_1::numeric+gr_2::numeric+gr_3::numeric+gr_4::numeric+gr_5::numeric+gr_6::numeric+uge::numeric+gr_7::numeric+gr_8::numeric+gr_9::numeric+gr_10::numeric+gr_11::numeric+gr_12::numeric+ugs::numeric) IS NOT NULL THEN (prek::numeric+half_k::numeric+full_k::numeric+gr_1::numeric+gr_2::numeric+gr_3::numeric+gr_4::numeric+gr_5::numeric+gr_6::numeric+uge::numeric+gr_7::numeric+gr_8::numeric+gr_9::numeric+gr_10::numeric+gr_11::numeric+gr_12::numeric+ugs::numeric)

			ELSE NULL

		END) AS enrollment

		FROM nysed_activeinstitutions

		LEFT JOIN nysed_nonpublicenrollment

		ON trim(replace(nysed_nonpublicenrollment.beds_code,',',''),' ')::text = nysed_activeinstitutions.sed_code::text);

DROP TABLE nysed_activeinstitutions;
CREATE TABLE nysed_activeinstitutions AS (SELECT * FROM nysed_activeinstitutions_tmp);
DROP TABLE nysed_activeinstitutions_tmp;


ALTER TABLE nysed_activeinstitutions
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

UPDATE nysed_activeinstitutions as t
SET hash =  md5(CAST((t.*)AS text)),
	wkb_geometry = (CASE
				        WHEN wkb_geometry IS NULL AND longitude != '0' AND latitude != '0'
					        THEN ST_SetSRID(ST_Point(longitude::DOUBLE PRECISION, 
												 	 latitude::DOUBLE PRECISION), 4326)
				        ELSE wkb_geometry
				    END),
	address = (CASE 
					WHEN wkb_geometry is not NULL 
						THEN geo_house_number || ' ' || geo_street_name
					ELSE physical_address_line1             
				END),
	facname = popular_name,
	factype = (CASE
						WHEN inst_sub_type_description LIKE '%CHARTER SCHOOL%'
			
							THEN 'Charter School'
			
						WHEN inst_type_description = 'CUNY'
			
							THEN CONCAT('CUNY - ', initcap(right(inst_sub_type_description,-5)))
			
						WHEN inst_type_description = 'SUNY' 
			
							THEN CONCAT('SUNY - ', initcap(right(inst_sub_type_description,-5)))
			
						WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'
			
							AND (prek::numeric+half_k::numeric+full_k::numeric+gr_1::numeric+gr_2::numeric+gr_3::numeric+gr_4::numeric+gr_5::numeric+uge::numeric)>0
			
							THEN 'Elementary School - Non-public'
			
						WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'
			
							AND (gr_6::numeric+gr_7::numeric+gr_8::numeric)>0
			
							THEN 'Middle School - Non-public'
			
						WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'
			
							AND (gr_9::numeric+gr_10::numeric+gr_11::numeric+gr_12::numeric+ugs::numeric)>0
			
							THEN 'High School - Non-public'
			
						WHEN inst_type_description = 'NON-PUBLIC SCHOOLS'
			
							AND inst_sub_type_description NOT LIKE 'ESL'
			
							AND inst_sub_type_description NOT LIKE 'BUILDING'
			
							THEN 'Other School - Non-public'
			
						WHEN inst_sub_type_description LIKE '%AHSEP%'
			
							THEN initcap(split_part(inst_sub_type_description,'(',1))
			
						ELSE initcap(inst_sub_type_description)
			
					END),

	facsubgrp = (CASE

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
			
					END),
	facgroup = NULL,
	facdomain = NULL,
	servarea = NULL,
	opname = (CASE

						WHEN inst_type_description = 'PUBLIC SCHOOLS' THEN 'NYC Department of Education'
			
						WHEN inst_type_description LIKE '%NON-IMF%' THEN 'NYC Department of Education'
			
						WHEN inst_type_description = 'CUNY' THEN 'City University of New York'
			
						WHEN inst_type_description = 'SUNY' THEN 'State University of New York'
			
						ELSE initcap(legal_name)
			
					END),

	opabbrev = (CASE
			
						WHEN inst_type_description = 'PUBLIC SCHOOLS' THEN 'NYCDOE'
						
						WHEN inst_type_description = 'CUNY' THEN 'CUNY'
			
						WHEN inst_type_description = 'SUNY' THEN 'SUNY'
			
						ELSE 'Non-public'
			
					END),

	optype = (CASE
			
					WHEN inst_type_description = 'PUBLIC SCHOOLS' THEN 'Public'
		
					WHEN inst_type_description LIKE '%NON-IMF%' THEN 'Public'
		
					WHEN inst_type_description = 'CUNY' THEN 'Public'
		
					WHEN inst_type_description = 'SUNY' THEN 'Public'
		
					ELSE 'Non-public'
		
				END),
	overagency = 'NYC Department of Education',
	overabbrev = 'NYCDOE', 
	overlevel = NULL, 
	capacity = NULL, 
	captype = NULL, 
	proptype = NULL
	;

CREATE TABLE nysed_activeinstitutions_tmp as (
SELECT * FROM nysed_activeinstitutions
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
);
DROP TABLE nysed_activeinstitutions;
CREATE TABLE nysed_activeinstitutions AS (SELECT * FROM nysed_activeinstitutions_tmp);
DROP TABLE nysed_activeinstitutions_tmp;