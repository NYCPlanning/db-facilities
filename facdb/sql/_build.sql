DROP TABLE IF EXISTS facdb;
WITH
spatial_join AS(
    SELECT
        a.uid,
        a.facname,
        a.source as datasource,
        a.opname,
        a.opabbrev,
        a.optype,
        a.overagency,
        a.overabbrev,
        a.overlevel,
        a.capacity,
        a.captype,
        a.proptype,
        b.bin,
        b.bbl,
        b.commboard,
        b.nta,
        b.council,
        b.censtract,
        b.precinct,
        b.schooldist
    FROM facdb_base a
    JOIN facdb_spatial b
    ON a.uid = b.uid
),
boro_join AS(
    SELECT
        a.*,
        b.boro,
        b.borocode,
        b.city,
        b.zipcode
    FROM spatial_join a
    JOIN facdb_boro b
    ON a.uid = b.uid
),
geom_join AS(
    SELECT
        a.*,
        geom,
        longitude,
        latitude,
        x as xcoord,
        y as ycoord
    FROM boro_join a
    JOIN facdb_geom b
    ON a.uid = b.uid
),
address_join AS(
    SELECT
        a.*,
        b.addressnum,
        b.streetname,
        b.address
    FROM geom_join a
    JOIN facdb_address b
    ON a.uid = b.uid
),
classification_join AS(
    SELECT
        a.*,
        b.facsubgrp,
        b.facgroup,
        b.facdomain,
        b.servearea
    FROM address_join a
    JOIN facdb_classification b
    ON a.uid = b.uid
)
SELECT
    facname,
    addressnum,
    streetname,
    address,
    city,
    zipcode,
    boro,
    borocode,
    bin,
    bbl,
    commboard,
    nta,
    council,
    schooldist,
    policeprct,
    censtract,
    factype,
    facsubgrp,
    facgroup,
    facdomain,
    servarea,
    opname,
    opabbrev,
    optype,
    overagency,
    overabbrev,
    overlevel,
    capacity,
    captype,
    proptype,
    latitude,
    longitude,
    xcoord,
    ycoord,
    datasource,
    uid,
    geom
INTO facdb
FROM classification_join;

CALL apply_correction(facdb, manual_corrections);
