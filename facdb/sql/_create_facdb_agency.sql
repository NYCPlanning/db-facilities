DROP TABLE IF EXISTS facdb_agency;
WITH
op_join AS (
	SELECT
		a.uid,
		a.opname,
		a.opabbrev,
		b.optype,
		b.overabbrev,
		b.overagency,
		b.overlevel
	FROM facdb_base a
	LEFT JOIN lookup_agency b
	ON a.opabbrev = b.opabbrev
),
over_join AS (
	SELECT
		a.uid,
		a.overabbrev,
		b.overagency,
		b.overlevel
	FROM facdb_base a
	LEFT JOIN lookup_agency b
	ON a.overabbrev = b.overabbrev
)
SELECT
	a.uid,
	a.opname,
	a.opabbrev,
	a.optype,
	COALESCE(a.overabbrev, b.overabbrev) as overabbrev,
	COALESCE(a.overagency, b.overagency) as overagency,
	COALESCE(a.overlevel, b.overlevel) as overlevel
INTO facdb_agency
FROM op_join a
JOIN over_join b
ON a.uid = b.uid;
