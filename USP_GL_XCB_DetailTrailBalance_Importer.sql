USE [GPCustom] 
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GL_XCB_DetailTrailBalance_Importer] 
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@DateIni		Date,
		@DateEnd		Date
/*
========================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
========================================================================================================================
1.0			01/06/2023	Carlos A. Flores	Created for the selection and insertion of the GP GL transactions for the 
											submitted fiscal period or date range.
========================================================================================================================
EXECUTE USP_GL_XCB_DetailTrailBalance_Importer 'GLSO', '0-88-1866', '01/01/2023', '01/28/2023'
EXECUTE USP_GL_XCB_DetailTrailBalance_Importer 'GLSO', '0-00-2105', '01/01/2023', '01/28/2023'
========================================================================================================================
*/
AS
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
		@AccountIndex	Int,
		@AccountDescr	Varchar(100)

DECLARE @tblAcctData	Table (AcctIndex Int, AcctDescription Varchar(100) Null)
DECLARE @tblCheckData	Table (Journal Int)

DECLARE @tblGLData		Table (
		COMPANY			Varchar(10),
		OPENYEAR		Int,
		PERIODID		Int,
		JRNENTRY		Int,
		SEQNUMBR		Int,
		ORTRXSRC		Varchar(20),
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
		ORG_DOC_NUMBER	Varchar(50),
		FiscalPeriod	Char(7),
		FP_StartDate	Date,
		UserDefined		Varchar(200))

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

INSERT INTO GP_XCB_Prepaid_Accounts
SELECT	DISTINCT Company, GLAccount 
FROM	GP_XCB_Prepaid 
WHERE	Company + GLAccount NOT IN (SELECT Company + GLAccount FROM GP_XCB_Prepaid_Accounts)

SET @Query = N'SELECT ACTINDX, RTRIM(ACTDESCR) FROM ' + @Company + '.dbo.GL00100 WHERE ACTINDX IN (SELECT ACTINDX FROM ' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + @GLAccount + ''')'

INSERT INTO @tblAcctData
EXECUTE(@Query)

SELECT	@AccountIndex = AcctIndex,
		@AccountDescr = AcctDescription
FROM	@tblAcctData

SET @Query = N'SELECT ''' + @Company + ''',
			G2.OPENYEAR,
			G2.PERIODID,
			G2.JRNENTRY,
			G2.SEQNUMBR,
			G2.ORTRXSRC,
			CASE WHEN LEFT(G2.SOURCDOC, 2) = ''PM'' THEN ''AP''
				 WHEN LEFT(G2.SOURCDOC, 2) IN (''AP'',''CR'',''SJ'') THEN ''AR''
			ELSE ''GL'' END AS GPSOURCE,
			''' + @GLAccount + ''' AS GLACCOUNT,
			CAST(G2.TRXDATE AS Date) AS TRXDATE,
			''' + @AccountDescr + ''' AS ACCTDESCRIPTION,
			RTRIM(G2.DSCRIPTN) AS REFERENCE,
			GPCustom.dbo.FindProNumber(G2.DSCRIPTN) AS PRONUMBER,
			CAST(G2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
			CAST(G2.DEBITAMT AS Numeric(10,2)) As DEBIT,
			RTRIM(G2.ORMSTRID) AS ORG_MSTR_NUMBER,
			RTRIM(G2.ORMSTRNM) AS ORG_MSTR_NAME,
			RTRIM(G2.ORDOCNUM) AS ORG_DOC_NUMBER,
			FPR.GP_Period,
			FPR.StartDate,
			RTRIM(G2.User_Defined_Text01)
	FROM	' + @Company + '.dbo.GL20000 G2
			INNER JOIN DYNAMICS.dbo.View_Fiscalperiod FPR ON G2.OPENYEAR = FPR.YEAR1 AND G2.PERIODID = FPR.PERIODID
			LEFT JOIN GPCustom.dbo.GP_XCB_Prepaid XC ON G2.JRNENTRY = XC.JournalNo AND XC.GLAccount = ''' + @GLAccount + ''' AND G2.SEQNUMBR = XC.Sequence AND XC.Company = ''' + @Company + ''' 
	WHERE	G2.ACTINDX = ' + CAST(@AccountIndex AS Varchar) + '  
			AND G2.TRXDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
			AND LEFT(G2.SOURCDOC, 2) NOT IN (''AP'',''CR'',''SJ'',''RM'')
			AND G2.DSCRIPTN NOT LIKE ''%UPR XFR TO%''
			AND XC.JournalNo IS Null 
			AND G2.SEQNUMBR > 0
			AND G2.VOIDED = 0 
	UNION
	SELECT ''' + @Company + ''',
			G2.HSTYEAR,
			G2.PERIODID,
			G2.JRNENTRY,
			G2.SEQNUMBR,
			G2.ORTRXSRC,
			CASE WHEN LEFT(G2.SOURCDOC, 2) = ''PM'' THEN ''AP''
				 WHEN LEFT(G2.SOURCDOC, 2) IN (''AP'',''CR'',''SJ'') THEN ''AR''
			ELSE ''GL'' END AS GPSOURCE,
			''' + @GLAccount + ''' AS GLACCOUNT,
			CAST(G2.TRXDATE AS Date) AS TRXDATE,
			''' + @AccountDescr + ''' AS ACCTDESCRIPTION,
			RTRIM(G2.DSCRIPTN) AS REFERENCE,
			GPCustom.dbo.FindProNumber(G2.DSCRIPTN) AS PRONUMBER,
			CAST(G2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
			CAST(G2.DEBITAMT AS Numeric(10,2)) As DEBIT,
			RTRIM(G2.ORMSTRID) AS ORG_MSTR_NUMBER,
			RTRIM(G2.ORMSTRNM) AS ORG_MSTR_NAME,
			RTRIM(G2.ORDOCNUM) AS ORG_DOC_NUMBER,
			FPR.GP_Period,
			FPR.StartDate,
			RTRIM(G2.User_Defined_Text01)
	FROM	' + @Company + '.dbo.GL30000 G2
			INNER JOIN DYNAMICS.dbo.View_Fiscalperiod FPR ON G2.HSTYEAR = FPR.YEAR1 AND G2.PERIODID = FPR.PERIODID
			LEFT JOIN GPCustom.dbo.GP_XCB_Prepaid XC ON G2.JRNENTRY = XC.JournalNo AND XC.GLAccount = ''' + @GLAccount + ''' AND G2.SEQNUMBR = XC.Sequence AND XC.Company = ''' + @Company + ''' 
	WHERE	G2.ACTINDX = ' + CAST(@AccountIndex AS Varchar) + '
			AND G2.TRXDATE > ''11/20/2019'' 
			AND G2.TRXDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
			AND LEFT(G2.SOURCDOC, 2) NOT IN (''AP'',''CR'',''SJ'',''RM'')
			AND G2.DSCRIPTN NOT LIKE ''%UPR XFR TO%''
			AND XC.JournalNo IS Null 
			AND G2.SEQNUMBR > 0
			AND G2.VOIDED = 0' -- OR (G2.VOIDED = 1 AND LEFT(G2.SOURCDOC, 2) = ''PM''))

INSERT INTO @tblGLData
EXECUTE(@Query)

INSERT INTO GP_XCB_Prepaid (Company, TrxDate, JournalNo, Sequence, Audit_Trial, Reference, DocumentNo, Vendor, Amount, ProNumber, GPPeriod, GLAccount, Matched, FiscalPeriod, FP_StartDate)
SELECT	@Company,
		TRXDATE, 
		JRNENTRY,
		SEQNUMBR,
		ORTRXSRC,
		REFERENCE,
		ORG_DOC_NUMBER, 
		IIF(ORG_MSTR_NUMBER = '', IIF(UserDefined LIKE 'VND:%', REPLACE(LEFT(UserDefined, dbo.AT('-', UserDefined, 1) - 1), 'VND:', ''), ''), ORG_MSTR_NUMBER), 
		IIF(CREDIT > 0, CREDIT * -1, DEBIT),
		PRONUMBER, 
		LEFT(DATENAME(mm, DATEADD(mm , PERIODID, -1 )), 3) + '-' + RIGHT(CAST(OPENYEAR AS Varchar), 2) AS GPPeriod, 
		@GLAccount,
		0 AS Matched,
		FiscalPeriod,
		FP_StartDate
FROM	@tblGLData

--UPDATE	GP_XCB_Prepaid
--SET		ProNumber = dbo.FindProNumber(DocumentNo)
--WHERE	Company = @Company
--		AND GLAccount = @GLAccount
--		AND ProNumber = ''
--		AND dbo.WithProNumber(Reference) = 0
--		AND dbo.WithProNumber(DocumentNo) = 1

/*
AND G2.DSCRIPTN NOT LIKE ''%UPR XFR TO%'' 

SELECT * FROM DYNAMICS.dbo.View_Fiscalperiod FP WHERE YEAR1 = 2022 ORDER BY PERIODID

-- TRUNCATE TABLE GP_XCB_Prepaid
*/