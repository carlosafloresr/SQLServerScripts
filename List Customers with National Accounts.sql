SELECT	'AIS' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	AIS..RM00101 RM1
		INNER JOIN AIS..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'DNJ' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	DNJ..RM00101 RM1
		INNER JOIN DNJ..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'FI' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	FI..RM00101 RM1
		INNER JOIN FI..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'GIS' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	GIS..RM00101 RM1
		INNER JOIN GIS..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'IMC' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	IMC..RM00101 RM1
		INNER JOIN IMC..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'NDS' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	NDS..RM00101 RM1
		INNER JOIN NDS..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'RCCL' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	RCCL..RM00101 RM1
		INNER JOIN RCCL..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
UNION
SELECT	'RCMR' AS Company,
		RM2.CustNmbr AS ParentId,
		RM2.CustName AS ParentName,
		RM1.CustNmbr AS ChildId,
		RM1.CustName AS ChildName
FROM	RCMR..RM00101 RM1
		INNER JOIN RCMR..RM00101 RM2 ON RM1.Cprcstnm = RM2.CustNmbr
WHERE	RM1.Cprcstnm <> ''
ORDER BY 1, RM2.CustNmbr