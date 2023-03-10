USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GL_DetailTrailBalance_New]    Script Date: 12/19/2022 2:03:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_GL_DetailTrailBalance_New]
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@DateIni		Date,
		@DateEnd		Date
AS
/*
EXECUTE USP_GL_DetailTrailBalance_New 'GLSO', '0-88-1866', '01/03/2022', '12/03/2022'
*/
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@TrxDate		Date,
		@JournalNo		Int,
		@Reference		Varchar(100),
		@DocumentNo		Varchar(30),
		@Vendor			Varchar(30),
		@Amount			Numeric(10,2),
		@ProNumber		Varchar(15),
		@GPPeriod		Char(6),
		@Matched		Bit,
		@AccountIndex	Int

DECLARE @tblAcctData	Table (AcctIndex Int)
DECLARE @tblCheckData	Table (Journal Int)

DECLARE @tblGLData		Table (
		COMPANY			Varchar(10),
		OPENYEAR		Int,
		PERIODID		Int,
		JRNENTRY		Int,
		GPSOURCE		Char(2),
		GLACCOUNT		Varchar(25),
		TRXDATE			Date,
		ACCTDESCRIPTION	Varchar(100),
		REFERENCE		Varchar(100),
		PRONUMBER		Varchar(50),
		CREDIT			Numeric(10,2),
		DEBIT			Numeric(10,2),
		ORG_MSTR_NUMBER	Varchar(30),
		ORG_MSTR_NAME	Varchar(100),
		ORG_DOC_NUMBER	Varchar(50))

DECLARE @tblReadData	Table (
		Company			Varchar(10),
		TrxDate			Date,
		JournalNo		Int,
		Reference		Varchar(100),
		DocumentNo		Varchar(30),
		Vendor			Varchar(30),
		Amount			Numeric(10,2),
		ProNumber		Varchar(15),
		GPPeriod		Char(6))

DECLARE @tblTempData	Table (
		TrxDate			Date,
		JournalNo		Int,
		Reference		Varchar(100),
		DocumentNo		Varchar(30),
		Vendor			Varchar(30),
		Amount			Numeric(10,2),
		ProNumber		Varchar(15),
		YEAR1			Int,
		PERIODID		Int)

SET @Query = N'SELECT ACTINDX FROM ' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + @GLAccount + ''''

INSERT INTO @tblAcctData
EXECUTE(@Query)

SET @AccountIndex = (SELECT AcctIndex FROM @tblAcctData)

SET @Query = N'SELECT ''' + @Company + ''',
		G2.OPENYEAR,
		G2.PERIODID,
		G2.JRNENTRY,
		CASE WHEN LEFT(G2.SOURCDOC, 2) = ''PM'' THEN ''AP''
			 WHEN LEFT(G2.SOURCDOC, 2) IN (''AP'',''CR'',''SJ'') THEN ''AR''
		ELSE ''GL'' END AS GPSOURCE,
		RTRIM(G5.ACTNUMST) AS GLACCOUNT,
		CAST(G2.TRXDATE AS Date) AS TRXDATE,
		RTRIM(G1.ACTDESCR) AS ACCTDESCRIPTION,
		RTRIM(G2.REFRENCE) AS REFERENCE,
		GPCustom.dbo.FindProNumber(G2.REFRENCE) AS PRONUMBER,
		CAST(G2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		CAST(G2.DEBITAMT AS Numeric(10,2)) As DEBIT,
		RTRIM(G2.ORMSTRID) AS ORG_MSTR_NUMBER,
		RTRIM(G2.ORMSTRNM) AS ORG_MSTR_NAME,
		RTRIM(G2.ORDOCNUM) AS ORG_DOC_NUMBER
FROM	' + @Company + '.dbo.GL20000 G2
		INNER JOIN ' + @Company + '.dbo.GL00100 G1 ON G2.ACTINDX = G1.ACTINDX
		INNER JOIN ' + @Company + '.dbo.GL00105 G5 ON G2.ACTINDX = G5.ACTINDX
		LEFT JOIN GPCustom.dbo.GP_XCB_Prepaid XC ON G2.JRNENTRY = XC.JournalNo AND G5.ACTNUMST = XC.GLAccount AND XC.Company = ''' + @Company + ''' 
WHERE	G5.ACTNUMST = ''' + @GLAccount + '''  
		AND G2.TRXDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
		AND LEFT(G2.SOURCDOC, 2) NOT IN (''AP'',''CR'',''SJ'',''RM'')
		AND XC.JournalNo IS Null 
		AND (G2.VOIDED = 0 OR (G2.VOIDED = 1 AND LEFT(G2.SOURCDOC, 2) = ''PM'')) 
UNION
SELECT ''' + @Company + ''',
		G2.HSTYEAR,
		G2.PERIODID,
		G2.JRNENTRY,
		CASE WHEN LEFT(G2.SOURCDOC, 2) = ''PM'' THEN ''AP''
			 WHEN LEFT(G2.SOURCDOC, 2) IN (''AP'',''CR'',''SJ'') THEN ''AR''
		ELSE ''GL'' END AS GPSOURCE,
		RTRIM(G5.ACTNUMST) AS GLACCOUNT,
		CAST(G2.TRXDATE AS Date) AS TRXDATE,
		RTRIM(G1.ACTDESCR) AS ACCTDESCRIPTION,
		RTRIM(G2.REFRENCE) AS REFERENCE,
		GPCustom.dbo.FindProNumber(G2.REFRENCE) AS PRONUMBER,
		CAST(G2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		CAST(G2.DEBITAMT AS Numeric(10,2)) As DEBIT,
		RTRIM(G2.ORMSTRID) AS ORG_MSTR_NUMBER,
		RTRIM(G2.ORMSTRNM) AS ORG_MSTR_NAME,
		RTRIM(G2.ORDOCNUM) AS ORG_DOC_NUMBER
FROM	' + @Company + '.dbo.GL30000 G2
		INNER JOIN ' + @Company + '.dbo.GL00100 G1 ON G2.ACTINDX = G1.ACTINDX
		INNER JOIN ' + @Company + '.dbo.GL00105 G5 ON G2.ACTINDX = G5.ACTINDX
		LEFT JOIN GPCustom.dbo.GP_XCB_Prepaid XC ON G2.JRNENTRY = XC.JournalNo AND G5.ACTNUMST = XC.GLAccount AND XC.Company = ''' + @Company + ''' 
WHERE	G5.ACTNUMST = ''' + @GLAccount + ''' 
		AND G2.TRXDATE > ''12/31/2019'' 
		AND G2.TRXDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
		AND LEFT(G2.SOURCDOC, 2) NOT IN (''AP'',''CR'',''SJ'',''RM'')
		AND XC.JournalNo IS Null 
		AND (G2.VOIDED = 0 OR (G2.VOIDED = 1 AND LEFT(G2.SOURCDOC, 2) = ''PM''))'
--PRINT @Query
INSERT INTO @tblGLData
EXECUTE(@Query)

INSERT INTO GP_XCB_Prepaid (Company, TrxDate, JournalNo, Reference, DocumentNo, Vendor, Amount, ProNumber, GPPeriod, GLAccount, Matched)
SELECT	@Company,
		TRXDATE, 
		JRNENTRY, 
		REFERENCE, 
		ORG_DOC_NUMBER, 
		ORG_MSTR_NUMBER, 
		IIF(CREDIT > 0, CREDIT * -1, DEBIT),
		PRONUMBER, 
		LEFT(DATENAME(mm, DATEADD(mm , PERIODID, -1 )), 3) + '-' + RIGHT(CAST(OPENYEAR AS Varchar), 2) AS GPPeriod, 
		@GLAccount,
		0 AS Matched 
FROM	@tblGLData

--DECLARE curFindMatch CURSOR LOCAL KEYSET OPTIMISTIC FOR
--SELECT	DAT.TRXDATE,
--		DAT.JRNENTRY,
--		DAT.REFERENCE,
--		DAT.ORG_DOC_NUMBER,
--		DAT.ORG_MSTR_NUMBER,
--		IIF(DAT.CREDIT > 0, DAT.CREDIT * -1, DAT.DEBIT) AS Amount,
--		DAT.PRONUMBER,
--		LEFT(DATENAME(month, DATEADD(month , DAT.PERIODID, -1 )), 3) + '-' + RIGHT(CAST(DAT.OPENYEAR AS Varchar), 2) AS Period
--FROM	@tblGLData DAT
--WHERE	PRONUMBER <> ''
--ORDER BY DAT.OPENYEAR,
--		DAT.GLACCOUNT,
--		DAT.PERIODID,
--		DAT.JRNENTRY

--OPEN curFindMatch 
--FETCH FROM curFindMatch INTO @TrxDate, @JournalNo, @Reference, @DocumentNo, @Vendor, @Amount, @ProNumber, @GPPeriod

--WHILE @@FETCH_STATUS = 0 
--BEGIN
--	DELETE @tblTempData
--	DELETE @tblCheckData

--	SET @Query = N'SELECT JournalNo FROM GPCustom.dbo.GP_XCB_Prepaid WHERE JournalNo = ' + CAST(@JournalNo AS Varchar) + ' AND Matched = 1 AND Company = ''' + @Company + ''' AND GLAccount = ''' + @GLAccount + ''''

--	INSERT INTO @tblCheckData
--	EXECUTE(@Query)

--	IF (SELECT COUNT(*) FROM @tblCheckData) = 0 -- We just validate not previously matched records
--	BEGIN
--		SET @Query = N'SELECT TRXDATE, JRNENTRY, REFRENCE, RTRIM(ORDOCNUM) AS DocumentNo, RTRIM(ORMSTRID) AS Vendor, DEBITAMT + CRDTAMNT AS Amount, GPCustom.dbo.FindProNumber(REFRENCE), OPENYEAR, PERIODID 
--		FROM	' + @Company + '.dbo.GL20000
--		WHERE	(REFRENCE LIKE ''%' + @ProNumber + '%''
--				OR REFRENCE LIKE ''%' + REPLACE(@ProNumber, '-', '') + '%'')
--				AND (CRDTAMNT + DEBITAMT) = ' + CAST(ABS(@Amount) AS nVarchar) + ' 
--				AND ACTINDX = ' + CAST(@AccountIndex AS Varchar) + ' 
--				AND JRNENTRY <> ' + CAST(@JournalNo AS Varchar)
				
--		INSERT INTO @tblTempData
--		EXECUTE(@Query)

--		SET @Matched = IIF((SELECT COUNT(*) FROM @tblTempData) > 0, 1, 0)

--		INSERT INTO GP_XCB_Prepaid (Company, TrxDate, JournalNo, Reference, DocumentNo, Vendor, Amount, ProNumber, GPPeriod, GLAccount, Matched)
--		VALUES (@Company, @TrxDate, @JournalNo, @Reference, @DocumentNo, @Vendor, @Amount, @ProNumber, @GPPeriod, @GLAccount, @Matched)

--		IF @Matched = 1
--		BEGIN
--			INSERT INTO GP_XCB_Prepaid (Company, TrxDate, JournalNo, Reference, DocumentNo, Vendor, Amount, ProNumber, GPPeriod, GLAccount, Matched)
--			SELECT	@Company,
--					TrxDate, 
--					JournalNo, 
--					Reference, 
--					DocumentNo, 
--					Vendor, 
--					Amount, 
--					ProNumber, 
--					LEFT(DATENAME(mm, DATEADD(mm , PERIODID, -1 )), 3) + '-' + RIGHT(CAST(YEAR1 AS Varchar), 2) AS GPPeriod, 
--					@GLAccount,
--					@Matched 
--			FROM	@tblTempData
--		END
--	END

--	FETCH FROM curFindMatch INTO @TrxDate, @JournalNo, @Reference, @DocumentNo, @Vendor, @Amount, @ProNumber, @GPPeriod
--END

--CLOSE curFindMatch
--DEALLOCATE curFindMatch
