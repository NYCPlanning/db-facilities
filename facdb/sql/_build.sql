DROP TABLE IF EXISTS facdb;
WITH
boro_join AS(

),
address_join AS(

),
geom_join AS(

),
spatial_join AS(

),
classification_join AS(

)
SELECT *
INTO facdb
FROM classification_join;

CALL apply_correction(facdb, manual_corrections);
