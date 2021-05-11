DROP TABLE IF EXISTS facdb_agency;
SELECT
	a.*, b.overagency, b.overlevel
INTO facdb_agency
FROM (
	SELECT
		uid,
		a.opname,
		a.opabbrev,
		b.optype,
		a.overabbrev
	FROM facdb_base a
	LEFT JOIN lookup_agency b
	ON a.opabbrev = b.opabbrev
) a LEFT JOIN lookup_agency b
ON a.overabbrev = b.overabbrev
