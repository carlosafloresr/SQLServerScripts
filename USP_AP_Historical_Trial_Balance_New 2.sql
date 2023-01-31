DECLARE @asof		Date = '09/03/2022',
		@Summary	Bit = 1

SET NOCOUNT ON

DECLARE @tblTrialData	Table (
		VENDORID		Varchar(15),
		VENDNAME		Varchar(100),
		VNDCLASS		Varchar(15),
		VCHRNMBR		Varchar(20),
		DOCDATE			Date, 
		DOCTYPE			Varchar(20),
		DOCAMNT			Numeric(12,2),
		DOCNUMBR		Varchar(30),
		Applied			Numeric(12,2),
		[0_to_30_Days]	Numeric(12,2),
		[31_to_60_Days]	Numeric(12,2),
		[61_to_90_Days]	Numeric(12,2),
		[91_to_180_Days]Numeric(12,2),
		[181_and_Over]	Numeric(12,2))

INSERT INTO @tblTrialData
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 1 THEN 'Invoice' 
			WHEN 2 THEN 'Finance Charge' 
			WHEN 3 THEN 'Misc Charge' 
			END AS docType, 
        pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        CASE WHEN pstgdate BETWEEN DATEADD(d, -30, @asof) AND @asof THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [0_to_30_Days], 
        CASE WHEN pstgdate BETWEEN DATEADD(d, -60, @asof) AND DATEADD(d, -31, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [31_to_60_Days], 
        CASE WHEN pstgdate BETWEEN DATEADD(d, -90, @asof) AND DATEADD(d, -61, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [61_to_90_Days], 
		CASE WHEN pstgdate BETWEEN DATEADD(d, -180, @asof) AND DATEADD(d, -91, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [91_to_180_Days], 
        CASE WHEN pstgdate < DATEADD(d, -181, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [181_and_Over]
FROM	PM20000 pmTrans 
        LEFT JOIN PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT	aptvchnm, aptodcty, SUM(appldamt) AS appldamt 
					FROM	PM20100 
					WHERE  docdate <= @asOf 
					GROUP BY aptvchnm, aptodcty
				   ) apply ON pmTrans.vchrnmbr = apply.aptvchnm AND pmTrans.doctype = apply.aptodcty 
WHERE	pstgdate <= @asof 
		AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) <> 0 
		AND pmTrans.doctype <= 3 
		AND voided = 0 
UNION 
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 4 THEN 'Return' 
			WHEN 5 THEN 'Credit' 
			WHEN 6 THEN 'Payment' 
			ELSE CONVERT(VARCHAR(2), pmTrans.doctype) 
			END AS docType, 
        -pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        -pmTrans.docamnt + ISNULL(apply.appldamt, 0) AS [0_to_30_Days], 
        0 AS [31_to_60_Days], 
        0 AS [61_to_90_Days], 
        0 AS [91_to_180_Days], 
		0 AS [181_and_Over]
FROM	PM20000 pmTrans 
        LEFT JOIN PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT vchrnmbr, doctype, SUM(appldamt) AS appldamt 
					FROM   PM20100 
					WHERE  docdate <= @asOf 
					GROUP BY vchrnmbr, doctype
					) apply ON pmTrans.vchrnmbr = apply.vchrnmbr AND pmTrans.doctype = apply.doctype 
WHERE  pstgdate <= @asof 
        AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) <> 0 
        AND pmTrans.doctype >= 4 
        AND voided = 0 
UNION 
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 1 THEN 'Invoice' 
			WHEN 2 THEN 'Finance Charge' 
			WHEN 3 THEN 'Misc Charge' 
			END AS docType, 
        pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        CASE WHEN pstgdate BETWEEN DATEADD(d, -30, @asof) AND @asof THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [0_to_30_Days], 
        CASE WHEN pstgdate BETWEEN DATEADD(d, -60, @asof) AND DATEADD(d, -31, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [31_to_60_Days], 
        CASE WHEN pstgdate BETWEEN DATEADD(d, -90, @asof) AND DATEADD(d, -61, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [61_to_90_Days], 
		CASE WHEN pstgdate BETWEEN DATEADD(d, -180, @asof) AND DATEADD(d, -91, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [91_to_180_Days], 
        CASE WHEN pstgdate < DATEADD(d, -181, @asof) THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [181_and_Over]
FROM	PM30200 pmTrans 
        LEFT JOIN PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT aptvchnm, aptodcty, SUM(appldamt) AS appldamt 
					FROM   PM30300 
					WHERE  glpostdt <= @asOf 
					GROUP BY aptvchnm, aptodcty
					) apply ON apply.aptvchnm = pmTrans.vchrnmbr AND pmTrans.doctype = apply.aptodcty 
WHERE	pstgdate <= @asof 
        AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) <> 0 
        AND pmTrans.doctype <= 3 
        AND voided = 0 
UNION 
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 4 THEN 'Return' 
			WHEN 5 THEN 'Credit' 
			WHEN 6 THEN 'Payment' 
			ELSE CONVERT(VARCHAR(2), pmTrans.doctype) 
			END AS docType, 
        -pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        -pmTrans.docamnt + ISNULL(apply.appldamt, 0) AS [0_to_30_Days], 
        0 AS [31_to_60_Days], 
        0 AS [61_to_90_Days], 
        0 AS [91_to_180_Days], 
		0 AS [181_and_Over]
FROM   PM30200 pmTrans 
        LEFT JOIN PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT vchrnmbr, doctype, SUM(appldamt) AS appldamt 
					FROM   PM30300 
					WHERE  glpostdt <= @asOf 
					GROUP BY vchrnmbr, doctype
					) apply ON pmTrans.vchrnmbr = apply.vchrnmbr AND pmTrans.doctype = apply.doctype 
WHERE  pstgdate <= @asof 
        AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) <> 0 
        AND pmTrans.doctype >= 4 
        AND voided = 0 

IF @Summary = 0
	SELECT	VENDORID,
			VENDNAME,
			VNDCLASS,
			VCHRNMBR,
			DOCDATE, 
			DOCTYPE,
			DOCNUMBR,
			DOCAMNT,
			Applied,
			[0_to_30_Days],
			[31_to_60_Days],
			[61_to_90_Days],
			[91_to_180_Days],
			[181_and_Over],
			[0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_to_180_Days] + [181_and_Over] AS Balance
	FROM	@tblTrialData
	ORDER BY VENDNAME, DOCDATE, DOCNUMBR
ELSE
	SELECT	VENDORID,
			VENDNAME,
			VNDCLASS,
			'' AS VCHRNMBR,
			MAX(DOCDATE) AS DOCDATE, 
			'' AS DOCTYPE,
			'' AS DOCNUMBR,
			SUM(DOCAMNT) AS DOCAMNT,
			SUM(Applied) AS Applied,
			SUM([0_to_30_Days]) AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([181_and_Over]) AS [181_and_Over],
			SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_to_180_Days] + [181_and_Over]) AS Balance
	FROM	@tblTrialData
	GROUP BY VENDORID, VENDNAME, VNDCLASS
	UNION
	SELECT	'ZZZZZZZZ' AS VENDORID,
			'ZZZZZZZZ' AS VENDNAME,
			'ZZZZZZZZ' AS VNDCLASS,
			'' AS VCHRNMBR,
			Null AS DOCDATE, 
			'' AS DOCTYPE,
			'' AS DOCNUMBR,
			SUM(DOCAMNT) AS DOCAMNT,
			SUM(Applied) AS Applied,
			SUM([0_to_30_Days]) AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([181_and_Over]) AS [181_and_Over],
			SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_to_180_Days] + [181_and_Over]) AS Balance
	FROM	@tblTrialData
	ORDER BY VENDNAME