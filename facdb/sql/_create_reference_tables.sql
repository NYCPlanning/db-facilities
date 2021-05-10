DROP TABLE IF EXISTS lookup_boro;
CREATE TABLE lookup_boro (
    boro TEXT,
    boroname TEXT,
    borocode INTEGER
);
\COPY lookup_boro FROM 'facdb/data/lookup_boro.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS lookup_classification;
CREATE TABLE lookup_classification (
    facsubgrp TEXT,
    facgroup TEXT,
    facdomain TEXT,
    servarea TEXT
);
\COPY lookup_classification FROM 'facdb/data/lookup_classification.csv' DELIMITER ',' CSV HEADER;
