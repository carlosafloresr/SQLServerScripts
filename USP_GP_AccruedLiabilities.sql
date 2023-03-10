USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GP_AccruedLiabilities]    Script Date: 2/20/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GP_AccruedLiabilities 'GLSO', '0-00-2105', '03/12/2020'
EXECUTE USP_GP_AccruedLiabilities 'GLSO', '0-01-1866', '02/12/2020'
EXECUTE USP_GP_AccruedLiabilities 'GLSO', '0-88-1866', '02/12/2020'
EXECUTE USP_GP_AccruedLiabilities 'GLSO', '0-99-1866', '02/26/2020' --, '97-110054'
*/
ALTER PROCEDURE [dbo].[USP_GP_AccruedLiabilities]
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@AsOfDate		Date,
		@ProNumber		Varchar(15) = Null
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX)

SET @Query = N'SELECT ''' + @Company + ''' AS Company,
		GPD.TransDate,
		GPD.Account,
		GPD.JournalEntry,
		GPD.SourceDocument,
		GPD.OrigAuditTrail,
		GPD.DistReference,
		GPD.Series,
		ISNULL(LEFT(UPPER(RTRIM(VND.VENDNAME)), 100), '''') AS Vendor,
		ISNULL(FSI.RecordCode, GPD.VendorId) AS VendorId,
		GPD.Amount,
		GPD.Pro,
		GPD.GP_Period,
		GPD.DataSource
INTO	##tmpGP_Data
FROM	(
		SELECT	CAST(GLO.TRXDATE AS Date) AS TransDate,
				RTRIM(GL5.ACTNUMST) AS Account,
				GLO.JRNENTRY AS JournalEntry,
				GLO.ORTRXSRC AS SourceDocument,
				RTRIM(GLO.REFRENCE) AS OrigAuditTrail,
				CASE WHEN GLO.SERIES = 4 THEN GLO.ORDOCNUM ELSE
				RTRIM(CASE WHEN GPCustom.dbo.AT(''|'', GLO.REFRENCE, 1) > 0 THEN SUBSTRING(GLO.REFRENCE, GPCustom.dbo.AT(''|'', GLO.REFRENCE, 1) + 1, 25) ELSE GLO.REFRENCE END) END AS DistReference,
				GLO.SERIES AS GPSeries,
				CASE GLO.SERIES 
					WHEN 1 THEN ''ALL'' 
					WHEN 2 THEN ''Financial'' 
					WHEN 3 THEN ''Sales'' 
					WHEN 4 THEN ''Purchasing'' 
					WHEN 5 THEN ''Inventory'' 
					WHEN 6 THEN ''Payroll'' 
					ELSE ''Project''
				END AS Series,
				GLO.ORMSTRID AS VendorId,
				(GLO.DEBITAMT * -1) + GLO.CRDTAMNT AS Amount,
				GPCustom.dbo.FindProNumber(GLO.REFRENCE) AS Pro,
				FIS.GP_Period,
				''OPEN'' AS DataSource
		FROM	' + @Company + '.dbo.GL20000 GLO
				INNER JOIN ' + @Company + '.dbo.GL00105 GL5 ON GLO.ACTINDX = GL5.ACTINDX
				INNER JOIN DYNAMICS.dbo.View_FiscalPeriod FIS ON GLO.TRXDATE BETWEEN FIS.StartDate AND FIS.EndDate
				LEFT JOIN GPCustom.dbo.GL_ProNumbers GPN ON GLO.JRNENTRY = GPN.JRNENTRY AND GLO.REFRENCE = GPN.Reference AND GPN.Company = ''' + @Company + ''' 
		WHERE	GL5.ACTNUMST = ''' + @GLAccount + '''
				AND GLO.TRXDATE BETWEEN DATEADD(dd, -800, ''' + CAST(@AsOfDate AS Varchar) + ''') AND ''' + CAST(@AsOfDate AS Varchar) + '''
		UNION
		SELECT	CAST(GLO.TRXDATE AS Date) AS TransDate,
				RTRIM(GL5.ACTNUMST) AS Account,
				GLO.JRNENTRY AS JournalEntry,
				GLO.ORTRXSRC AS SourceDocument,
				RTRIM(GLO.REFRENCE) AS OrigAuditTrail,
				CASE WHEN GLO.SERIES = 4 THEN GLO.ORDOCNUM ELSE
				RTRIM(CASE WHEN GPCustom.dbo.AT(''|'', GLO.REFRENCE, 1) > 0 THEN SUBSTRING(GLO.REFRENCE, GPCustom.dbo.AT(''|'', GLO.REFRENCE, 1) + 1, 25) ELSE GLO.REFRENCE END) END AS DistReference,
				GLO.SERIES AS GPSeries,
				CASE GLO.SERIES 
					WHEN 1 THEN ''ALL'' 
					WHEN 2 THEN ''Financial'' 
					WHEN 3 THEN ''Sales''
					WHEN 4 THEN ''Purchasing'' 
					WHEN 5 THEN ''Inventory'' 
					WHEN 6 THEN ''Payroll'' 
					ELSE ''Project''
				END AS Series,
				GLO.ORMSTRID AS VendorId,
				(GLO.DEBITAMT * -1) + GLO.CRDTAMNT AS Amount,
				ISNULL(GPN.ProNumber, GPCustom.dbo.FindProNumber(GLO.REFRENCE)) AS Pro,
				FIS.GP_Period,
				''HISTORY'' AS DataSource
		FROM	' + @Company + '.dbo.GL30000 GLO
				INNER JOIN ' + @Company + '.dbo.GL00105 GL5 ON GLO.ACTINDX = GL5.ACTINDX
				INNER JOIN DYNAMICS.dbo.View_FiscalPeriod FIS ON GLO.TRXDATE BETWEEN FIS.StartDate AND FIS.EndDate
				LEFT JOIN GPCustom.dbo.GL_ProNumbers GPN ON GLO.JRNENTRY = GPN.JRNENTRY AND GLO.REFRENCE = GPN.Reference AND GPN.Company = ''' + @Company + ''' 
		WHERE	GL5.ACTNUMST = ''' + @GLAccount + '''
				AND GLO.TRXDATE BETWEEN DATEADD(dd, -800, ''' + CAST(@AsOfDate AS Varchar) + ''') AND ''' + CAST(@AsOfDate AS Varchar) + '''
		) GPD 
		LEFT JOIN IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FSI ON GPD.Pro = FSI.InvoiceNumber AND ABS(GPD.Amount) = FSI.ChargeAmount1 AND FSI.RecordType = ''VND'' AND GPD.Pro <> '''' AND GPD.VendorId = '''' AND GPD.GPSeries = 2
		LEFT JOIN ' + @Company + '.dbo.PM00200 VND ON ISNULL(FSI.RecordCode, GPD.VendorId) = VND.VENDORID '

IF @ProNumber IS NOT null
SET @Query = @Query + 'WHERE GPD.Pro = ''' + @ProNumber + ''' '

--PRINT @Query
EXECUTE(@Query)

--INSERT INTO GPCustom.dbo.GL_ProNumbers
--SELECT	*
--FROM	(
--		SELECT	Company
--				,JournalEntry 
--				,Pro
--				,OrigAuditTrail
--		FROM	##tmpGP_Data
--		WHERE	JournalEntry NOT IN (SELECT JRNENTRY FROM GL_ProNumbers)
--		) DATA
--WHERE	Pro IN (SELECT InvoiceNumber FROM IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails)

SELECT	DATA.*,
		Counter = (SELECT COUNT(TEMP.Pro) FROM ##tmpGP_Data TEMP WHERE TEMP.Pro = DATA.Pro AND TEMP.VendorId = DATA.VendorId AND ABS(TEMP.Amount) = ABS(DATA.Amount))
FROM	##tmpGP_Data DATA
ORDER BY 
		Pro,
		TransDate,
		JournalEntry

DROP TABLE ##tmpGP_Data