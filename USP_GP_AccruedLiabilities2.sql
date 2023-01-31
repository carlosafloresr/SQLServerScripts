/*
EXECUTE USP_GP_AccruedLiabilities2 'GLSO', '0-00-2105', '03/12/2020'
EXECUTE USP_GP_AccruedLiabilities2 'GLSO', '0-88-1866', '03/07/2020'
*/
ALTER PROCEDURE USP_GP_AccruedLiabilities2
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@AsOfDate		date
AS
SET NOCOUNT ON

DECLARE	@tblBkpData		Table (		
		Company			Varchar(5),
		TRXDATE			Date,
		ACTNUMST		Varchar(15),
		JRNENTRY		Int,
		ORTRXSRC		Varchar(30),
		REFRENCE		Varchar(30),
		SERIES			Smallint,
		ORMSTRID		Varchar(30),
		ORDOCNUM		Varchar(30),
		DEBITAMT		Numeric(10,2),
		CRDTAMNT		Numeric(10,2),
		DataSource		Varchar(12))

DECLARE	@tblData		Table (
		Company			Varchar(5),
		TransDate		Date,
		Account			Varchar(30),
		JournalEntry	Int,
		SourceDocument	Varchar(30),
		OrigAuditTrail	Varchar(30),
		DistReference	Varchar(30),
		Series			Varchar(10),
		Vendor			Varchar(100),
		VendorId		Varchar(30),
		Amount			Numeric(10,2),
		Pro				Varchar(30),
		AP_Period		Char(7),
		DataSource		Varchar(12))

--PRINT 'INSERT HISTORY'
--INSERT INTO @tblBkpData
--SELECT	@Company AS Company,
--		GL3.TRXDATE,
--		GL5.ACTNUMST,
--		GL3.JRNENTRY,
--		GL3.ORTRXSRC,
--		GL3.REFRENCE,
--		GL3.SERIES,
--		GL3.ORMSTRID,
--		GL3.ORDOCNUM,
--		GL3.DEBITAMT,
--		GL3.CRDTAMNT,
--		'HISTORY' AS DataSource
--FROM	GLSO.dbo.GL30000 GL3
--		INNER JOIN GLSO.dbo.GL00105 GL5 ON GL3.ACTINDX = GL5.ACTINDX
--		LEFT JOIN GP_AccruedLiabilities GAL ON 
--			GL3.TRXDATE = GAL.TransDate 
--			AND GL3.REFRENCE = GAL.OrigAuditTrail
--			AND GL3.ORTRXSRC = GAL.SourceDocument
--			AND GL5.ACTNUMST = GAL.Account
--WHERE	GL5.ACTNUMST = @GLAccount
--		AND GL3.TRXDATE BETWEEN DATEADD(dd, -365, @AsOfDate) AND @AsOfDate
--		AND GAL.Account IS Null

PRINT 'INSERT OPEN'
INSERT INTO @tblBkpData
SELECT	@Company AS Company,
		GL2.TRXDATE,
		GL5.ACTNUMST,
		GL2.JRNENTRY,
		GL2.ORTRXSRC,
		GL2.REFRENCE,
		GL2.SERIES,
		GL2.ORMSTRID,
		GL2.ORDOCNUM,
		GL2.DEBITAMT,
		GL2.CRDTAMNT,
		'OPEN' AS DataSource
FROM	GLSO.dbo.GL20000 GL2
		INNER JOIN GLSO.dbo.GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
		LEFT JOIN GP_AccruedLiabilities GAL ON 
			GL2.TRXDATE = GAL.TransDate 
			AND GL2.REFRENCE = GAL.OrigAuditTrail
			AND GL2.ORTRXSRC = GAL.SourceDocument
			AND GL5.ACTNUMST = GAL.Account
WHERE	GL5.ACTNUMST = @GLAccount
		AND GL2.TRXDATE BETWEEN DATEADD(dd, -365, @AsOfDate) AND @AsOfDate
		AND GAL.Account IS Null

DECLARE @Count Int = (SELECT COUNT(*) FROM @tblBkpData)

PRINT @Count

PRINT 'PROCESS DATA'
INSERT INTO @tblData
SELECT	GPD.Company,
		GPD.TransDate,
		GPD.Account,
		GPD.JournalEntry,
		GPD.SourceDocument,
		GPD.OrigAuditTrail,
		GPD.DistReference,
		GPD.Series,
		ISNULL(LEFT(UPPER(RTRIM(VND.VENDNAME)), 100), '') AS Vendor,
		ISNULL(FSI.RecordCode, GPD.VendorId) AS VendorId,
		GPD.Amount,
		GPD.Pro,
		GPD.GP_Period,
		GPD.DataSource
FROM	(
	SELECT	GLO.Company,
			GLO.TRXDATE AS TransDate,
			RTRIM(GLO.ACTNUMST) AS Account,
			GLO.JRNENTRY AS JournalEntry,
			GLO.ORTRXSRC AS SourceDocument,
			RTRIM(GLO.REFRENCE) AS OrigAuditTrail,
			CASE WHEN GLO.SERIES = 4 THEN GLO.ORDOCNUM 
				 ELSE RTRIM(CASE WHEN GPCustom.dbo.AT('|', GLO.REFRENCE, 1) > 0 THEN SUBSTRING(GLO.REFRENCE, GPCustom.dbo.AT('|', GLO.REFRENCE, 1) + 1, 25) ELSE GLO.REFRENCE END) 
			END AS DistReference,
			GLO.SERIES AS GPSeries,
			CASE GLO.SERIES 
				WHEN 1 THEN 'ALL' 
				WHEN 2 THEN 'Financial' 
				WHEN 3 THEN 'Sales' 
				WHEN 4 THEN 'Purchasing' 
				WHEN 5 THEN 'Inventory' 
				WHEN 6 THEN 'Payroll' 
				ELSE 'Project'
			END AS Series,
			GLO.ORMSTRID AS VendorId,
			(GLO.DEBITAMT * -1) + GLO.CRDTAMNT AS Amount,
			GPCustom.dbo.FindProNumber(GLO.REFRENCE) AS Pro,
			FIS.GP_Period,
			GLO.DataSource
	FROM	@tblBkpData GLO
			INNER JOIN DYNAMICS.dbo.View_FiscalPeriod FIS ON GLO.TRXDATE BETWEEN FIS.StartDate AND FIS.EndDate
	) GPD
	LEFT JOIN IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FSI ON GPD.Pro = FSI.InvoiceNumber AND ABS(GPD.Amount) = FSI.ChargeAmount1 AND FSI.RecordType = 'VND' AND GPD.Pro <> '' AND GPD.VendorId = '' AND GPD.GPSeries = 2
	LEFT JOIN GLSO.dbo.PM00200 VND ON ISNULL(FSI.RecordCode, GPD.VendorId) = VND.VENDORID

PRINT 'SELECT DATA'
INSERT INTO GP_AccruedLiabilities
SELECT	DATA.*,
		Counter = (SELECT COUNT(TEMP.Pro) FROM @tblData TEMP WHERE TEMP.Pro = DATA.Pro AND TEMP.VendorId = DATA.VendorId AND ABS(TEMP.Amount) = ABS(DATA.Amount))
FROM	@tblData DATA

SELECT	*
FROM	GP_AccruedLiabilities
WHERE	Account = @GLAccount
		AND TransDate BETWEEN DATEADD(dd, -365, @AsOfDate) AND @AsOfDate
ORDER BY 
		Pro,
		TransDate,
		JournalEntry