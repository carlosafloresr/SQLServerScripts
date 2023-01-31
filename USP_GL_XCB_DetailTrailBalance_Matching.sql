/* 
EXECUTE USP_GL_XCB_DetailTrailBalance_Matching 'GLSO', '0-88-1866'
EXECUTE USP_GL_XCB_DetailTrailBalance_Matching 'GLSO', '0-88-1866', 1
 
EXECUTE USP_GL_XCB_DetailTrailBalance_Matching 'GLSO', '0-00-2105'
EXECUTE USP_GL_XCB_DetailTrailBalance_Matching 'GLSO', '0-00-2105', 1
*/
ALTER PROCEDURE USP_GL_XCB_DetailTrailBalance_Matching
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@JustSWSUpdate	Bit = 0,
		@ProNumber		Varchar(15) = Null
AS
/*
========================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
========================================================================================================================
1.0			01/10/2023	Carlos A. Flores	Created for the matching process and update of SWS information
========================================================================================================================
*/
SET NOCOUNT ON

IF (SELECT TOP 1 InsertedOn FROM GP_XCB_Prepaid_Temp) < CAST(GETDATE() AS Date)
	TRUNCATE TABLE GP_XCB_Prepaid_Temp

DECLARE @Query			Varchar(MAX),
		@ProNumbers		Varchar(MAX) = '',
		@ProcDate		Date = GETDATE(),
		@AccountIndex	Int,
		@MaxDate		Date,
		@Counter		Int = 0

DECLARE @tblAcctData	Table (AcctIndex Int, AcctDescription Varchar(100) Null)

SET @Query = N'SELECT ACTINDX, RTRIM(ACTDESCR) FROM ' + @Company + '.dbo.GL00100 WHERE ACTINDX IN (SELECT ACTINDX FROM ' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + @GLAccount + ''')'

INSERT INTO @tblAcctData
EXECUTE(@Query)

SELECT	@AccountIndex = AcctIndex
FROM	@tblAcctData

IF @JustSWSUpdate = 0
BEGIN
	DECLARE	@Record1	Int,
			@Record2	Int,
			@Date1		Date,
			@Date2		Date,
			@TrxDate1	Date,
			@TrxDate2	Date

	DECLARE	@tblMatched Table (Record1 Int, Record2 Int, Date1 Date, Date2 Date, TrxDate1 Date, TrxDate2 Date)

	-- MATCHING BY PRONUMBER SUMMARY
	DECLARE @tblSource1 Table (
	ProNumber		Varchar(15),
	TrxDate			Date,
	Vendor			Varchar(15),
	FP_StartDate	Date,
	Amount			Numeric(10,2),
	Summary			Numeric(10,2),
	RecordId		Int)

	DECLARE @tblSource2 Table (
	ProNumber		Varchar(15),
	TrxDate			Date,
	Vendor			Varchar(15),
	FP_StartDate	Date,
	Amount			Numeric(10,2),
	Summary			Numeric(10,2),
	RecordId		Int)

	INSERT INTO @tblSource1
	SELECT	XCB1.ProNumber,
			XCB1.TrxDate,
			IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) AS Vendor,
			XCB1.FP_StartDate,
			XCB1.Amount,
			Summary = (SELECT SUM(Amount) FROM GP_XCB_Prepaid XCB WHERE XCB.Company = XCB1.Company AND XCB.GLAccount = XCB1.GLAccount AND XCB.ProNumber = XCB1.ProNumber AND XCB.Vendor = XCB1.Vendor AND XCB.Amount > 0),
			XCB1.RecordId
	FROM	GP_XCB_Prepaid XCB1
	WHERE	XCB1.Company = @Company
			AND XCB1.GLAccount = @GLAccount
			AND ((XCB1.Matched = 0 AND @ProNumber IS Null) OR (@ProNumber IS NOT Null AND XCB1.ProNumber = @ProNumber))
			AND XCB1.Amount > 0
			AND IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) <> ''
			AND XCB1.ProNumber <> ''
			AND XCB1.RecordId NOT IN (SELECT RecordId FROM GP_XCB_Prepaid_Matched)

	INSERT INTO @tblSource2
	SELECT	XCB1.ProNumber,
			XCB1.TrxDate,
			IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) AS Vendor,
			XCB1.FP_StartDate,
			XCB1.Amount,
			Summary = (SELECT SUM(ABS(Amount)) FROM GP_XCB_Prepaid XCB WHERE XCB.Company = XCB1.Company AND XCB.GLAccount = XCB1.GLAccount AND XCB.ProNumber = XCB1.ProNumber AND XCB.Vendor = XCB1.Vendor AND XCB.Amount < 0),
			XCB1.RecordId
	FROM	GP_XCB_Prepaid XCB1
	WHERE	XCB1.Company = @Company
			AND XCB1.GLAccount = @GLAccount
			AND ((XCB1.Matched = 0 AND @ProNumber IS Null) OR (@ProNumber IS NOT Null AND XCB1.ProNumber = @ProNumber))
			AND XCB1.Amount < 0
			AND IIF(XCB1.Vendor = '', ISNULL(XCB1.SWSVendor, ''), XCB1.Vendor) <> ''
			AND XCB1.ProNumber <> ''
			AND XCB1.RecordId NOT IN (SELECT RecordId FROM GP_XCB_Prepaid_Matched)
			
	UPDATE	GP_XCB_Prepaid
	SET		GP_XCB_Prepaid.Matched = 1,
			GP_XCB_Prepaid.ProcessingDate = @ProcDate,
			GP_XCB_Prepaid.MatchFrom = DATA.FP_StartDate
	FROM	(
			SELECT	DISTINCT S1.RecordId, S2.FP_StartDate
			FROM	@tblSource1 S1
					INNER JOIN @tblSource2 S2 ON S1.ProNumber = S2.ProNumber AND S1.Vendor = S2.Vendor AND S1.Summary = S2.Summary
			UNION
			SELECT	DISTINCT S2.RecordId, S1.FP_StartDate
			FROM	@tblSource1 S1
					INNER JOIN @tblSource2 S2 ON S1.ProNumber = S2.ProNumber AND S1.Vendor = S2.Vendor AND S1.Summary = S2.Summary
			) DATA
	WHERE	GP_XCB_Prepaid.RecordId = DATA.RecordId

	INSERT INTO GP_XCB_Prepaid_Matched (RecordId, MatchedOn)
	SELECT	RecordId, MAX(MaxDate) AS MaxDate
	FROM	(
			SELECT	DISTINCT S1.RecordId, IIF(S1.TrxDate > S2.TrxDate, S1.TrxDate, S2.TrxDate) AS MaxDate
			FROM	@tblSource1 S1
					INNER JOIN @tblSource2 S2 ON S1.ProNumber = S2.ProNumber AND S1.Vendor = S2.Vendor AND S1.Summary = S2.Summary
			UNION
			SELECT	DISTINCT S2.RecordId, IIF(S1.TrxDate > S2.TrxDate, S1.TrxDate, S2.TrxDate) AS MaxDate
			FROM	@tblSource1 S1
					INNER JOIN @tblSource2 S2 ON S1.ProNumber = S2.ProNumber AND S1.Vendor = S2.Vendor AND S1.Summary = S2.Summary
			) DATA
	WHERE	RecordId NOT IN (SELECT RecordId FROM GP_XCB_Prepaid_Matched)
	GROUP BY RecordId

	-- MATCHING BY INDIVIDUAL TRANSACTIONS
	INSERT INTO @tblMatched
	SELECT	DISTINCT TOP 50000 CXB1.RecordId, CXB2.RecordId, CXB1.FP_StartDate, CXB2.FP_StartDate, CXB1.TrxDate, CXB2.TrxDate
	FROM	GP_XCB_Prepaid CXB1
			INNER JOIN GP_XCB_Prepaid CXB2 ON CXB1.Company = CXB2.Company AND CXB1.GLAccount = CXB2.GLAccount AND CXB1.ProNumber = CXB2.ProNumber 
												AND CXB2.Matched = 0
												AND CXB1.RecordId <> CXB2.RecordId 
												AND ABS(CXB1.Amount) = ABS(CXB2.Amount) 
												AND ((CXB1.Amount > 0 AND CXB2.Amount < 0)
												OR (CXB1.Amount < 0 AND CXB2.Amount > 0))
	WHERE	CXB1.Company = @Company
			AND CXB1.GLAccount = @GLAccount
			AND CXB1.Matched = 0
			AND CXB1.ProNumber <> ''
			AND CXB1.RecordId NOT IN (SELECT RecordId FROM GP_XCB_Prepaid_Matched)
	ORDER BY 1, 2
	
	DECLARE curRecordsData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT * FROM @tblMatched

	OPEN curRecordsData 
	FETCH FROM curRecordsData INTO @Record1, @Record2, @Date1, @Date2, @TrxDate1, @TrxDate2

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF NOT EXISTS(SELECT RecordId FROM GP_XCB_Prepaid_Matched WHERE RecordId = @Record1 OR RecordId = @Record2)
		BEGIN
			SET @Counter = @Counter + 1
			SET @MaxDate = IIF(@TrxDate1 > @TrxDate2, @TrxDate1, @TrxDate2)

			UPDATE	GP_XCB_Prepaid
			SET		Matched = 1,
					ProcessingDate = @ProcDate,
					MatchFrom = @Date2
			WHERE	RecordId = @Record1

			UPDATE	GP_XCB_Prepaid
			SET		Matched = 1,
					ProcessingDate = @ProcDate,
					MatchFrom = @Date1
			WHERE	RecordId = @Record2

			IF NOT EXISTS(SELECT RecordId FROM GP_XCB_Prepaid_Matched WHERE RecordId = @Record1)
				INSERT INTO GP_XCB_Prepaid_Matched (RecordId, MatchedOn) VALUES (@Record1, @MaxDate)

			IF NOT EXISTS(SELECT RecordId FROM GP_XCB_Prepaid_Matched WHERE RecordId = @Record2)
				INSERT INTO GP_XCB_Prepaid_Matched (RecordId, MatchedOn) VALUES (@Record2, @MaxDate)
		END

		FETCH FROM curRecordsData INTO @Record1, @Record2, @Date1, @Date2, @TrxDate1, @TrxDate2
	END

	CLOSE curRecordsData
	DEALLOCATE curRecordsData

	PRINT 'Matched Records: ' + CAST(@Counter * 2 AS Varchar)
END

-- UPDATE RECORDS FROM AP VOID TRANSACTIONS
BEGIN
	SET @Query = N'UPDATE GP_XCB_Prepaid SET GP_XCB_Prepaid.ProNumber = DATA.ProNumber, GP_XCB_Prepaid.Reference = RTRIM(DATA.DistRef) 
	FROM (
	SELECT	XCB.RecordId, P3D.DistRef, GPCustom.dbo.FindProNumber(ISNULL(P3D.DistRef,P2D.DistRef)) AS ProNumber
	FROM	GP_XCB_Prepaid XCB
			LEFT JOIN ' + @Company + '.dbo.GL20000 GL2 ON XCB.JournalNo = GL2.JRNENTRY AND XCB.Sequence = GL2.SEQNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30200 P3H ON XCB.Vendor = P3H.VENDORID AND XCB.DocumentNo = P3H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30600 P3D ON P3H.VENDORID = P3D.VENDORID AND P3H.VCHRNMBR = P3D.VCHRNMBR AND P3H.TRXSORCE = P3D.TRXSORCE AND P3D.DSTINDX = ' + CAST(@AccountIndex AS Varchar) + ' 
			LEFT JOIN ' + @Company + '.dbo.PM20000 P2H ON XCB.Vendor = P2H.VENDORID AND XCB.DocumentNo = P2H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM10100 P2D ON P2H.VENDORID = P2D.VENDORID AND P2H.VCHRNMBR = P2D.VCHRNMBR AND P2H.TRXSORCE = P2D.TRXSORCE AND P2D.DSTINDX = ' + CAST(@AccountIndex AS Varchar) + ' 
	WHERE	XCB.Company = ''' + @Company + ''' 
			AND XCB.GLAccount = ''' + @GLAccount + ''' 
			AND XCB.Audit_Trial LIKE ''PMVVR%''
			AND XCB.Reference = ''Purchases''
			AND XCB.ProNumber = ''''
	UNION
	SELECT	XCB.RecordId, P3D.DistRef, GPCustom.dbo.FindProNumber(ISNULL(P3D.DistRef,P2D.DistRef)) AS ProNumber
	FROM	GP_XCB_Prepaid XCB
			LEFT JOIN ' + @Company + '.dbo.GL30000 GL2 ON XCB.JournalNo = GL2.JRNENTRY AND XCB.Sequence = GL2.SEQNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30200 P3H ON XCB.Vendor = P3H.VENDORID AND XCB.DocumentNo = P3H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30600 P3D ON P3H.VENDORID = P3D.VENDORID AND P3H.VCHRNMBR = P3D.VCHRNMBR AND P3H.TRXSORCE = P3D.TRXSORCE AND P3D.DSTINDX = ' + CAST(@AccountIndex AS Varchar) + ' 
			LEFT JOIN ' + @Company + '.dbo.PM20000 P2H ON XCB.Vendor = P2H.VENDORID AND XCB.DocumentNo = P2H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM10100 P2D ON P2H.VENDORID = P2D.VENDORID AND P2H.VCHRNMBR = P2D.VCHRNMBR AND P2H.TRXSORCE = P2D.TRXSORCE AND P2D.DSTINDX = ' + CAST(@AccountIndex AS Varchar) + ' 
	WHERE	XCB.Company = ''' + @Company + ''' 
			AND XCB.GLAccount = ''' + @GLAccount + ''' 
			AND XCB.Audit_Trial LIKE ''PMVVR%''
			AND XCB.Reference = ''Purchases''
			AND XCB.ProNumber = '''') DATA WHERE GP_XCB_Prepaid.RecordId = DATA.RecordId AND DATA.ProNumber <> '''' '

	EXECUTE(@Query)
END

-- UPDATATING TRANSACTION DESCRIPTIONS FROM AP RECORDS IF PRO NUMBER MISSING
BEGIN
	DECLARE	@tblTmpData		Table (
	RecordId				Int,
	JournalNo				Int,
	Reference				Varchar(50),
	GL_Reference			Varchar(50),
	AP_Reference			Varchar(50))

	SET @Query = N'SELECT XCB.RecordId, XCB.JournalNo, XCB.Reference, GL2.REFRENCE, ISNULL(P2D.DistRef,P3D.DistRef) AS DistRef 
	FROM	GP_XCB_Prepaid XCB
			LEFT JOIN ' + @Company + '.dbo.GL20000 GL2 ON XCB.JournalNo = GL2.JRNENTRY AND XCB.Sequence = GL2.SEQNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30200 P3H ON XCB.Vendor = P3H.VENDORID AND XCB.DocumentNo = P3H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30600 P3D ON P3H.VENDORID = P3D.VENDORID AND P3H.VCHRNMBR = P3D.VCHRNMBR AND P3H.TRXSORCE = P3D.TRXSORCE AND P3D.DSTINDX = GL2.ACTINDX
			LEFT JOIN ' + @Company + '.dbo.PM20000 P2H ON XCB.Vendor = P2H.VENDORID AND XCB.DocumentNo = P2H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM10100 P2D ON P2H.VENDORID = P2D.VENDORID AND P2H.VCHRNMBR = P2D.VCHRNMBR AND P2H.TRXSORCE = P2D.TRXSORCE AND P2D.DSTINDX = GL2.ACTINDX
	WHERE	XCB.Company = ''' + @Company + ''' 
			AND XCB.GLAccount = ''' + @GLAccount + ''' 
			AND XCB.Audit_Trial LIKE ''PM%''
			AND XCB.ProNumber = '''' 
	UNION 
	SELECT XCB.RecordId, XCB.JournalNo, XCB.Reference, GL2.REFRENCE, ISNULL(P2D.DistRef,P3D.DistRef) AS DistRef 
	FROM	GP_XCB_Prepaid XCB
			LEFT JOIN ' + @Company + '.dbo.GL30000 GL2 ON XCB.JournalNo = GL2.JRNENTRY AND XCB.Sequence = GL2.SEQNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30200 P3H ON XCB.Vendor = P3H.VENDORID AND XCB.DocumentNo = P3H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM30600 P3D ON P3H.VENDORID = P3D.VENDORID AND P3H.VCHRNMBR = P3D.VCHRNMBR AND P3H.TRXSORCE = P3D.TRXSORCE AND P3D.DSTINDX = GL2.ACTINDX
			LEFT JOIN ' + @Company + '.dbo.PM20000 P2H ON XCB.Vendor = P2H.VENDORID AND XCB.DocumentNo = P2H.DOCNUMBR
			LEFT JOIN ' + @Company + '.dbo.PM10100 P2D ON P2H.VENDORID = P2D.VENDORID AND P2H.VCHRNMBR = P2D.VCHRNMBR AND P2H.TRXSORCE = P2D.TRXSORCE AND P2D.DSTINDX = GL2.ACTINDX
	WHERE	XCB.Company = ''' + @Company + ''' 
			AND XCB.GLAccount = ''' + @GLAccount + ''' 
			AND XCB.Audit_Trial LIKE ''PM%''
			AND XCB.ProNumber ='''''

	INSERT INTO @tblTmpData
	EXECUTE(@Query)

	UPDATE	GP_XCB_Prepaid
	SET		GP_XCB_Prepaid.ProNumber = DATA.ProNumber,
			GP_XCB_Prepaid.Reference = RTRIM(IIF(DATA.SourceDescription = 1, DATA.GL_Reference, DATA.AP_Reference))
	FROM	(
			SELECT	RecordId,
					JournalNo,
					Reference,
					GL_Reference,
					AP_Reference,
					CASE WHEN dbo.WithProNumber(GL_Reference) = 1 THEN dbo.FindProNumber(GL_Reference) 
						 WHEN dbo.WithProNumber(AP_Reference) = 1 THEN dbo.FindProNumber(AP_Reference) 
					ELSE '' END AS ProNumber,
					CASE WHEN dbo.WithProNumber(GL_Reference) = 1 THEN 1
						 WHEN dbo.WithProNumber(AP_Reference) = 1 THEN 2
					ELSE 0 END AS SourceDescription
			FROM	@tblTmpData
			) DATA
	WHERE	GP_XCB_Prepaid.RecordId = DATA.RecordId
			AND DATA.SourceDescription > 0
END
-- UPDATE SWS INFORMATION
DECLARE @tblTemp	Table (RecordId Int, ProNumber Varchar(15))

DECLARE	@tblSWSData Table (
		Pro			Varchar(15), 
		VendorId	Varchar(15),
		VendorName	varchar(75),
		VndInvoice	Varchar(30),
		Cost		Numeric(10,2),
		PayType		Char(1),
		SWS_Status	Char(1), 
		Manif_Date	Date,
		Deliv_Date	Date)

INSERT INTO @tblTemp
SELECT	TOP 600 RecordId, ProNumber 
FROM	GP_XCB_Prepaid
WHERE	(SWSStatus IS Null OR SWSManifestDate IS Null OR SWSDeliveryDate IS Null)
		AND ProNumber <> ''
		AND RecordId NOT IN (SELECT RecordId FROM GP_XCB_Prepaid_Temp)
ORDER BY TrxDate

INSERT INTO GP_XCB_Prepaid_Temp (RecordId, InsertedOn)
SELECT	RecordId, @ProcDate
FROM	@tblTemp
WHERE	RecordId NOT IN (SELECT RecordId FROM GP_XCB_Prepaid_Temp)

DECLARE curFindMatch CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT ProNumber 
FROM	@tblTemp

OPEN curFindMatch 
FETCH FROM curFindMatch INTO @ProNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @ProNumbers = @ProNumbers + IIF(@ProNumbers = '', '', ',') + '|' + @ProNumber + '|'

	FETCH FROM curFindMatch INTO @ProNumber
END

CLOSE curFindMatch
DEALLOCATE curFindMatch

IF @ProNumbers <> ''
BEGIN
	SET @Query = N'SELECT DISTINCT CAST(a.div_code||''-''||a.pro AS STRING) AS pronumber, b.vn_code, c.name, 
			b.vnref, b.amount, b.prepay, a.status, a.invdt, a.deldt
	FROM	TRK.Order a
			INNER JOIN TRK.OrvnPay b ON a.cmpy_no = b.cmpy_no AND a.no = b.or_no AND b.amount <> 0
			INNER JOIN TRK.Vendor c ON a.cmpy_no = c.cmpy_no AND b.vn_code = c.code
	WHERE	a.cmpy_no = 9
			AND CAST(a.div_code||''-''||a.pro AS STRING) IN (' + REPLACE(@ProNumbers, '|', '''') + ')'
	
	INSERT INTO @tblSWSData
	EXECUTE USP_QuerySWS_ReportData @Query

	UPDATE	GP_XCB_Prepaid
	SET		GP_XCB_Prepaid.SWSManifestDate	= DATA.Manif_Date,
			GP_XCB_Prepaid.SWSStatus		= DATA.TxtStatus,
			GP_XCB_Prepaid.SWSDeliveryDate	= DATA.Deliv_Date
	FROM	(
			SELECT	DISTINCT Pro, Manif_Date, Deliv_Date,
					CASE SWS_Status
					WHEN 'C' THEN 'Complete'
					WHEN 'R' THEN 'Ready'
					WHEN 'D' THEN 'Dispatch'
					WHEN 'O' THEN 'Dropped'
					WHEN 'X' THEN 'Deferred'
					WHEN 'A' THEN 'Assigned'
					WHEN 'P' THEN 'Partial'
					WHEN 'V' THEN 'Void'
					END AS TxtStatus
			FROM	@tblSWSData
			) DATA
	WHERE	GP_XCB_Prepaid.ProNumber = DATA.Pro
			AND (GP_XCB_Prepaid.SWSStatus IS Null
			OR GP_XCB_Prepaid.SWSDeliveryDate IS Null
			OR GP_XCB_Prepaid.SWSStatus	<> DATA.TxtStatus)
	
	UPDATE	GP_XCB_Prepaid
	SET		GP_XCB_Prepaid.SWSVendor		= DATA.VendorId,
			GP_XCB_Prepaid.SWSVndName		= DATA.VendorName,
			GP_XCB_Prepaid.SWSVndInvoice	= DATA.VndInvoice,
			GP_XCB_Prepaid.SWSVndCost		= DATA.Cost,
			GP_XCB_Prepaid.SWSPayType		= DATA.PayType
	FROM	@tblSWSData DATA
	WHERE	GP_XCB_Prepaid.ProNumber = DATA.Pro
			AND ABS(GP_XCB_Prepaid.Amount) = DATA.Cost
			AND GP_XCB_Prepaid.SWSVendor IS Null
END

/*
TRUNCATE TABLE GP_XCB_Prepaid_Temp
*/