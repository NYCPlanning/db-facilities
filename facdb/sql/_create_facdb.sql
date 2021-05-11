DROP TABLE IF EXISTS facdb;
SELECT
    facdb_base.facname,
    facdb_address.addressnum,
    facdb_address.streetname,
    facdb_address.address,
    facdb_boro.city,
    facdb_boro.zipcode,
    facdb_boro.boro,
    facdb_boro.borocode,
    facdb_spatial.bin,
    facdb_spatial.bbl,
    facdb_spatial.commboard,
    facdb_spatial.nta,
    facdb_spatial.council,
    facdb_spatial.schooldist,
    facdb_spatial.precinct,
    facdb_spatial.censtract,
    facdb_base.factype,
    facdb_classification.facsubgrp,
    facdb_classification.facgroup,
    facdb_classification.facdomain,
    facdb_classification.servarea,
    facdb_base.opname,
    facdb_agency.opabbrev,
    facdb_agency.optype,
    facdb_agency.overagency,
    facdb_agency.overabbrev,
    facdb_agency.overlevel,
    facdb_base.capacity,
    facdb_base.captype,
    facdb_base.proptype,
    facdb_geom.latitude,
    facdb_geom.longitude,
    facdb_geom.x as xcoord,
    facdb_geom.y as ycoord,
    facdb_base.source as datasource,
    facdb_base.uid,
    facdb_geom.geom,
INTO facdb
FROM facdb_base
LEFT JOIN facdb_spatial 	ON facdb_base.uid = facdb_spatial.uid
LEFT JOIN facdb_boro 		ON facdb_base.uid = facdb_boro.uid
LEFT JOIN facdb_address 	on facdb_base.uid = facdb_address.uid
LEFT JOIN facdb_classification 	on facdb_base.uid = facdb_classification.uid
LEFT JOIN facdb_agency 		ON facdb_base.uid = facdb_agency.uid
LEFT JOIN facdb_geom 		ON facdb_base.uid = facdb_geom.uid;

CALL apply_correction(facdb, manual_corrections);
