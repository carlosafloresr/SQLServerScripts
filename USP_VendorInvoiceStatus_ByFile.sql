USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorInvoiceStatus_ByFile]    Script Date: 1/26/2021 1:21:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorInvoiceStatus_ByFile 79
EXECUTE USP_VendorInvoiceStatus_ByFile 148
*/
ALTER PROCEDURE [dbo].[USP_VendorInvoiceStatus_ByFile]
		@HeaderId		Int = 1
AS
SET NOCOUNT ON

DECLARE	@DetailId		Int,
		@Company		Varchar(5),
		@CompanyNo		Int,
		@DateIni		Date,
		@DateEnd		Date,
		@VendorId		Varchar(20),
		@Invoice		Varchar(25),
		@Container		Varchar(15),
		@Reference		Varchar(25),
		@Query			Varchar(MAX),
		@Status			Varchar(30),
		@InvDate		Date,
		@Amount			Numeric(10,2),
		@Balance		Numeric(10,2),
		@DataStatus		Varchar(50),
		@RowCount		Int = 0,
		@Location		Char(1),
		@OpsSystem		Varchar(15),
		@OpCompanyId	Varchar(3),
		@FileContainer	Varchar(30)

DECLARE @tblData		Table
		(VendorId		Varchar(20) Null,
		VendorName		Varchar(75) Null,
		Invoice			Varchar(35) Null,
		InvDate			Date Null,
		Amount			Numeric(10,2) Null,
		Balance			Numeric(10,2) Null,
		Container		Varchar(25) Null,
		Reference		Varchar(50) Null,
		DataStatus		Varchar(70) Null,
		KeyField		Varchar(70),
		DataSource		Varchar(50) Null)

DECLARE @tblDataTmp		Table
		(VendorId		Varchar(20) Null,
		VendorName		Varchar(75) Null,
		Invoice			Varchar(35) Null,
		InvDate			Date Null,
		Amount			Numeric(10,2) Null,
		Balance			Numeric(10,2) Null,
		Container		Varchar(25) Null,
		Reference		Varchar(50) Null,
		DataStatus		Varchar(70) Null,
		KeyField		Varchar(70),
		DataSource		Varchar(50) Null)

DECLARE	@tblFind		Table
		(VendorId		Varchar(20) Null,
		Invoice			Varchar(35),
		InvDate			Date,
		Amount			Numeric(10,2),
		Balance			Numeric(10,2),
		Location		Char(1))

DECLARE	@tblResult Table (
		HeaderId		int NOT NULL,
		DetailId		int NOT NULL,
		Company			varchar(5) NOT NULL,
		VendorId		varchar(20) NULL,
		VendorName		varchar(50) NULL,
		FileName		varchar(50) NOT NULL,
		UploadedOn		datetime NOT NULL,
		File_Invoice	varchar(30) NULL,
		File_InvDate	date NULL,
		File_Container	varchar(50) NULL,
		File_Reference	varchar(50) NULL,
		File_Amount		numeric(12, 2) NOT NULL,
		Invoice			varchar(35) NULL,
		InvDate			date NULL,
		Amount			numeric(12, 2) NULL,
		Balance			numeric(12, 2) NULL,
		Inv_Difference	numeric(12, 2) NOT NULL,
		Container		varchar(25) NULL,
		Reference		varchar(50) NULL,
		DataStatus		varchar(70) NULL,
		KeyField		varchar(70) NULL,
		DataSource		varchar(50) NULL,
		DocType			varchar(12) NULL,
		DocumentNumber	varchar(30) NULL,
		Applied_Paid	numeric(10,2) NULL,
		PostingDate		date NULL)

DELETE	VendorInvoiceStatusResult
WHERE	HeaderId = @HeaderId

SET @CompanyNo = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)

INSERT INTO @tblResult
SELECT	HDR.VendorInvoiceStatusHdrId AS HeaderId
		,DET.VendorInvoiceStatusDetId AS DetailId
		,HDR.Company
		,HDR.VendorId
		,HDR.VendorName
		,HDR.FileName
		,HDR.UploadedOn
		,RTRIM(REPLACE(DET.InvoiceNumber, '?', '')) AS File_Invoice
		,DET.InvoiceDate AS File_InvDate
		,DET.ContainerNumber AS File_Container
		,DET.Reference AS File_Reference
		,DET.Amount AS File_Amount
		,RTRIM(REPLACE(TB1.Invoice, '?', '')) AS Invoice
		,TB1.InvDate
		,TB1.Amount
		,TB1.Balance
		,0.00 AS Inv_Difference
		,TB1.Container
		,TB1.Reference
		,TB1.DataStatus
		,TB1.KeyField
		,TB1.DataSource
		,Null
		,Null
		,Null
		,Null
FROM	VendorInvoiceStatusHdr HDR
		INNER JOIN VendorInvoiceStatusDet DET ON HDR.VendorInvoiceStatusHdrId = DET.VendorInvoiceStatusHdrId
		LEFT JOIN @tblData TB1 ON HDR.VendorId = TB1.VendorId
WHERE	HDR.VendorInvoiceStatusHdrId = @HeaderId

SELECT	*
INTO	#tmpResults
FROM	@tblResult
WHERE	HeaderId = -1

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		File_Invoice,
		DetailId,
		VendorId,
		File_Container
FROM	@tblResult

OPEN curTransactions 
FETCH FROM curTransactions INTO @Company, @Invoice, @DetailId, @VendorId, @FileContainer

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ' + CASE WHEN @VendorId IS Null THEN 'VENDORID' ELSE '' + RTRIM(@VendorId) + '' END + ',
					GPCustom.dbo.GetVendorName(''' + @Company + ''', ' + CASE WHEN @VendorId IS Null THEN 'VENDORID' ELSE '' + RTRIM(@VendorId) + '' END + ') AS VendorName,
					RTRIM(DOCNUMBR) AS DOCNUMBR,
					DOCDATE,
					DOCAMNT,
					DOCAMNT,
					'''',
					TRXDSCRN,
					''GP Unposted'' AS DataStatus,
					''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
					''Great Plains'' AS DataSource
			FROM	' + @Company + '.dbo.PM10000
			WHERE	(DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

	IF LEN(RTRIM(@Invoice)) > 13
		SET @Query = @Query + ' OR DOCNUMBR LIKE ''' + LEFT(RTRIM(@Invoice), 13) + '%'''
	
	IF @FileContainer IS NOT Null AND @FileContainer <> ''
		SET @Query = @Query + ' OR TRXDSCRN LIKE ''' + '%' + RTRIM(@FileContainer) + '%'')'
	ELSE
		SET @Query = @Query + ')'

	IF @VendorId IS NOT Null
		SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

	SET @Query = @Query + ' UNION 
			SELECT ' + CASE WHEN @VendorId IS Null THEN 'VENDORID' ELSE '' + RTRIM(@VendorId) + '' END + ',
				GPCustom.dbo.GetVendorName(''' + @Company + ''', ' + CASE WHEN @VendorId IS Null THEN 'VENDORID' ELSE '' + RTRIM(@VendorId) + '' END + ') AS VendorName,
				RTRIM(DOCNUMBR) AS DOCNUMBR,
					DOCDATE,
					DOCAMNT,
					CURTRXAM,
					'''',
					TRXDSCRN,
					CASE WHEN CURTRXAM = 0 THEN ''GP Paid'' WHEN DOCAMNT > CURTRXAM AND CURTRXAM > 0 THEN ''GP Partialy Paid'' ELSE ''GP Unpaid'' END AS DataStatus,
					''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
					''Great Plains'' AS DataSource
			FROM	' + @Company + '.dbo.PM20000
			WHERE	(DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

	IF LEN(RTRIM(@Invoice)) > 13
		SET @Query = @Query + ' OR DOCNUMBR LIKE ''' + LEFT(RTRIM(@Invoice), 13) + '%'')'
	ELSE
		
	IF @FileContainer IS NOT Null AND @FileContainer <> ''
		SET @Query = @Query + ' OR TRXDSCRN LIKE ''' + '%' + RTRIM(@FileContainer) + '%'')'
	ELSE
		SET @Query = @Query + ')'

	IF @VendorId IS NOT Null
		SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

	SET @Query = @Query + ' UNION 
			SELECT ' + CASE WHEN @VendorId IS Null THEN 'VENDORID' ELSE '' + RTRIM(@VendorId) + '' END + ',
				GPCustom.dbo.GetVendorName(''' + @Company + ''', ' + CASE WHEN @VendorId IS Null THEN 'VENDORID' ELSE '' + RTRIM(@VendorId) + '' END + ') AS VendorName,
				RTRIM(DOCNUMBR) AS DOCNUMBR,
					DOCDATE,
					DOCAMNT,
					CURTRXAM,
					'''',
					TRXDSCRN,
					CASE WHEN CURTRXAM = 0 THEN ''GP Paid'' WHEN DOCAMNT > CURTRXAM AND CURTRXAM > 0 THEN ''GP Partialy Paid'' ELSE ''GP Unpaid'' END AS DataStatus,
					''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
					''Great Plains'' AS DataSource
			FROM	' + @Company + '.dbo.PM30200
			WHERE	(DOCNUMBR = ''' + RTRIM(@Invoice) + ''''

	IF LEN(RTRIM(@Invoice)) > 13
		SET @Query = @Query + ' OR DOCNUMBR LIKE ''' + LEFT(RTRIM(@Invoice), 13) + '%'')'
	
	IF @FileContainer IS NOT Null AND @FileContainer <> ''
		SET @Query = @Query + ' OR TRXDSCRN LIKE ''' + '%' + RTRIM(@FileContainer) + '%'')'
	ELSE
		SET @Query = @Query + ')'

	IF @VendorId IS NOT Null
		SET @Query = @Query + ' AND VendorId = ''' + RTRIM(@VendorId) + ''''

	INSERT INTO @tblData
	EXECUTE(@Query)
	
	FETCH FROM curTransactions INTO @Company, @Invoice, @DetailId, @VendorId, @FileContainer
END

CLOSE curTransactions
DEALLOCATE curTransactions

UPDATE	@tblResult
SET		VendorId	= DATA.VendorId,
		VendorName	= DATA.VendorName,
		InvDate		= DATA.InvDate,
		Amount		= DATA.Amount,
		Balance		= DATA.Balance,
		Reference	= DATA.Reference,
		DataStatus	= DATA.DataStatus,
		KeyField	= DATA.KeyField,
		DataSource	= DATA.DataSource,
		Invoice		= DATA.Invoice
FROM	@tblData DATA
WHERE	File_Invoice = DATA.Invoice
		OR DATA.Reference LIKE '%' + RTRIM(File_Container) + '%'

INSERT INTO #tmpResults
SELECT	HDR.VendorInvoiceStatusHdrId AS HeaderId
		,DET.VendorInvoiceStatusDetId AS DetailId
		,HDR.Company
		,ISNULL(HDR.VendorId,TB1.VendorId) AS VendorId
		,GPCustom.dbo.GetVendorName(HDR.Company, TB1.VENDORID) AS VendorName
		,HDR.FileName
		,HDR.UploadedOn
		,REPLACE(DET.InvoiceNumber, '?', '') AS File_Invoice
		,DET.InvoiceDate AS File_InvDate
		,DET.ContainerNumber AS File_Container
		,DET.Reference AS File_Reference
		,DET.Amount AS File_Amount
		,REPLACE(ISNULL(TB1.Invoice, DET.InvoiceNumber), '?', '') AS Invoice
		,TB1.InvDate
		,TB1.Amount
		,TB1.Balance
		,DET.Amount - ISNULL(TB1.Amount, 0) AS Inv_Difference
		,TB1.Container
		,TB1.Reference
		,ISNULL(TB1.DataStatus, 'Not Found') AS DataStatus
		,TB1.KeyField
		,TB1.DataSource
		,Null
		,Null
		,Null
		,Null
FROM	VendorInvoiceStatusHdr HDR
		INNER JOIN VendorInvoiceStatusDet DET ON HDR.VendorInvoiceStatusHdrId = DET.VendorInvoiceStatusHdrId
		INNER JOIN @tblData TB1 ON (HDR.VendorId = TB1.VendorId OR DET.InvoiceNumber = TB1.Invoice)
WHERE	HDR.VendorInvoiceStatusHdrId = @HeaderId
		AND DET.VendorInvoiceStatusDetId = @DetailId

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		DATEADD(dd, -180, File_InvDate),
		GETDATE(),
		VendorId,
		CASE WHEN File_Invoice = '' THEN Null ELSE RTRIM(File_Invoice) END,
		CASE WHEN File_Container = '' THEN Null ELSE File_Container END,
		CASE WHEN File_Reference = '' THEN Null ELSE (CASE WHEN File_Invoice = '' THEN File_Reference ELSE Null END) END,
		DetailId
FROM	@tblResult
WHERE	DataSource IS Null

OPEN curTransactions 
FETCH FROM curTransactions INTO @Company, @DateIni, @DateEnd, @VendorId, @Invoice, @Container, @Reference, @DetailId

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblData

	IF @VendorId = ''
		SET @VendorId = Null

	IF @Invoice = ''
		SET @Invoice = Null

	IF @Container = ''
		SET @Container = Null

	IF @Reference= ''
		SET @Reference = Null

	PRINT 'Checking SWS'

	SET @Query	= N'SELECT	OVP.Vn_Code,
							VND.Name,
							OVP.vendor_invoice,
							OVP.ADate,
							OVP.Amount,
							OVP.Amount AS Balance,
							INV.Eq_Code,
							INV.BTRef,
							'''' AS DataStatus,
							Null AS KeyField,
							'''' AS DataSource
					FROM	TRK.InvVnPay OVP
							INNER JOIN TRK.Vendor VND ON OVP.Cmpy_No = VND.Cmpy_No AND OVP.Vn_Code = VND.Code
							INNER JOIN TRK.Invoice INV ON OVP.Cmpy_No = INV.Cmpy_No AND OVP.inv_code = INV.Code AND INV.Type <> ''C''
					WHERE	OVP.Cmpy_No = ' + CAST(@CompanyNo AS Varchar) + ' 
							AND OVP.vendor_invoice = ''' + RTRIM(@Invoice) + ''''

	INSERT INTO @tblData
	EXECUTE USP_QuerySWS_ReportData @Query

	SET @RowCount = (SELECT COUNT(*) FROM @tblData)

	IF @RowCount > 0
	BEGIN
		UPDATE	@tblData
		SET		DataStatus = 'Unposted in SWS',
				DataSource = 'SWS'
		WHERE	DataStatus = '' AND DataSource = ''

		UPDATE	@tblResult
		SET		VendorId	= DATA.VendorId,
				VendorName	= DATA.VendorName,
				InvDate		= DATA.InvDate,
				Amount		= DATA.Amount,
				Balance		= DATA.Balance,
				Reference	= DATA.Reference,
				DataStatus	= DATA.DataStatus,
				KeyField	= DATA.KeyField,
				DataSource	= DATA.DataSource
		FROM	@tblData DATA
		WHERE	File_Invoice = RTRIM(DATA.Invoice)
	END

	/*
	=================================================================
	SCRIPT DISABLE BY CARLOS A. FLORES ON 01/26/2021
	REASON: A SWS SEARCH HAS BEEN ADDED TO THE STORED PROCEDURE
	=================================================================
	*/
	--IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under the Great Plains check FSI Integration
	--BEGIN
	--	PRINT 'Checking FSI Integration / ' + CAST(GETDATE() AS Varchar)

	--	INSERT INTO @tblData
	--	SELECT	DISTINCT RecordCode AS VendorId,
	--			dbo.GetVendorName(Company, RecordCode) AS VendorName,
	--			CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END AS Invoice,
	--			ReceivedOn AS Date,		
	--			ChargeAmount1 AS Amount,
	--			ChargeAmount1 AS Balance,
	--			Equipment,
	--			InvoiceNumber AS Reference,
	--			'In FSI' AS DataStatus,
	--			RTRIM(Company) + '~' + RTRIM(RecordCode) + '~' + RTRIM(CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END) + '~' AS KeyField,
	--			'FSI' AS DataSource
	--	FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Vendors
	--	WHERE	Company = @Company
	--			AND WeekEndDate BETWEEN @DateIni AND @DateEnd
	--			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND RecordCode = @VendorId))
	--			AND (@Invoice IS Null OR (@Invoice IS NOT Null AND VendorDocument LIKE '%' + @Invoice + '%'))
	--			AND (@Container IS Null OR (@Container IS NOT Null AND Equipment LIKE '%' + @Container + '%'))
	--			AND (@Reference IS Null OR (@Reference IS NOT Null AND InvoiceNumber LIKE '%' + @Reference + '%'))

	--	UPDATE	@tblResult
	--	SET		VendorId	= DATA.VendorId,
	--			VendorName	= DATA.VendorName,
	--			InvDate		= DATA.InvDate,
	--			Amount		= DATA.Amount,
	--			Balance		= DATA.Balance,
	--			Reference	= DATA.Reference,
	--			DataStatus	= DATA.DataStatus,
	--			KeyField	= DATA.KeyField,
	--			DataSource	= DATA.DataSource
	--	FROM	@tblData DATA
	--	WHERE	File_Invoice = RTRIM(DATA.Invoice)
	--END

	SET @RowCount = (SELECT COUNT(*) FROM @tblData)

	IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under the FSI checks under AP integrations
	BEGIN
		PRINT 'Checking AP integrations / ' + CAST(GETDATE() AS Varchar)

		SET @Query = N'SELECT DISTINCT VENDORID,
			CASE WHEN VendorName = '''' THEN GPCustom.dbo.GetVendorName(Company, VENDORID) ELSE VendorName END AS VendorName,
			DOCNUMBR,
			DOCDATE,
			DOCAMNT,
			0,
			Container,
			ProNum,
			''In '' + Integration,
			RTRIM(Company) + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR) + ''~'',
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

		UPDATE	@tblResult
		SET		VendorId	= DATA.VendorId,
				VendorName	= DATA.VendorName,
				InvDate		= DATA.InvDate,
				Amount		= DATA.Amount,
				Balance		= DATA.Balance,
				Reference	= DATA.Reference,
				DataStatus	= DATA.DataStatus,
				KeyField	= DATA.KeyField,
				DataSource	= DATA.DataSource
		FROM	@tblData DATA
		WHERE	File_Invoice = RTRIM(DATA.Invoice)
	END

	SET @RowCount = (SELECT COUNT(*) FROM @tblData)

	--IF @RowCount = 0 AND @OpsSystem = 'ONEVIEW' AND @DateIni > '01/01/2000' -- If not found under Great Plains, FSI and AP integrations
	--BEGIN
	--	PRINT 'Checking OneView'

	--	SET @Query = N'SELECT CLN.External_Id AS VendorId, 
	--		'''' AS VendorName,
	--		HDR.BL_Number, 
	--		HDR.Inv_date, 
	--		HDR.Inv_total, 
	--		HDR.Inv_balance, 
	--		'''',
	--		HDR.Inh_invoice_id,
	--		''In OneView'' AS DataStatus,
	--		''' + @Company + ''' + ''~'' + RTRIM(HDR.Vendor) + ''~'' + RTRIM(HDR.BL_Number),
	--		''OneView'' AS DataSource
	--FROM	AP_Hdr HDR
	--		INNER JOIN Client CLN ON HDR.Vendor = CLN.AcctG_Id
	--WHERE	HDR.Div_Code = ''' + @OpCompanyId + ''' 
	--		AND HDR.Inv_date BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''''

	--	IF @VendorId IS NOT Null
	--		SET @Query = @Query + ' AND CLN.External_Id = ''' + RTRIM(@VendorId) + ''''

	--	IF @Invoice IS NOT Null
	--		SET @Query = @Query + ' AND HDR.BL_Number = ''' + RTRIM(@Invoice) + ''''

	--	IF @Reference IS NOT Null
	--		SET @Query = @Query + ' AND HDR.Invoice_No LIKE ''' + '%' + RTRIM(@Reference) + '%' + ''''
	
	--	INSERT INTO @tblDataTmp
	--	EXECUTE USP_QueryPervasive @Query
	
	--	INSERT INTO @tblData
	--	SELECT	*
	--	FROM	@tblDataTmp
	--	WHERE	VendorId + '~' + Invoice NOT IN (SELECT VendorId + '~' + Invoice FROM @tblData)

	--	UPDATE	@tblData
	--	SET		VendorId	= CASE WHEN @OpCompanyId = 20 THEN SUBSTRING(VendorId, 2, 15) ELSE VendorId END

	--	UPDATE	@tblData
	--	SET		VendorName	= GPCustom.dbo.GetVendorName(@Company, VendorId)

	--	UPDATE	@tblResult
	--	SET		VendorId	= DATA.VendorId,
	--			VendorName	= DATA.VendorName,
	--			InvDate		= DATA.InvDate,
	--			Amount		= DATA.Amount,
	--			Balance		= DATA.Balance,
	--			Reference	= DATA.Reference,
	--			DataStatus	= DATA.DataStatus,
	--			KeyField	= DATA.KeyField,
	--			DataSource	= DATA.DataSource
	--	FROM	@tblData DATA
	--	WHERE	File_Invoice = RTRIM(DATA.Invoice)
	--END
	
	--PRINT 'Creating cursor Transaction_Companies'

	--DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	--SELECT	DISTINCT Invoice,
	--		DataStatus
	--FROM	@tblData

	--OPEN Transaction_Companies 
	--FETCH FROM Transaction_Companies INTO @Invoice, @DataStatus

	--WHILE @@FETCH_STATUS = 0 
	--BEGIN
	--	SET @Invoice = REPLACE(@Invoice, '?', '')
	--	SET @Query = 'SELECT VendorId, DocNumbr, DocDate, DocAmnt, CurTrxAm, ''W'' AS Location FROM ' + RTRIM(@Company) + '.dbo.PM10000 WHERE VendorId = ''' + RTRIM(@VendorId) + ''' AND (DocNumbr = ''' + RTRIM(@Invoice) + ''' OR DocNumbr LIKE ''' + RTRIM(@Invoice) + '%'') '
	--	SET @Query = @Query + 'UNION SELECT VendorId, DocNumbr, DocDate, DocAmnt, CurTrxAm, ''O'' AS Location FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE VendorId = ''' + RTRIM(@VendorId) + ''' AND (DocNumbr = ''' + RTRIM(@Invoice) + ''' OR DocNumbr LIKE ''' + RTRIM(@Invoice) + '%'') '
	--	SET @Query = @Query + 'UNION SELECT VendorId, DocNumbr, DocDate, DocAmnt, CurTrxAm, ''H'' AS Location FROM ' + RTRIM(@Company) + '.dbo.PM30200 WHERE VendorId = ''' + RTRIM(@VendorId) + ''' AND (DocNumbr = ''' + RTRIM(@Invoice) + ''' OR DocNumbr LIKE ''' + RTRIM(@Invoice) + '%'')'

	--	DELETE @tblFind
		
	--	PRINT 'Insert GP search results'
		
	--	INSERT INTO @tblFind
	--	EXECUTE(@Query)

	--	--IF @@ROWCOUNT = 0
	--	--	SET @Status = 'GP Not Found' + ISNULL(' (' + @DataStatus + ')','')
	--	--ELSE
	--	--BEGIN
	--	--	SELECT	@VendorId	= Vendorid,
	--	--			@Amount		= Amount,
	--	--			@Balance	= Balance,
	--	--			@InvDate	= InvDate,
	--	--			@Location	= Location
	--	--	FROM	@tblFind

	--	--	IF @Location = 'W'
	--	--		SET	@Status = 'GP Unposted'
	--	--	ELSE
	--	--		SET	@Status = CASE WHEN @Balance = 0 THEN 'GP Paid' WHEN @Amount > @Balance AND @Balance > 0 THEN 'GP Partialy Paid' ELSE 'GP Unpaid' END
	--	--END

	--	UPDATE	@tblData
	--	SET		Balance		= ISNULL(@Balance,0),
	--			--DataStatus	= @Status,
	--			InvDate		= ISNULL(@InvDate,InvDate),
	--			VendorId	= CASE WHEN VendorId IS Null THEN @VendorId ELSE VendorId END
	--	WHERE	Invoice = @Invoice
	--			AND (VendorId = @VendorId
	--			OR VendorId IS Null)

	--	FETCH FROM Transaction_Companies INTO @Invoice, @DataStatus
	--END

	--CLOSE Transaction_Companies
	--DEALLOCATE Transaction_Companies
	------------------------------------------------------------------------------------------
	
	--INSERT INTO #tmpResults
	--SELECT	HDR.VendorInvoiceStatusHdrId AS HeaderId
	--		,DET.VendorInvoiceStatusDetId AS DetailId
	--		,HDR.Company
	--		,ISNULL(HDR.VendorId,TB1.VendorId) AS VendorId
	--		,GPCustom.dbo.GetVendorName(HDR.Company, TB1.VENDORID) AS VendorName
	--		,HDR.FileName
	--		,HDR.UploadedOn
	--		,REPLACE(DET.InvoiceNumber, '?', '') AS File_Invoice
	--		,DET.InvoiceDate AS File_InvDate
	--		,DET.ContainerNumber AS File_Container
	--		,DET.Reference AS File_Reference
	--		,DET.Amount AS File_Amount
	--		,REPLACE(ISNULL(TB1.Invoice, DET.InvoiceNumber), '?', '') AS Invoice
	--		,TB1.InvDate
	--		,TB1.Amount
	--		,TB1.Balance
	--		,DET.Amount - ISNULL(TB1.Amount, 0) AS Inv_Difference
	--		,TB1.Container
	--		,TB1.Reference
	--		,ISNULL(TB1.DataStatus, 'Not Found') AS DataStatus
	--		,TB1.KeyField
	--		,TB1.DataSource
	--		,Null
	--		,Null
	--		,Null
	--		,Null
	--FROM	VendorInvoiceStatusHdr HDR
	--		INNER JOIN VendorInvoiceStatusDet DET ON HDR.VendorInvoiceStatusHdrId = DET.VendorInvoiceStatusHdrId
	--		LEFT JOIN @tblData TB1 ON (HDR.VendorId = TB1.VendorId OR DET.InvoiceNumber = TB1.Invoice)
	--WHERE	HDR.VendorInvoiceStatusHdrId = @HeaderId
	--		AND DET.VendorInvoiceStatusDetId = @DetailId

	FETCH FROM curTransactions INTO @Company, @DateIni, @DateEnd, @VendorId, @Invoice, @Container, @Reference, @DetailId
END

CLOSE curTransactions
DEALLOCATE curTransactions

INSERT INTO VendorInvoiceStatusResult
SELECT	HeaderId,
		DetailId,
		Company,
		VendorId,
		VendorName,
		FileName,
		UploadedOn,
		File_Invoice,
		File_InvDate,
		File_Container,
		File_Reference,
		File_Amount,
		Invoice,
		InvDate,
		Amount,
		Balance,
		File_Amount - ISNULL(Amount, 0) AS Inv_Difference,
		Container,
		Reference,
		ISNULL(DataStatus, 'Not Found') AS DataStatus,
		KeyField,
		DataSource,
		DocType,
		DocumentNumber,
		Applied_Paid,
		PostingDate
FROM	@tblResult

DROP TABLE #tmpResults

EXECUTE USP_VendorInvoiceStatus_Grid @HeaderId