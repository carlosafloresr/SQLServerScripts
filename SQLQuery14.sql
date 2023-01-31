USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorInvoiceStatus]    Script Date: 9/21/2017 2:33:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorInvoiceStatus 'GLSO', '07/15/2017', '07/30/2017', '636', '02352915', Null, Null
EXECUTE USP_VendorInvoiceStatus 'GLSO', '07/15/2017', '07/30/2017', '636'
EXECUTE USP_VendorInvoiceStatus 'GSA', '08/01/2017', '09/06/2017', '167'
EXECUTE USP_VendorInvoiceStatus 'GLSO', '08/01/2017', '09/06/2017', 'USCBP'
EXECUTE USP_VendorInvoiceStatus 'NDS', '08/01/2017', '08/31/2017', Null, '53-111459'
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
		@OpCompanyId	Varchar(3)

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
		DocImage		Varchar(250) Null)

DECLARE	@tblFind		Table
		(Invoice		Varchar(35),
		InvDate			Date,
		Amount			Numeric(10,2),
		Balance			Numeric(10,2),
		Location		Char(1))

SET @Company = RTRIM(@Company)

SELECT	@OpsSystem		= OperativeSystem,
		@OpCompanyId	= OperativeCompanyId
FROM	Companies 
WHERE	CompanyId = @Company

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
				Null
		FROM	' + @Company + '.dbo.PM20000
		WHERE	DocDate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
				AND DOCTYPE < 6 '

IF @VendorId IS NOT Null
	SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

IF @Invoice IS NOT Null
	SET @Query = @Query + ' AND DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

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
			Null
		FROM	' + @Company + '.dbo.PM30200
		WHERE	DocDate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
			AND DOCTYPE < 6'
		
IF @VendorId IS NOT Null
	SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

IF @Invoice IS NOT Null
	SET @Query = @Query + ' AND DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

	INSERT INTO @tblData
	EXECUTE(@Query)

SET @RowCount = (SELECT COUNT(*) FROM @tblData)

IF @RowCount = 0 -- If not found under the Great Plains check FSI Integration
BEGIN
	INSERT INTO @tblData
	SELECT	DISTINCT Company,
			RecordCode AS VendorId,
			dbo.GetVendorName(Company, RecordCode) AS VendorName,
			CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END AS Invoice,
			ReceivedOn AS Date,		
			ChargeAmount1 AS Amount,
			ChargeAmount1 AS Balance,
			Equipment,
			InvoiceNumber AS Reference,
			'In FSI' AS DataStatus,
			RTRIM(Company) + '~' + RTRIM(RecordCode) + '~' + RTRIM(CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END) + '~' AS KeyField,
			Null
	FROM	ILSINT02.Integrations.dbo.View_Integration_FSI_Vendors
	WHERE	Company = @Company
			AND WeekEndDate BETWEEN @DateIni AND @DateEnd
			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND RecordCode = @VendorId))
			AND (@Invoice IS Null OR (@Invoice IS NOT Null AND VendorDocument LIKE '%' + @Invoice + '%'))
			AND (@Container IS Null OR (@Container IS NOT Null AND Equipment LIKE '%' + @Container + '%'))
			AND (@Reference IS Null OR (@Reference IS NOT Null AND InvoiceNumber LIKE '%' + @Reference + '%'))
END

SET @RowCount = (SELECT COUNT(*) FROM @tblData)

IF @RowCount = 0 -- If not found under the FSI checks under AP integrations
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
		Null
FROM	ILSINT02.Integrations.dbo.Integrations_AP
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
ELSE
	PRINT 'On FSI'

SET @RowCount = (SELECT COUNT(*) FROM @tblData)

IF @RowCount = 0 AND @OpsSystem = 'ONEVIEW' -- If not found under Great Plains, FSI and AP integrations
BEGIN
	SET @Query = N'SELECT ''' + @Company + ''' AS Company,
		CLN.External_Id AS VendorId, 
		'''' AS VendorName,
		HDR.BL_Number, 
		HDR.Inv_date, 
		HDR.Inv_total, 
		HDR.Inv_balance, 
		'''',
		HDR.Inh_invoice_id,
		''In OneView'' AS DataStatus,
		''' + @Company + ''' + ''~'' + RTRIM(HDR.Vendor) + ''~'' + RTRIM(HDR.BL_Number),
		Null
FROM	AP_Hdr HDR
		INNER JOIN Client CLN ON HDR.Vendor = CLN.AcctG_Id
WHERE	HDR.Div_Code = ''' + @OpCompanyId + ''' 
		AND HDR.Inv_date BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''''

	IF @VendorId IS NOT Null
		SET @Query = @Query + ' AND CLN.External_Id = ''' + RTRIM(@VendorId) + ''''

	IF @Invoice IS NOT Null
		SET @Query = @Query + ' AND HDR.BL_Number = ''' + RTRIM(@Invoice) + ''''
	
	INSERT INTO @tblData
	EXECUTE USP_QueryPervasive @Query

	UPDATE	@tblData
	SET		VendorId	= CASE WHEN @OpCompanyId = 20 THEN SUBSTRING(VendorId, 2, 15) ELSE VendorId END

	UPDATE	@tblData
	SET		VendorName	= GPCustom.dbo.GetVendorName(@Company, VendorId)
END
ELSE
	PRINT 'On Integrations_AP'

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
			SET	@Status = CASE WHEN @Balance = 0 THEN 'GP Paid' WHEN @Amount > @Balance AND @Balance > 0 THEN 'GP Partialy Paid' ELSE 'GP Unpaid' END
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
		CASE WHEN DataStatus = 'GP Unpaid' THEN '' ELSE KeyField END AS KeyField
FROM	@tblData
ORDER BY
		VendorId,
		InvDate,
		Invoice