-- QC consistency in operator information
DROP TABLE IF EXISTS qc_operator;
WITH
new as (
	SELECT opabbrev, opname, optype, datasource, count(*) as count_new
	FROM facdb
	group by opabbrev, opname, optype, datasource
),
old as (
	SELECT opabbrev, opname, optype, datasource, count(*) as count_old
	FROM dcp_facilities
	group by opabbrev, opname, optype, datasource
)
select
	coalesce(a.opabbrev, b.opabbrev) as opabbrev,
	coalesce(a.opname, b.opname) as opname,
	coalesce(a.optype, b.optype) as optype,
	coalesce(a.datasource, b.datasource) as datasource,
	b.count_old,  a.count_new - b.count_old as diff
INTO qc_operator
from new a join old b
on a.opabbrev = b.opabbrev
and a.opname = b.opname
and a.optype = b.optype
and a.datasource = b.datasource;

-- QC consistency in oversight information
DROP TABLE IF EXISTS qc_oversight;
with
new as (
	SELECT overabbrev, overagency, overlevel, datasource, count(*) as count_new
	FROM facdb
	group by overabbrev, overagency, overlevel, datasource
),
old as (
	SELECT overabbrev, overagency, overlevel, datasource, count(*) as count_old
	FROM dcp_facilities
	group by overabbrev, overagency, overlevel, datasource
)
select
	coalesce(a.overabbrev, b.overabbrev) as overabbrev,
	coalesce(a.overagency, b.overagency) as overagency,
	coalesce(a.overlevel, b.overlevel) as optype,
	coalesce(a.datasource, b.datasource) as datasource,
	b.count_old,  a.count_new - b.count_old as diff
INTO qc_oversight
from new a
join old b
on a.overabbrev = b.overabbrev
and a.overagency = b.overagency
and a.overlevel = b.overlevel
and a.datasource = b.datasource;

-- QC consistency in grouping information
DROP TABLE IF EXISTS qc_classification;
with
new as (
	SELECT facdomain, facgroup, facsubgrp, servarea, count(*) as count_new
	FROM facdb
	group by facdomain, facgroup, facsubgrp, servarea
),
old as (
	SELECT facdomain, facgroup, facsubgrp, servarea, count(*) as count_old
	FROM dcp_facilities
	group by facdomain, facgroup, facsubgrp, servarea
)
select
	coalesce(a.facdomain, b.facdomain) as facdomain,
	coalesce(a.facgroup, b.facgroup) as facgroup,
	coalesce(a.facsubgrp, b.facsubgrp) as facsubgrp,
	coalesce(a.servarea, b.servarea) as servarea,
	b.count_old,  a.count_new - b.count_old as diff
INTO qc_classification
from new a
join old b
on a.facdomain = b.facdomain
and a.facgroup = b.facgroup
and a.facsubgrp = b.facsubgrp
and a.servarea = b.servarea;

-- make sure capcaity types are consistent
DROP TABLE IF EXISTS qc_captype;
with
new as (
	SELECT captype, sum(capacity::integer) as sum_new
	FROM facdb
	group by captype
),
old as (
	SELECT captype, sum(capacity::integer) as sum_old
	FROM dcp_facilities
	group by captype
)
select a.captype, a.sum_new, b.sum_old, a.sum_new - b.sum_old as diff
INTO qc_captype
from new a
join old b
on a.captype = b.captype;

-- make sure property types are consistent
DROP TABLE IF EXISTS qc_proptype;
with
new as (
	SELECT coalesce(proptype, 'NULL') as proptype, count(*) as count_new
	FROM facdb
	group by proptype
),
old as (
	SELECT coalesce(proptype, 'NULL') as proptype, count(*) as count_old
	FROM dcp_facilities
	group by proptype
)
select a.proptype, a.count_new, b.count_old,  a.count_new - b.count_old as diff
INTO qc_proptype
from new a
join old b
on a.proptype = b.proptype;

DROP TABLE IF EXISTS qc_mapped;
WITH
geom_new as (
	SELECT facdomain, facgroup, facsubgrp, factype, datasource,
	count(*) as count_new,
	sum((geom is null)::integer) as wogeom_new
	from facdb
	group by facdomain, facgroup, facsubgrp, factype, datasource
),
geom_old as (
	SELECT facdomain, facgroup, facsubgrp, factype, datasource,
	count(*) as count_old,
	sum((wkb_geometry is null)::integer) as wogeom_old
	from dcp_facilities
	group by facdomain, facgroup, facsubgrp, factype, datasource
)
select
	coalesce(a.facdomain, b.facdomain) as facdomain,
	coalesce(a.facgroup, b.facgroup) as facgroup,
	coalesce(a.facsubgrp, b.facsubgrp) as facsubgrp,
	coalesce(a.factype, b.factype) as factype,
	coalesce(a.datasource, b.datasource) as datasource,
	coalesce(b.count_old, 0) as count_old,
	coalesce(a.count_new, 0) as count_new,
	coalesce(a.wogeom_new, 0) as wogeom_new,
	coalesce(b.wogeom_old, 0) as wogeom_old
INTO qc_mapped
from geom_new a
FULL join geom_old b
on a.facdomain = b.facdomain
AND a.facgroup = b.facgroup
AND a.facsubgrp = b.facsubgrp
AND a.factype = b.factype
AND a.datasource = b.datasource;

-- report Change in distribution of number of records by fac subgroup / group / domain between current and previous version
DROP TABLE IF EXISTS qc_diff;
select
	coalesce(a.facdomain, b.facdomain) as facdomain,
	coalesce(a.facgroup, b.facgroup) as facgroup,
	coalesce(a.facsubgrp, b.facsubgrp) as facsubgrp,
	coalesce(a.factype, b.factype) as factype,
	coalesce(a.datasource, b.datasource) as datasource,
	coalesce(count_old, 0) as count_old,
	coalesce(count_new, 0) as count_new,
	coalesce(count_new, 0) - coalesce(count_old, 0) as diff
INTO qc_diff
FROM
(
	select facdomain, facgroup, facsubgrp, factype, datasource, coalesce(count(*),0) as count_new
	from facdb
	where geom is not null
	group by facdomain, facgroup, facsubgrp, factype, datasource
) a FULL JOIN
(	select facdomain, facgroup, facsubgrp, factype, datasource, coalesce(count(*),0) as count_old
	from dcp_facilities
	where wkb_geometry is not null
	group by facdomain, facgroup, facsubgrp, factype, datasource
) b
ON a.facdomain = b.facdomain
and a.facgroup = b.facgroup
and a.facsubgrp = b.facsubgrp
and a.factype = b.factype
and a.datasource = b.datasource
order by facdomain, facgroup, facsubgrp, factype;
