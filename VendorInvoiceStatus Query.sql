/*
EXECUTE USP_VendorInvoiceStatus_ByFile 1
*/
ALTER PROCEDURE USP_VendorInvoiceStatus_ByFile
		@HeaderId		Int = 1
AS
SET NOCOUNT ON

DECLARE	@DetailId		Int,
		@Company		Varchar(5),
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
		@OpCompanyId	Varchar(3)

DECLARE @tblData		Table
		(VendorId		Varchar(20),
		VendorName		Varchar(75),
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
		(VendorId		Varchar(20),
		VendorName		Varchar(75),
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
		(Invoice		Varchar(35),
		InvDate			Date,
		Amount			Numeric(10,2),
		Balance			Numeric(10,2),
		Location		Char(1))

DELETE	VendorInvoiceStatusResult
WHERE	HeaderId = @HeaderId

SELECT	HDR.VendorInvoiceStatusHdrId AS HeaderId
		,DET.VendorInvoiceStatusDetId AS DetailId
		,HDR.Company
		,HDR.VendorId
		,HDR.VendorName
		,HDR.FileName
		,HDR.UploadedOn
		,DET.InvoiceNumber AS File_Invoice
		,DET.InvoiceDate AS File_InvDate
		,DET.ContainerNumber AS File_Container
		,DET.Reference AS File_Reference
		,DET.Amount AS File_Amount
		,TB1.Invoice
		,TB1.InvDate
		,TB1.Amount
		,TB1.Balance
		,0 AS Inv_Difference
		,TB1.Container
		,TB1.Reference
		,TB1.DataStatus
		,TB1.KeyField
		,TB1.DataSource
INTO	#tmpRecords
FROM	VendorInvoiceStatusHdr HDR
		INNER JOIN VendorInvoiceStatusDet DET ON HDR.VendorInvoiceStatusHdrId = DET.VendorInvoiceStatusHdrId
		LEFT JOIN @tblData TB1 ON HDR.VendorId = TB1.VendorId
WHERE	HDR.VendorInvoiceStatusHdrId = @HeaderId

SELECT	*
INTO	#tmpResults
FROM	#tmpRecords
WHERE	HeaderId = -1

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		DATEADD(dd, -30, File_InvDate),
		DATEADD(dd, 30, File_InvDate),
		VendorId,
		CASE WHEN File_Invoice = '' THEN Null ELSE File_Invoice END,
		CASE WHEN File_Container = '' THEN Null ELSE File_Container END,
		CASE WHEN File_Reference = '' THEN Null ELSE (CASE WHEN File_Invoice = '' THEN File_Reference ELSE Null END) END,
		DetailId
FROM	#tmpRecords

OPEN curTransactions 
FETCH FROM curTransactions INTO @Company, @DateIni, @DateEnd, @VendorId, @Invoice, @Container, @Reference, @DetailId

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblData

	------------------------------------------------------------------------------------------
	IF @VendorId = ''
		SET @VendorId = Null

	IF @Invoice = ''
		SET @Invoice = Null

	IF @Container = ''
		SET @Container = Null

	IF @Reference= ''
		SET @Reference = Null

	-- Search first in Great Plains
	SET @Query = N'SELECT VENDORID,
					GPCustom.dbo.GetVendorName(''' + @Company + ''', VENDORID) AS VendorName,
					DOCNUMBR,
					DOCDATE,
					DOCAMNT,
					CURTRXAM,
					'''',
					TRXDSCRN,
					Null,
					''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
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
			SELECT VENDORID,
				GPCustom.dbo.GetVendorName(''' + @Company + ''', VENDORID) AS VendorName,
				DOCNUMBR,
				DOCDATE,
				DOCAMNT,
				CURTRXAM,
				'''',
				TRXDSCRN,
				Null,
				''' + @Company + ''' + ''~'' + RTRIM(VENDORID) + ''~'' + RTRIM(DOCNUMBR),
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

	IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under the Great Plains check FSI Integration
	BEGIN
		INSERT INTO @tblData
		SELECT	DISTINCT RecordCode AS VendorId,
				dbo.GetVendorName(Company, RecordCode) AS VendorName,
				CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END AS Invoice,
				ReceivedOn AS Date,		
				ChargeAmount1 AS Amount,
				ChargeAmount1 AS Balance,
				Equipment,
				InvoiceNumber AS Reference,
				'In FSI' AS DataStatus,
				RTRIM(Company) + '~' + RTRIM(RecordCode) + '~' + RTRIM(CASE WHEN MainVendorDocument = '' OR MainVendorDocument = Equipment THEN VendorDocument ELSE MainVendorDocument END) + '~' AS KeyField,
				'FSI' AS DataSource
		FROM	ILSINT02.Integrations.dbo.View_Integration_FSI_Vendors
		WHERE	Company = @Company
				AND WeekEndDate BETWEEN @DateIni AND @DateEnd
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND RecordCode = @VendorId))
				AND (@Invoice IS Null OR (@Invoice IS NOT Null AND VendorDocument LIKE '%' + @Invoice + '%'))
				AND (@Container IS Null OR (@Container IS NOT Null AND Equipment LIKE '%' + @Container + '%'))
				AND (@Reference IS Null OR (@Reference IS NOT Null AND InvoiceNumber LIKE '%' + @Reference + '%'))
	END

	SET @RowCount = (SELECT COUNT(*) FROM @tblData)

	IF @RowCount = 0 AND @DateIni > '01/01/2000' -- If not found under the FSI checks under AP integrations
	BEGIN
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

	SET @RowCount = (SELECT COUNT(*) FROM @tblData)

	IF @RowCount = 0 AND @OpsSystem = 'ONEVIEW' AND @DateIni > '01/01/2000' -- If not found under Great Plains, FSI and AP integrations
	BEGIN
		SET @Query = N'SELECT CLN.External_Id AS VendorId, 
			'''' AS VendorName,
			HDR.BL_Number, 
			HDR.Inv_date, 
			HDR.Inv_total, 
			HDR.Inv_balance, 
			'''',
			HDR.Inh_invoice_id,
			''In OneView'' AS DataStatus,
			''' + @Company + ''' + ''~'' + RTRIM(HDR.Vendor) + ''~'' + RTRIM(HDR.BL_Number),
			''OneView'' AS DataSource
	FROM	AP_Hdr HDR
			INNER JOIN Client CLN ON HDR.Vendor = CLN.AcctG_Id
	WHERE	HDR.Div_Code = ''' + @OpCompanyId + ''' 
			AND HDR.Inv_date BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''''

		IF @VendorId IS NOT Null
			SET @Query = @Query + ' AND CLN.External_Id = ''' + RTRIM(@VendorId) + ''''

		IF @Invoice IS NOT Null
			SET @Query = @Query + ' AND HDR.BL_Number = ''' + RTRIM(@Invoice) + ''''

		IF @Reference IS NOT Null
			SET @Query = @Query + ' AND HDR.Invoice_No LIKE ''' + '%' + RTRIM(@Reference) + '%' + ''''
			--SET @Query = @Query + ' AND (HDR.Invoice_No LIKE ''' + '%' + RTRIM(@Reference) + '%' + ''' OR HDR.Inh_invoice_id LIKE ''' + '%' + RTRIM(@Reference) + '%' + ''')'
	
		INSERT INTO @tblDataTmp
		EXECUTE USP_QueryPervasive @Query
	
		INSERT INTO @tblData
		SELECT	*
		FROM	@tblDataTmp
		WHERE	VendorId + '~' + Invoice NOT IN (SELECT VendorId + '~' + Invoice FROM @tblData)

		UPDATE	@tblData
		SET		VendorId	= CASE WHEN @OpCompanyId = 20 THEN SUBSTRING(VendorId, 2, 15) ELSE VendorId END

		UPDATE	@tblData
		SET		VendorName	= GPCustom.dbo.GetVendorName(@Company, VendorId)
	END

	DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT Invoice,
			DataStatus
	FROM	@tblData

	OPEN Transaction_Companies 
	FETCH FROM Transaction_Companies INTO @Invoice, @DataStatus

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
		WHERE	VendorId = @VendorId
				AND Invoice = @Invoice

		FETCH FROM Transaction_Companies INTO @Invoice, @DataStatus
	END

	CLOSE Transaction_Companies
	DEALLOCATE Transaction_Companies
	------------------------------------------------------------------------------------------

	INSERT INTO #tmpResults
	SELECT	HDR.VendorInvoiceStatusHdrId AS HeaderId
			,DET.VendorInvoiceStatusDetId AS DetailId
			,HDR.Company
			,HDR.VendorId
			,HDR.VendorName
			,HDR.FileName
			,HDR.UploadedOn
			,DET.InvoiceNumber AS File_Invoice
			,DET.InvoiceDate AS File_InvDate
			,DET.ContainerNumber AS File_Container
			,DET.Reference AS File_Reference
			,DET.Amount AS File_Amount
			,ISNULL(TB1.Invoice, DET.InvoiceNumber) AS Invoice
			,TB1.InvDate
			,TB1.Amount
			,TB1.Balance
			,DET.Amount - ISNULL(TB1.Amount, 0) AS Inv_Difference
			,TB1.Container
			,TB1.Reference
			,CASE WHEN TB1.DataStatus IS Null THEN 'Not Found' ELSE TB1.DataStatus END AS DataStatus
			,TB1.KeyField
			,TB1.DataSource
	FROM	VendorInvoiceStatusHdr HDR
			INNER JOIN VendorInvoiceStatusDet DET ON HDR.VendorInvoiceStatusHdrId = DET.VendorInvoiceStatusHdrId
			LEFT JOIN @tblData TB1 ON HDR.VendorId = TB1.VendorId
	WHERE	HDR.VendorInvoiceStatusHdrId = @HeaderId
			AND DET.VendorInvoiceStatusDetId = @DetailId

	FETCH FROM curTransactions INTO @Company, @DateIni, @DateEnd, @VendorId, @Invoice, @Container, @Reference, @DetailId
END

CLOSE curTransactions
DEALLOCATE curTransactions

INSERT INTO VendorInvoiceStatusResult
SELECT	*
FROM	#tmpResults

SELECT	HeaderId
		,DetailId
		,Company
		,VendorId
		,VendorName
		,FileName
		,UploadedOn
		,File_Invoice
		,File_InvDate
		,File_Container
		,File_Reference
		,File_Amount
		,Invoice
		,InvDate
		,Amount
		,Balance
		,Inv_Difference
		,Container
		,Reference
		,DataStatus
		,KeyField
		,DataSource
		--,'Invoice: ' + File_Invoice + ' / Date: ' + CONVERT(Varchar, File_InvDate, 101) + ' / Amount: ' + FORMAT(File_Amount, 'C', 'en-US') + ' / Equipment: ' + File_Container AS GroupId
		,'Invoice: <strong style="color: #FFFF00">' + File_Invoice + '</strong> / Date: <strong style="color: #FFFF00">' + CONVERT(Varchar, File_InvDate, 101) + '</strong> / Amount: <strong style="color: #00FF00">' + FORMAT(File_Amount, 'C', 'en-US') + '</strong> / Equipment: <strong style="color: #FFFF00">' + File_Container + '</strong>' AS GroupId
FROM	VendorInvoiceStatusResult
WHERE	HeaderId = @HeaderId
ORDER BY
		File_InvDate,
		File_Invoice

DROP TABLE #tmpRecords
DROP TABLE #tmpResults

-- INSERT INTO VendorInvoiceStatusHdr (Company, VendorId, VendorName, FileName) VALUES ('GLSO','293','Vasquez Trucking Inc', 'IGS_Vendor_Statement.csv')