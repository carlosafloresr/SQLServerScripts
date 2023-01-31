/*
-- PART CODES
SELECT	DISTINCT BIN, part_no, descript
into	#tmpsale
FROM	Sale
WHERE	[DATE] BETWEEN '1/1/2011' AND '3/19/2012'
		AND part_no <> ''
		AND Depot_Loc = 'MEMPHIS'

SELECT	DISTINCT A.BIN, A.part_no, B.descript
FROM	#tmpsale A
		INNER JOIN (SELECT BIN, part_no, MAX(descript) AS descript FROM #tmpsale GROUP BY BIN, part_no) B ON A.BIN = B.BIN AND  A.part_no = B.PART_NO
WHERE	RTRIM(A.PART_NO) NOT IN (SELECT RTRIM(JOBCODE) FROM JobCodes)
		AND A.Bin <> ''
ORDER BY A.BIN, A.part_no
*/

/*
-- DAMAGE CODES
SELECT	DISTINCT cdex_damag, cdex_compo, bin
into	#tmpDamage
FROM	Sale
WHERE	[DATE] BETWEEN '1/1/2011' AND '3/19/2012'
		AND cdex_damag <> ''
		AND Depot_Loc = 'MEMPHIS'

SELECT	DISTINCT BIN, cdex_compo, cdex_damag
FROM	#tmpDamage A
		--INNER JOIN (SELECT BIN, part_no, MAX(descript) AS descript FROM #tmpsale GROUP BY BIN, part_no) B ON A.BIN = B.BIN AND  A.part_no = B.PART_NO
WHERE	RTRIM(A.cdex_damag) NOT IN (SELECT DamageCode FROM DamageCodes)
ORDER BY A.bin, A.cdex_compo, A.cdex_damag

DROP TABLE #tmpDamage
/*


/*
-- REPAIR CODES
SELECT	DISTINCT cdex_repai, cdex_compo, bin
into	#tmpRepair
FROM	Sale
WHERE	[DATE] BETWEEN '1/1/2011' AND '3/19/2012'
		AND cdex_repai <> ''
		AND Depot_Loc = 'MEMPHIS'

SELECT	DISTINCT rtrim(BIN) as bin, cdex_compo, cdex_repai
FROM	#tmpRepair A
		--INNER JOIN (SELECT BIN, part_no, MAX(descript) AS descript FROM #tmpsale GROUP BY BIN, part_no) B ON A.BIN = B.BIN AND  A.part_no = B.PART_NO
WHERE	RTRIM(A.cdex_repai) NOT IN (SELECT RepairCode FROM RepairCodes)
ORDER BY rtrim(A.bin), A.cdex_compo, A.cdex_repai

DROP TABLE #tmpRepair
/*

-- SELECT TOP 1000 * FROM Sale