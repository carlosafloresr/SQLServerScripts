/*
EXECUTE USP_GL_XCB_DetailTrailBalance_Special 'GIS', '0-88-1866', 1231539
*/
ALTER PROCEDURE USP_GL_XCB_DetailTrailBalance_Special
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@Journal		Int
AS
SET NOCOUNT ON

DECLARE @tblAcctData	Table (AcctIndex Int, AcctDescription Varchar(100) Null)

DECLARE	@Query			Varchar(MAX),
		@TrxDate		Date,
		@Reference		Varchar(100),
		@DocumentNo		Varchar(30),
		@Vendor			Varchar(30),
		@Amount			Numeric(10,2),
		@ProNumber		Varchar(15),
		@GPPeriod		Char(6),
		@Matched		Bit,
		@AccountIndex	Int,
		@AccountDescr	Varchar(100),
		@SpecialImport	Bit

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
		AMOUNT			Numeric(10,2),
		ORG_MSTR_NUMBER	Varchar(30),
		ORG_MSTR_NAME	Varchar(100),
		ORG_DOC_NUMBER	Varchar(50),
		FiscalPeriod	Char(7),
		FP_StartDate	Date,
		Division		Char(2))

DECLARE @tblGLEndData	Table (
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
		REFERENCE		Varchar(100) Null,
		PRONUMBER		Varchar(50),
		AMOUNT			Numeric(10,2),
		ORG_MSTR_NUMBER	Varchar(30),
		ORG_MSTR_NAME	Varchar(100),
		ORG_DOC_NUMBER	Varchar(50),
		FiscalPeriod	Char(7),
		FP_StartDate	Date,
		Division		Char(2),
		DivSummary		Numeric(12, 2))

SET @Query = N'SELECT ACTINDX, RTRIM(ACTDESCR) FROM ' + @Company + '.dbo.GL00100 WHERE ACTINDX IN (SELECT ACTINDX FROM ' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + @GLAccount + ''')'

INSERT INTO @tblAcctData
EXECUTE(@Query)

SELECT	@AccountIndex = AcctIndex,
		@AccountDescr = AcctDescription
FROM	@tblAcctData

INSERT INTO @tblGLData
SELECT	@Company AS Company,
		G2.HSTYEAR,
		G2.PERIODID,
		G2.JRNENTRY,
		G2.SEQNUMBR,
		G2.ORTRXSRC,
		CASE WHEN LEFT(G2.SOURCDOC, 2) = 'PM' THEN 'AP'
				WHEN LEFT(G2.SOURCDOC, 2) IN ('AP','CR','SJ') THEN 'AR'
		ELSE 'GL' END AS GPSOURCE,
		@GLAccount AS GLACCOUNT,
		CAST(G2.TRXDATE AS Date) AS TRXDATE,
		@AccountDescr AS ACCTDESCRIPTION,
		IIF(G2.ACTINDX = 650, REPLACE(REPLACE(G2.DSCRIPTN, '(', ''), ')', ''), RTRIM(ISNULL(TMP.MainText + ' [' + TMP.ProNumber + ']', G2.REFRENCE))) AS REFERENCE,
		TMP.PRONUMBER,
		IIF(G2.ACTINDX = 650, G2.DEBITAMT - G2.CRDTAMNT, G2.CRDTAMNT - G2.DEBITAMT) AS AMOUNT,
		RTRIM(G2.ORMSTRID) AS ORG_MSTR_NUMBER,
		RTRIM(G2.ORMSTRNM) AS ORG_MSTR_NAME,
		RTRIM(G2.ORDOCNUM) AS ORG_DOC_NUMBER,
		FPR.GP_Period,
		FPR.StartDate,
		TMP.Division
FROM	GLSO.dbo.GL30000 G2
		INNER JOIN (
					SELECT	G2.JRNENTRY,
							G2.SEQNUMBR,
							dbo.FindProNumber(G2.DSCRIPTN) AS ProNumber,
							LEFT(dbo.FindProNumber(G2.DSCRIPTN), 2) AS Division,
							MainText = ISNULL(REPLACE(REPLACE((SELECT RTRIM(T.REFRENCE) FROM GLSO.dbo.GL30000 T WHERE T.JRNENTRY = G2.JRNENTRY AND T.ACTINDX = 650 AND LEFT(T.REFRENCE, 4) = '(' + LEFT(dbo.FindProNumber(G2.DSCRIPTN), 2) + ')'), '(', ''), ')', ''), RTRIM(G2.DSCRIPTN))
					FROM	GLSO.dbo.GL30000 G2
							LEFT JOIN GPCustom.dbo.GP_XCB_Prepaid XC ON G2.JRNENTRY = XC.JournalNo AND XC.GLAccount = @GLAccount AND G2.SEQNUMBR = XC.Sequence AND XC.Company = @Company  
					WHERE	G2.JRNENTRY = @Journal
							AND LEFT(G2.SOURCDOC, 2) NOT IN ('AP','CR','SJ','RM')
							AND XC.JournalNo IS Null 
							AND G2.VOIDED = 0
					) TMP ON G2.JRNENTRY = TMP.JRNENTRY AND G2.SEQNUMBR = TMP.SEQNUMBR
		INNER JOIN DYNAMICS.dbo.View_Fiscalperiod FPR ON G2.HSTYEAR = FPR.YEAR1 AND G2.PERIODID = FPR.PERIODID
UNION
SELECT	@Company AS Company,
		G2.OPENYEAR,
		G2.PERIODID,
		G2.JRNENTRY,
		G2.SEQNUMBR,
		G2.ORTRXSRC,
		CASE WHEN LEFT(G2.SOURCDOC, 2) = 'PM' THEN 'AP'
				WHEN LEFT(G2.SOURCDOC, 2) IN ('AP','CR','SJ') THEN 'AR'
		ELSE 'GL' END AS GPSOURCE,
		@GLAccount AS GLACCOUNT,
		CAST(G2.TRXDATE AS Date) AS TRXDATE,
		@AccountDescr AS ACCTDESCRIPTION,
		IIF(G2.ACTINDX = 650, REPLACE(REPLACE(G2.DSCRIPTN, '(', ''), ')', ''), RTRIM(ISNULL(TMP.MainText + ' [' + TMP.ProNumber + ']', G2.REFRENCE))) AS REFERENCE,
		TMP.PRONUMBER,
		IIF(G2.ACTINDX = 650, G2.DEBITAMT - G2.CRDTAMNT, G2.CRDTAMNT - G2.DEBITAMT) AS AMOUNT,
		RTRIM(G2.ORMSTRID) AS ORG_MSTR_NUMBER,
		RTRIM(G2.ORMSTRNM) AS ORG_MSTR_NAME,
		RTRIM(G2.ORDOCNUM) AS ORG_DOC_NUMBER,
		FPR.GP_Period,
		FPR.StartDate,
		TMP.Division
FROM	GLSO.dbo.GL20000 G2
		INNER JOIN (
					SELECT	G2.JRNENTRY,
							G2.SEQNUMBR,
							dbo.FindProNumber(G2.DSCRIPTN) AS ProNumber,
							LEFT(dbo.FindProNumber(G2.DSCRIPTN), 2) AS Division,
							MainText = REPLACE(REPLACE((SELECT RTRIM(T.REFRENCE) FROM GLSO.dbo.GL20000 T WHERE T.JRNENTRY = G2.JRNENTRY AND T.ACTINDX = 650 AND LEFT(T.REFRENCE, 4) = '(' + LEFT(dbo.FindProNumber(G2.DSCRIPTN), 2) + ')'), '(', ''), ')', '')
					FROM	GLSO.dbo.GL20000 G2
							LEFT JOIN GPCustom.dbo.GP_XCB_Prepaid XC ON G2.JRNENTRY = XC.JournalNo AND XC.GLAccount = @GLAccount AND G2.SEQNUMBR = XC.Sequence AND XC.Company = @Company  
					WHERE	G2.JRNENTRY = @Journal
							AND LEFT(G2.SOURCDOC, 2) NOT IN ('AP','CR','SJ','RM')
							AND XC.JournalNo IS Null 
							AND G2.VOIDED = 0
					) TMP ON G2.JRNENTRY = TMP.JRNENTRY AND G2.SEQNUMBR = TMP.SEQNUMBR
		INNER JOIN DYNAMICS.dbo.View_Fiscalperiod FPR ON G2.OPENYEAR = FPR.YEAR1 AND G2.PERIODID = FPR.PERIODID

INSERT INTO @tblGLEndData
SELECT	TMP.*,
		SumDiv = IIF(TMP.ProNumber = '', ISNULL((SELECT SUM(T.AMOUNT) FROM @tblGLData T WHERE T.Division = LEFT(TMP.REFERENCE, 2)), 0), 0)
FROM	@tblGLData TMP

IF (SELECT ISNULL(SUM(AMOUNT), 1) FROM @tblGLEndData WHERE ProNumber = '') = (SELECT ISNULL(SUM(DivSummary), 2) FROM @tblGLEndData)
BEGIN
	--INSERT INTO GP_XCB_Prepaid (Company, TrxDate, JournalNo, Sequence, Audit_Trial, Reference, DocumentNo, Vendor, Amount, ProNumber, GPPeriod, GLAccount, Matched, FiscalPeriod, FP_StartDate)
	SELECT	@Company,
			TRXDATE, 
			JRNENTRY,
			SEQNUMBR,
			ORTRXSRC,
			REFERENCE,
			ORG_DOC_NUMBER, 
			ORG_MSTR_NUMBER, 
			AMOUNT,
			PRONUMBER, 
			LEFT(DATENAME(mm, DATEADD(mm , PERIODID, -1 )), 3) + '-' + RIGHT(CAST(OPENYEAR AS Varchar), 2) AS GPPeriod, 
			@GLAccount,
			0 AS Matched,
			FiscalPeriod,
			FP_StartDate
	FROM	@tblGLEndData
	WHERE	PRONUMBER <> ''
	ORDER BY PRONUMBER, AMOUNT
END
ELSE
	PRINT 'The Journal # ' + CAST(1231539 AS Varchar) + ' don''t comply with the expected journal type'

/*
SELECT	JRNENTRY, REFRENCE, DSCRIPTN, DEBITAMT, CRDTAMNT, GL.ACTINDX, dbo.FindProNumber(DSCRIPTN) AS ProNumber, G5.ACTNUMST AS Account
		FROM	GLSO.dbo.GL30000 GL
				INNER JOIN GLSO.dbo.GL00105 G5 ON GL.ACTINDX = G5.ACTINDX
		WHERE	JRNENTRY = 1473717

SELECT	DISTINCT JournalNo, Reference
FROM	GP_XCB_Prepaid
WHERE	MATCHED = 0
		AND GLACCOUNT = '0-88-1866'
		AND ProNumber = ''
		AND (Reference LIKE '([0-9][0-9])%' or Reference LIKE '[0-9][0-9]%')
ORDER BY JournalNo
*/