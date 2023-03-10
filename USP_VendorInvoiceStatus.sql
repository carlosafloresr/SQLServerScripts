USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorInvoiceStatus]    Script Date: 9/23/2021 10:29:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorInvoiceStatus 'GLSO', '07/15/2017', '07/30/2017', '636', '02352915', Null, Null
EXECUTE USP_VendorInvoiceStatus 'GLSO', '01/15/2017', '02/01/2018', Null, '10001559'
EXECUTE USP_VendorInvoiceStatus 'GLSO', '08/01/2017', '09/22/2017', Null, Null, Null, '0010384'
EXECUTE USP_VendorInvoiceStatus 'GLSO', '08/01/2017', '09/06/2017', '97-101718'
EXECUTE USP_VendorInvoiceStatus 'GLSO', '01/01/2021', '01/25/2021', Null, '02-267027'
EXECUTE USP_VendorInvoiceStatus @Company, @DateIni, @DateEnd, @VendorId, @Invoice, @Container, @Reference
*/
ALTER PROCEDURE [dbo].[USP_VendorInvoiceStatus]
		@Company		Varchar(5),
		@DateIni		Date,
		@DateEnd		Date,
		@VendorId		Varchar(20) = Null,
		@Invoice		Varchar(25) = Null,
		@Container		Varchar(15) = Null,
		@Reference		Varchar(25) = Null
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@Status			Varchar(30),
		@InvDate		Date,
		@Amount			Numeric(10,2),
		@Balance		Numeric(10,2),
		@DataStatus		Varchar(50),
		@RowCount		Int = 0,
		@Location		Char(1),
		@OpsSystem		Varchar(15),
		@OpCompanyId	Varchar(3),
		@CompanyNum		Varchar(2)

DECLARE @tblData		Table
		(Company		Varchar(10),
		VendorId		Varchar(20),
		VendorName		Varchar(75),
		Invoice			Varchar(35) Null,
		InvDate			Date Null,
		Amount			Numeric(10,2) Null,
		Balance			Numeric(10,2) Null,
		Container		Varchar(25) Null,
		Reference		Varchar(50) Null,
		DataStatus		Varchar(70) Null,
		KeyField		Varchar(70),
		DocImage		Varchar(250) Null,
		DataSource		Varchar(50) Null)

DECLARE @tblDataTmp		Table
		(Company		Varchar(10),
		VendorId		Varchar(20),
		VendorName		Varchar(75),
		Invoice			Varchar(35) Null,
		InvDate			Date Null,
		Amount			Numeric(10,2) Null,
		Balance			Numeric(10,2) Null,
		Container		Varchar(25) Null,
		Reference		Varchar(50) Null,
		DataStatus		Varchar(70) Null,
		KeyField		Varchar(70),
		DocImage		Varchar(250) Null,
		DataSource		Varchar(50) Null)

DECLARE	@tblFind		Table
		(Invoice		Varchar(35),
		InvDate			Date,
		Amount			Numeric(10,2),
		Balance			Numeric(10,2),
		Location		Char(1))

SET @Company = RTRIM(@Company)
SET @CompanyNum = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)

SELECT	@OpsSystem		= OperativeSystem,
		@OpCompanyId	= OperativeCompanyId
FROM	Companies 
WHERE	CompanyId = @Company
		OR CompanyAlias = @Company

IF @VendorId = ''
	SET @VendorId = Null

IF @Invoice = ''
	SET @Invoice = Null

IF @Container = ''
	SET @Container = Null

IF @Reference= ''
	SET @Reference = Null

-- Search first in Great Plains
SET @Query = N'SELECT ''' + @Company + ''' AS Company,
				VENDORID,
				GPCustom.dbo.GetVendorName(''' + @Company + ''', VENDORID) AS VendorName,
				DOCNUMBR,
				DOCDATE,
				DOCAMNT,
				CURTRXAM,
				'''',
				TRXDSCRN,
				Null,
				''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
				Null,
				''Great Plains'' AS DataSource
		FROM	' + @Company + '.dbo.PM20000
		WHERE	DocDate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
				AND DOCTYPE < 6 '

IF @VendorId IS NOT Null
	SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

IF @Invoice IS NOT Null
	SET @Query = @Query + ' AND DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

IF @Reference IS NOT Null
	SET @Query = @Query + ' AND TRXDSCRN LIKE ''' + '%' + RTRIM(@Reference) + '%' + ''''

SET @Query = @Query + ' UNION 
		SELECT ''' + @Company + ''' AS Company,
			VENDORID,
			GPCustom.dbo.GetVendorName(''' + @Company + ''', VENDORID) AS VendorName,
			DOCNUMBR,
			DOCDATE,
			DOCAMNT,
			CURTRXAM,
			'''',
			TRXDSCRN,
			Null,
			''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
			Null,
			''Great Plains'' AS DataSource
		FROM	' + @Company + '.dbo.PM30200
		WHERE	DocDate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
			AND DOCTYPE < 6'
		
IF @VendorId IS NOT Null
	SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

IF @Invoice IS NOT Null
	SET @Query = @Query + ' AND DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

IF @Reference IS NOT Null
	SET @Query = @Query + ' AND TRXDSCRN LIKE ''' + '%' + RTRIM(@Reference) + '%' + ''''

INSERT INTO @tblData
EXECUTE(@Query)

SET @RowCount = (SELECT COUNT(*) FROM @tblData)

/*
=================================================================
SCRIPT DISABLE BY CARLOS A. FLORES ON 01/26/2021
REASON: A SWS SEARCH HAS BEEN ADDED TO THE STORED PROCEDURE
=================================================================
*/
--IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under the Great Plains check FSI Integration
--BEGIN
--	INSERT INTO @tblData
--	SELECT	DISTINCT Company,
--			RecordCode AS VendorId,
--			dbo.GetVendorName(Company, RecordCode) AS VendorName,
--			CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END AS Invoice,
--			ReceivedOn AS Date,		
--			ChargeAmount1 AS Amount,
--			ChargeAmount1 AS Balance,
--			Equipment,
--			InvoiceNumber AS Reference,
--			'In FSI' AS DataStatus,
--			RTRIM(Company) + '~' + RTRIM(RecordCode) + '~' + RTRIM(CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END) + '~' AS KeyField,
--			Null,
--			'FSI' AS DataSource
--	FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Vendors
--	WHERE	Company = @Company
--			AND WeekEndDate BETWEEN @DateIni AND @DateEnd
--			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND RecordCode = @VendorId))
--			AND (@Invoice IS Null OR (@Invoice IS NOT Null AND VendorDocument LIKE '%' + @Invoice + '%'))
--			AND (@Container IS Null OR (@Container IS NOT Null AND Equipment LIKE '%' + @Container + '%'))
--			AND (@Reference IS Null OR (@Reference IS NOT Null AND InvoiceNumber LIKE '%' + @Reference + '%'))
--END

--SET @RowCount = (SELECT COUNT(*) FROM @tblData)

IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under the FSI checks under AP integrations
BEGIN
	SET @Query = N'SELECT DISTINCT Company,
		VENDORID,
		CASE WHEN VendorName = '''' THEN GPCustom.dbo.GetVendorName(Company, VENDORID) ELSE VendorName END AS VendorName,
		DOCNUMBR,
		DOCDATE,
		DOCAMNT,
		0,
		Container,
		ProNum,
		''In '' + Integration,
		RTRIM(Company) + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR) + ''~'',
		Null,
		''Integration_AP'' AS DataSource
FROM	IntegrationsDB.Integrations.dbo.Integrations_AP
WHERE	Company = ''' + @Company + '''
		AND DOCDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' '

	IF @VendorId IS NOT Null
		SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

	IF @Invoice IS NOT Null
		SET @Query = @Query + ' AND DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

	IF @Container IS NOT Null
		SET @Query = @Query + ' AND Container = ''' + RTRIM(@Container) + ''''

	IF @Reference IS NOT Null
		SET @Query = @Query + ' AND ProNum = ''' + RTRIM(@Reference) + ''''
	
	INSERT INTO @tblData
	EXECUTE(@Query)
END

SET @RowCount = (SELECT COUNT(*) FROM @tblData)

IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under Great Plains, FSI and AP integrations
BEGIN
	SET @Query = N'SELECT '''' AS Company,
		pay.vn_code,
		'''' AS VendorName,
		pay.vendor_invoice,
		pay.adate,
		pay.amount,
		0 AS balance,
		inv.eq_code AS Container,
		inv.BTRef as reference,
		'''' AS DataStatus,
		'''' AS KeyField,
		Null as DocImage,
		'''' AS DataSource
FROM	TRK.InvVnPay pay, TRK.Invoice inv 
WHERE	pay.inv_code = inv.code 
		AND pay.cmpy_no = ' + @CompanyNum + '
		AND pay.adate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
		AND pay.vendor_invoice <> '''' '

	IF @VendorId IS NOT Null
		SET @Query = @Query + ' AND pay.vn_code = ''' + RTRIM(@VendorId) + ''''

	IF @Invoice IS NOT Null
		SET @Query = @Query + ' AND pay.vendor_invoice = ''' + RTRIM(@Invoice) + ''''
	
	INSERT INTO @tblData
	EXECUTE USP_QuerySWS_ReportData @Query

	UPDATE	@tblData
	SET		Company = @Company,
			DataStatus = 'Unposted in SWS',
			DataSource = 'SWS',
			VendorName = GPCustom.dbo.GetVendorName(@Company, VendorId)
			--KeyField = @Company + '~' + RTRIM(VendorId) + '~' + RTRIM(Invoice)
	WHERE	DataStatus = ''
END

DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Company,
		VendorId,
		Invoice,
		DataStatus
FROM	@tblData

OPEN Transaction_Companies 
FETCH FROM Transaction_Companies INTO @Company, @VendorId, @Invoice, @DataStatus

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = 'SELECT DocNumbr, DocDate, DocAmnt, CurTrxAm, ''W'' AS Location FROM ' + RTRIM(@Company) + '.dbo.PM10000 WHERE VendorId = ''' + RTRIM(@VendorId) + ''' AND DocNumbr = ''' + RTRIM(@Invoice) + ''' '
	SET @Query = @Query + 'UNION SELECT DocNumbr, DocDate, DocAmnt, CurTrxAm, ''O'' AS Location FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE VendorId = ''' + RTRIM(@VendorId) + ''' AND DocNumbr = ''' + RTRIM(@Invoice) + ''' '
	SET @Query = @Query + 'UNION SELECT DocNumbr, DocDate, DocAmnt, CurTrxAm, ''H'' AS Location FROM ' + RTRIM(@Company) + '.dbo.PM30200 WHERE VendorId = ''' + RTRIM(@VendorId) + ''' AND DocNumbr = ''' + RTRIM(@Invoice) + ''''

	DELETE @tblFind

	INSERT INTO @tblFind
	EXECUTE(@Query)

	IF @@ROWCOUNT = 0
		SET @Status = 'GP Not Found' + ISNULL(' (' + @DataStatus + ')','')
	ELSE
	BEGIN
		SELECT	@Amount		= Amount,
				@Balance	= Balance,
				@InvDate	= InvDate,
				@Location	= Location
		FROM	@tblFind

		IF @Location = 'W'
			SET	@Status = 'GP Unposted'
		ELSE
			SET	@Status = CASE WHEN @Balance = 0 THEN 'GP Paid' WHEN @Amount > @Balance AND @Balance > 0 THEN 'GP Partially Paid' ELSE 'GP Unpaid' END
	END

	UPDATE	@tblData
	SET		Balance		= ISNULL(@Balance,0),
			DataStatus	= @Status,
			InvDate		= ISNULL(@InvDate,InvDate)
	WHERE	Company = @Company
			AND VendorId = @VendorId
			AND Invoice = @Invoice

	FETCH FROM Transaction_Companies INTO @Company, @VendorId, @Invoice, @DataStatus
END

CLOSE Transaction_Companies
DEALLOCATE Transaction_Companies

SELECT	VendorId,
		VendorName,
		Invoice,
		InvDate,
		Amount,
		Balance,
		Container,
		Reference,
		DataStatus,
		CASE WHEN DataStatus = 'GP Unpaid' THEN '' ELSE KeyField END AS KeyField,
		DataSource,
		'' AS GroupId,
		0 AS HeaderId,
		0 AS DetailId,
		0 AS Inv_Difference
FROM	@tblData
ORDER BY
		VendorId,
		InvDate,
		Invoice