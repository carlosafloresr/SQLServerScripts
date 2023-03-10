SELECT	DISTINCT RM1.CUSTNMBR
		,RM2.CUSTNAME
FROM	RM20101 RM1
		INNER JOIN RM00101 RM2 ON RM1.CUSTNMBR = RM2.CUSTNMBR
WHERE	CURTRXAM <> 0
		OR DOCDATE > GETDATE() - 365
UNION
SELECT	DISTINCT RM1.CUSTNMBR
		,RM2.CUSTNAME
FROM	RM30101 RM1
		INNER JOIN RM00101 RM2 ON RM1.CUSTNMBR = RM2.CUSTNMBR
WHERE	CURTRXAM <> 0
		OR DOCDATE > GETDATE() - 365
ORDER BY RM2.CUSTNAME