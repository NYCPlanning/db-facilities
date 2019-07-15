CREATE OR REPLACE PROCEDURE load_to_facilities(tbl text)
LANGUAGE plpgsql
AS $$
BEGIN
    execute format('INSERT INTO 
    				facilities(
    					uid, 
						facname, 
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
						datasource,
						addressnum,
						streetname, 
						address, 
						city, 
						zipcode, 
						boro,
						borocode,
						schooldist,
						policeprct,
						bin,
						bbl, 
						latitude,
						longitude, 
						xcoord, 
						ycoord, 
						commboard, 
						nta, 
						council, 
						censtract, 
						geom)

    				SELECT hash, 
						facname, 
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
						datasource,
						geo_house_number,
						geo_street_name,
						address,
					    geo_city,
					    geo_zip_code,
						NULL,
						geo_borough_code,
						geo_policeprct,
						geo_schooldist,
					    geo_bin,
					    geo_bbl,
					    geo_latitude,
					    geo_longitude,
						NULL,
						NULL,
					    geo_commboard,
					    geo_nta,
					    geo_council,
					    geo_censtract,
					    wkb_geometry
						FROM %I
						WHERE geo_grc <> 71::text or geo_grc2 <> 71::text; ', tbl);
	EXCEPTION WHEN others THEN
		execute format('INSERT INTO 
    				facilities(
    					uid, 
						facname, 
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
						datasource,
						addressnum,
						streetname, 
						address, 
						city, 
						zipcode, 
						boro,
						borocode,
						schooldist,
						policeprct,
						bin,
						bbl, 
						latitude,
						longitude, 
						xcoord, 
						ycoord, 
						commboard, 
						nta, 
						council, 
						censtract, 
						geom)
						
    				SELECT hash, 
						facname, 
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
						datasource,
						NULL,
						NULL,
						address,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						wkb_geometry
						FROM %I;', tbl);
    RAISE NOTICE '% loaded, geo_ attributes are NULL', tbl;
END;
$$;