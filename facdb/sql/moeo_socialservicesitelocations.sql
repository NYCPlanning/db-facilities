DROP TABLE IF EXISTS _moeo_socialservicesitelocations;

WITH tmp AS(
    SELECT MIN(uid) AS uid
    FROM moeo_socialservicesitelocations
    GROUP BY program_name||provider_name, address_1
)
SELECT
    uid,
    source,
    CONCAT(provider_name, ' ' ,program_name) as facname,
    parsed_hnum as addressnum,
    parsed_sname as streetname,
    address_1 as address,
    city,
    postcode as zipcode,
    borough as boro,
    LEFT(bin::text, 1) as borocode,
    bin,
    bbl,
    (CASE
        WHEN program_name = 'NORC SITES' THEN 'NORC Services'
        WHEN program_name = 'TRANSPORTATION ONLY' THEN 'Transportation'
        ELSE initcap(program_name)
    END) as factype,
    (CASE
        WHEN program_name IN
            ('PEAK Centers',
            'Teen Rapp',
            'Youth Recreational Services/Youth Athletic Leagues')
            THEN 'After-School Programs'
        WHEN program_name IN
            ('Community Based Programs')
            THEN 'Community Centers and Community School Programs'
        WHEN program_name IN
            ('Social Welfare')
            THEN 'Financial Assistance and Social Services'
        WHEN program_name IN
            ('COVID19 Programs',
            'Customized Assistance Services (CAS)',
            'Intake Medical Services')
            THEN 'Health Promotion and Disease Prevention'
        WHEN program_name IN
            ('AIM',
            'Alternative To Detention',
            'Alternative To Incarceration',
            'Anti-gun Violence Initiative',
            'Appellate Indigent Criminal Defense',
            'Arches',
            'Article 10 Petition Parental Representation',
            'Assigned Domestic Violence Counsel',
            'Child Advocacy Center',
            'Court Advocacy Services',
            'Court Based Programs',
            'Crime Victims Services',
            'Discharge and Reentry Services',
            'Emergency Intervention Services (Domestic Violence Shelters)',
            'Family Justice Center',
            'Hate Crimes Prevention',
            'ICM Plus',
            'Legal Services',
            'Mediation Services',
            'Next STEPS',
            'Parent Support Program',
            'Trial-Level Indigent Defense Representation',
            'Victim Services, Domestic Violence',
            'Victim Services, Other',
            'Young Adult Justice Program')
            THEN 'Legal and Intervention Services'
        WHEN program_name IN
            ('Adolescent IMPACT',
            'Mental Health Services, Vocational',
            'Mobile Adolescent Therapy')
            THEN 'Mental Health'
        WHEN program_name IN
            ('Adult Outreach Service',
            'Drop-In Centers',
            'Homebase Homelessness Prevention',
            'Rapid Re-Housing',
            'Shelter Intake',
            'Shelter/Shelter Services')
            THEN 'Non-residential Housing and Homeless Services'
        WHEN program_name IN
            ('Home Care/Attendant/Maker and Housekeeping Services')
            THEN 'Other Health Care'
        WHEN program_name IN
            ('Food Pantry/Meal Services')
            THEN 'Soup Kitchens and Food Pantries'
        WHEN program_name IN
            ('CareerAdvance',
            'CareerCompass',
            'ECHOES',
            'Employment Focused Services',
            'Job Services',
            'Jobs Plus',
            'Justice Plus',
            'Neighborhood Employment Services',
            'NeON',
            'NeON Arts',
            'NYC Business Solutions',
            'Placement Services',
            'WeCARE',
            'Workforce 1 Career Centers',
            'Works Plus',
            'YouthPathways')
            THEN 'Workforce Development'
        WHEN program_name IN
            ('Adult Protective Services')
            THEN 'Programs for People with Disabilities'
    END) as facsubgrp,
    provider_name as opname,
    NULL as opabbrev,
    'NYC'||agency_name as overabbrev,
    NULL as capacity,
    NULL as captype,
    NULL as proptype,
    NULL as wkb_geometry,
    geo_1b,
    geo_bl,
    geo_bn
INTO _moeo_socialservicesitelocations
FROM moeo_socialservicesitelocations
WHERE uid IN (SELECT uid FROM tmp)
AND program_name !~* 'Home Delivered Meals|senior center|CONDOM DISTRIBUTION SERVICES|GROWING UP NYC INITIATIVE SUPPORT SERVICES|PLANNING AND EVALUATION [BASE]|TO BE DETERMINED - UNKNOWN';

CALL append_to_facdb_base('_moeo_socialservicesitelocations');
