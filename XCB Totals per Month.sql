DECLARE @AccStr		Varchar(15) = '0-88-1866',
		@Account	Int		

DECLARE @tblPeriods Table (Period Char(7), Debit Numeric(12,2), Credit Numeric(12,2), Balance Numeric(10, 2))

SET @Account = (SELECT ACTINDX FROM GLSO.dbo.GL00105 WHERE ACTNUMST = @AccStr)

INSERT INTO @tblPeriods
SELECT	CAST(YEAR1 AS Varchar) + '-' + dbo.PADL(PERIODID, 2, '0') AS Period, 
		DEBITAMT,
		CRDTAMNT,
		PERDBLNC
FROM	GLSO.dbo.GL10111
WHERE	ACTINDX = @Account	
		AND PERIODID > 0
UNION
SELECT	CAST(YEAR1 AS Varchar) + '-' + dbo.PADL(PERIODID, 2, '0') AS Period, 
		DEBITAMT,
		CRDTAMNT,
		PERDBLNC
FROM	GLSO.dbo.GL10110
WHERE	ACTINDX = @Account
		AND PERIODID > 0

SELECT	RIGHT(XCB.FiscalPeriod, 4) + '-' + LEFT(XCB.FiscalPeriod, 2) AS FiscalPeriod, 
		PER.Debit AS GP_Debit,
		PER.Credit AS GP_Credit,
		PER.Balance AS GP_Balance,
		SUM(XCB.Amount) AS XCB_Balance,
		AccountBalance = FORMAT((SELECT SUM(TMP.Balance) FROM @tblPeriods TMP WHERE TMP.Period <= PER.Period), 'C', 'en-us'),
		PER.Balance - SUM(XCB.Amount) AS Difference,
		CONVERT(Char(10), FIP.StartDate, 101) AS StartDate,
		CONVERT(Char(10), FIP.EndDate, 101) AS EndDate
FROM	GP_XCB_Prepaid XCB
		LEFT JOIN @tblPeriods PER ON RIGHT(XCB.FiscalPeriod, 4) + '-' + LEFT(XCB.FiscalPeriod, 2) = PER.Period
		LEFT JOIN DYNAMICS.dbo.View_Fiscalperiod FIP ON XCB.FiscalPeriod = FIP.GP_PERIOD
WHERE	XCB.GLAccount = @AccStr
		-- FP_StartDate < '10/30/2022' 
GROUP BY RIGHT(XCB.FiscalPeriod, 4) + '-' + LEFT(XCB.FiscalPeriod, 2), 
		PER.Period, 
		PER.Debit, 
		PER.Credit, 
		PER.Balance,
		CONVERT(Char(10), FIP.StartDate, 101),
		CONVERT(Char(10), FIP.EndDate, 101)
ORDER BY PER.Period DESC

--'TOTAL NOVEMBER': $ -8,641,394.98
/*
SELECT	count(*) AS Counter, SUM(Amount) AS Amount
FROM	GP_XCB_Prepaid
WHERE	FP_StartDate < '12/04/2022'
		AND GLAccount = '0-88-1866'
		and Matched = 0

SELECT	count(*) AS Counter, SUM(Amount) AS Amount
FROM	GP_XCB_Prepaid
WHERE	FP_StartDate < '10/30/2022'
		and Matched = 1

SELECT	count(*) AS Counter, SUM(Amount) AS Amount
FROM	GP_XCB_Prepaid
WHERE	FP_StartDate = '10/30/2022'

PRINT 32212968.56 + 32645653.37 + -8641394.98

*/