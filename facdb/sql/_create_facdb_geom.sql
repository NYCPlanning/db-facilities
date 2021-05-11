DROP TABLE IF EXISTS facdb_geom;
SELECT uid,
    geom,
    geomsource,
    ST_astext(Geom),
    ST_X(geom) as longitude,
    ST_Y(geom) as latitude,
    ST_X(ST_Transform(geom, 2263)) as x,
    ST_Y(ST_Transform(geom, 2263)) as y INTO facdb_geom
FROM (
        SELECT uid,
            ST_SetSRID(
                coalesce(
                    geom_bldg,
                    geom_pluto,
                    geom_bn,
                    geom_bl,
                    geom_1b,
                    wkb_geometry
                ),
                4326
            ) as geom,
            coalesce(
                source_bldg,
                source_pluto,
                source_bn,
                source_bl,
                source_1b,
                source_wkb
            ) as geomsource
        FROM (
                SELECT a.*,
                    st_centroid(b.wkb_geometry) as geom_bldg,
                    (
                        case
                            when a.wkb_geometry is not null then 'wkb_geometry'
                        end
                    ) as source_wkb,
                    (
                        case
                            when geom_1b is not null then '1b'
                        end
                    ) as source_1b,
                    (
                        case
                            when geom_bl is not null then 'bl'
                        end
                    ) as source_bl,
                    (
                        case
                            when geom_bn is not null then 'bn'
                        end
                    ) as source_bn,
                    (
                        case
                            when geom_pluto is not null then 'pluto bbl centroid'
                        end
                    ) as source_pluto,
                    (
                        case
                            when b.wkb_geometry is not null then 'building centroid'
                        end
                    ) as source_bldg
                FROM (
                        SELECT a.*,
                            st_centroid(b.wkb_geometry) as geom_pluto
                        FROM (
                                SELECT uid,
                                    st_centroid(wkb_geometry) as wkb_geometry,
                                    geo_1b->'result'->>'geo_bbl' as geo_bbl,
                                    (
                                        CASE
                                            WHEN geo_1b->'result'->>'geo_bin' IN (
                                                '5000000',
                                                '4000000',
                                                '3000000',
                                                '2000000',
                                                '1000000'
                                            ) THEN NULL
                                            ELSE geo_1b->'result'->>'geo_bin'
                                        END
                                    ) as geo_bin,
                                    st_point(
                                        nullif(geo_1b->'result'->>'geo_longitude', '')::double precision,
                                        nullif(geo_1b->'result'->>'geo_latitude', '')::double precision
                                    ) as geom_1b,
                                    st_point(
                                        nullif(geo_bl->'result'->>'geo_longitude', '')::double precision,
                                        nullif(geo_bl->'result'->>'geo_latitude', '')::double precision
                                    ) as geom_bl,
                                    st_point(
                                        nullif(geo_bn->'result'->>'geo_longitude', '')::double precision,
                                        nullif(geo_bn->'result'->>'geo_latitude', '')::double precision
                                    ) as geom_bn
                                from facdb_base
                            ) a
                            LEFT JOIN dcp_mappluto b ON b.bbl::bigint::text = a.geo_bbl
                    ) a
                    LEFT JOIN doitt_buildingfootprints b ON b.bin::bigint::text = a.geo_bin
            ) a
    ) a
