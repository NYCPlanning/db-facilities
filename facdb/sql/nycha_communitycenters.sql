DROP TABLE IF EXISTS _nycha_communitycenters;

WITH subgroup_flags AS(
  SELECT
    *,
    (program_type ~* 'Case Management')::int as grp1, --'LEGAL AND INTERVENTION SERVICES'
    (program_type ~* 'UPK')::int as grp2, --'DOE UNIVERSAL PRE-KINDERGARTEN'
    (program_type ~* 'Senior|NORC')::int as grp3, --'SENIOR SERVICES'
    (program_type ~* 'Day Care|Child Care')::int as grp4, --'DAY CARE'
    (program_type ~* 'Disabilities')::int as grp5, --'PROGRAMS FOR PEOPLE WITH DISABILITIES'
    (program_type ~* 'Storage')::int as grp6, --'STORAGE'
    (program_type ~* 'Job Readiness|Jobs Plus')::int as grp7, --'WORKFORCE DEVELOPMENT'
    (program_type ~* 'Vocational|Trade School')::int as grp8, --'GED AND ALTERNATIVE HIGH SCHOOL EQUIVALENCY'
    (program_type ~* 'School')::int as grp9, --'PUBLIC K-12 SCHOOLS'
    (program_type ~* 'NYPD')::int as grp10, --'POLICE SERVICES'
    (program_type ~* 'Food Pantry')::int as grp11, --'SOUP KITCHENS AND FOOD PANTRIES'
    (program_type ~* 'Mental|Counseling')::int as grp12, --'MENTAL HEALTH'
    (program_type ~* 'Clinic')::int as grp13, --'HOSPITALS AND CLINICS'
    (program_type ~* 'Plasterer''s Shop')::int as grp14, --'CUSTODIAL'
    (program_type ~* 'ESL|Literacy')::int as grp15, --'ADULT AND IMMIGRANT LITERACY'
    (program_type ~* 'Training')::int as grp16, --'TRAINING AND TESTING'
    (program_type ~* 'Library')::int as grp17, --'PUBLIC LIBRARIES'
    (program_type ~* 'CCTV')::int as grp18, --'TELECOMMUNICATIONS'
    (program_type ~* 'Office|Staff|Contractor|ORRR')::int as grp19, --'CITY GOVERNMENT OFFICES'
    (program_type ~* 'RESERVED - OPERATIONS|TA USE|lighting vendor|Unknown|Vacant')::int as grp20, --'MISCELLANEOUS USE'
    (program_type ~* 'Urban Family Center|Shelter')::int as grp21, --'NON-RESIDENTIAL HOUSING AND HOMELESS SERVICES'
    (program_type ~* 'Head Start')::int as grp22, --'HEAD START' -- facgroup should be DAY CARE AND PRE-KINDERGARTEN and facdomain should be EDUCATION, CHILD WELFARE, AND YOUTH
    (program_type ~* 'Child welfare|Family')::int as grp23 --'FAMILY SERVICES' -- facgroup should be CHILD SERVICES AND WELFARE and facdomain should be EDUCATION, CHILD WELFARE, AND YOUTH
    --(program_type ~* 'Youth|Vocation|Jobs|Literacy|Lab')::int as grp24--'YOUTH CENTERS, LITERACY PROGRAMS, AND JOB TRAINING SERVICES'
  FROM nycha_communitycenters
)
SELECT
    uid,
    source,
    development as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    address as address,
    NULL as city,
    NULL as zipcode,
    borough as boro,
    NULL as borocode,
    bin,
    bbl,
    (CASE
		  WHEN program_type = 'NORC' THEN 'NORC Services'
		  ELSE 'NYCHA Community Center - '|| initcap(program_type)
	  END) as factype,
    (CASE
      -- Classify multi-service facilities as community centers
      WHEN (grp1+grp2+grp3+grp4+grp5+grp6+grp7+grp8+grp9+
              grp10+grp11+grp12+grp13+grp14+grp15+grp16+grp17+
              grp18+grp19+grp20+grp21+grp22+grp23) > 1 THEN 'COMMUNITY CENTER'
      WHEN grp1 = 1 THEN 'LEGAL AND INTERVENTION SERVICES'
      WHEN grp2 = 1 THEN 'DOE UNIVERSAL PRE-KINDERGARTEN'
      WHEN grp3 = 1 THEN 'SENIOR SERVICES'
      WHEN grp4 = 1 THEN 'DAY CARE'
      WHEN grp5 = 1 THEN 'PROGRAMS FOR PEOPLE WITH DISABILITIES'
      WHEN grp6 = 1 THEN 'STORAGE'
      WHEN grp7 = 1 THEN 'WORKFORCE DEVELOPMENT'
      WHEN grp8 = 1 THEN 'GED AND ALTERNATIVE HIGH SCHOOL EQUIVALENCY'
      WHEN grp9 = 1 THEN 'PUBLIC K-12 SCHOOLS'
      WHEN grp10 = 1 THEN 'POLICE SERVICES'
      WHEN grp11 = 1 THEN 'SOUP KITCHENS AND FOOD PANTRIES'
      WHEN grp12 = 1 THEN 'MENTAL HEALTH'
      WHEN grp13 = 1 THEN 'HOSPITALS AND CLINICS'
      WHEN grp14 = 1 THEN 'CUSTODIAL'
      WHEN grp15 = 1 THEN 'ADULT AND IMMIGRANT LITERACY'
      WHEN grp16 = 1 THEN 'TRAINING AND TESTING'
      WHEN grp17 = 1 THEN 'PUBLIC LIBRARIES'
      WHEN grp18 = 1 THEN 'TELECOMMUNICATIONS'
      WHEN grp19 = 1 THEN 'CITY GOVERNMENT OFFICES'
      WHEN grp20 = 1 THEN 'MISCELLANEOUS USE'
      WHEN grp21 = 1 THEN 'NON-RESIDENTIAL HOUSING AND HOMELESS SERVICES'
      WHEN grp22 = 1 THEN 'HEAD START'
      WHEN grp23 = 1 THEN 'FAMILY SERVICES'
      ELSE 'COMMUNITY CENTER'
    END) as facsubgrp,
    'NYC Housing Authority' as opname,
    'NYCHA' as opabbrev,
    'NYCHA' as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    wkt::geometry as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _nycha_communitycenters
FROM subgroup_flags;

CALL append_to_facdb_base('_nycha_communitycenters');
