SET NOCOUNT ON

DECLARE @Query		Varchar(MAX),
		@ProNumber	Varchar(15),
		@ProNumbers	Varchar(MAX) = ''

DECLARE	@tblMatched Table (Record1 Int, Record2 Int)
DECLARE	@tblSWSData Table (Pro Varchar(15), SWSStatus Char(1), Manif_Date Date)

--INSERT INTO @tblMatched
--SELECT	TOP 100000 CXB1.RecordId AS Record1,
--		CXB2.RecordId AS Record2
--FROM	GP_XCB_Prepaid CXB1
--		INNER JOIN GP_XCB_Prepaid CXB2 ON CXB1.ProNumber = CXB2.ProNumber AND CXB1.JournalNo <> CXB2.JournalNo AND ABS(CXB1.Amount) = ABS(CXB2.Amount)
--WHERE	CXB1.Matched = 0
--ORDER BY CXB1.RecordId

--UPDATE	GP_XCB_Prepaid
--SET		Matched = 1
--WHERE	RecordId IN (SELECT Record1 FROM @tblMatched)
--		OR RecordId IN (SELECT Record2 FROM @tblMatched)

DECLARE curFindMatch CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	TOP 625 ProNumber 
FROM	GP_XCB_Prepaid
WHERE	SWSManifestDate IS Null

OPEN curFindMatch 
FETCH FROM curFindMatch INTO @ProNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @ProNumbers = @ProNumbers + IIF(@ProNumbers = '', '', ',') + '|' + @ProNumber + '|'

	FETCH FROM curFindMatch INTO @ProNumber
END

CLOSE curFindMatch
DEALLOCATE curFindMatch

SET @Query = N'SELECT CAST(div_code||''-''||pro AS STRING) AS pronumber, Status AS OrderStatus, invdt 
FROM	TRK.Order 
WHERE	cmpy_no = 9 
		AND CAST(div_code||''-''||pro AS STRING) IN (' + REPLACE(@ProNumbers, '|', '''') + ')'

INSERT INTO @tblSWSData
EXECUTE USP_QuerySWS_ReportData @Query

UPDATE	GP_XCB_Prepaid
SET		GP_XCB_Prepaid.SWSManifestDate	= DATA.Manif_Date,
		GP_XCB_Prepaid.SWSStatus		= DATA.SWSStatus
FROM	(
		SELECT	Pro,
				CASE SWSStatus
				WHEN 'C' THEN 'Complete'
				WHEN 'R' THEN 'Ready'
				WHEN 'D' THEN 'Dispatch'
				WHEN 'O' THEN 'Dropped'
				WHEN 'X' THEN 'Deferred'
				WHEN 'A' THEN 'Assigned'
				WHEN 'P' THEN 'Partial'
				WHEN 'V' THEN 'Void'
				END AS SWSStatus,
				Manif_Date
		FROM	@tblSWSData
		) DATA
WHERE	GP_XCB_Prepaid.ProNumber = DATA.Pro

/*
SELECT	top 10 * --COUNT(*) AS Total
FROM	GP_XCB_Prepaid
WHERE	Matched = 0

SELECT	TOP 10000 CXB1.*,
		CXB2.*
FROM	GP_XCB_Prepaid CXB1
		LEFT JOIN GP_XCB_Prepaid CXB2 ON CXB1.ProNumber = CXB2.ProNumber AND CXB1.JournalNo <> CXB2.JournalNo AND ABS(CXB1.Amount) = ABS(CXB2.Amount)
WHERE	CXB2.ProNumber IS NOT Null

SELECT	JRNENTRY, OPENYEAR, PERIODID, REFRENCE, CRDTAMNT * -1 AS CRDTAMNT, DEBITAMT, GPCustom.dbo.FindProNumber(REFRENCE) AS PRONUMBER
FROM	GLSO..GL20000
WHERE	(REFRENCE LIKE '%95-291840%'
		OR REFRENCE LIKE '%95291840%')
		AND ACTINDX = 650
		--AND CRDTAMNT + DEBITAMT = 430
ORDER BY REFRENCE

*/