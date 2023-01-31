/*
EXECUTE USP_RaistoneExtract_JustData 'GLSO','7899'
*/
ALTER PROCEDURE USP_RaistoneExtract_JustData
		@CompanyId			varchar(5) = Null,
		@CustomerId			varchar(20) = Null,
		@SentStatus			smallint = 0 -- 0=All Open, 1=Sent Today, 2=Unsent
AS
SET NOCOUNT ON

IF @CompanyId = 'ALL' OR @CompanyId = ''
	SET @CompanyId = Null

IF @CustomerId = 'ALL' OR @CustomerId = ''
	SET @CustomerId = Null

DECLARE @Query				varchar(MAX) = '',
		@Company			varchar(5)

DECLARE @RaistoneExtract	Table (
		Destination				nvarchar(100),
		BuyerName				nvarchar(100),
		SourceSystem			nvarchar(100),
		SourceReference			nvarchar(100),
		SupplierName			nvarchar(75),
		SupplierId				nvarchar(25),
		Type					nvarchar(25),
		InvoiceDate				date,
		Currency				nvarchar(3),
		PaymentDate				date,
		InvoiceId				nvarchar(25),
		InvoiceStatus			nvarchar(15),
		InvoiceAmount			numeric(10,2),
		Discount				numeric(10,2),
		SupplierReference		nvarchar(100),
		InternalReferenceNote	nvarchar(500),
		DEX_ROW_ID				int)

IF @SentStatus <> 1
BEGIN
	DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT LTRIM(RTRIM(CompanyId))
	FROM	GPCustom.dbo.Companies 
	WHERE	CompanyId IN (SELECT CompanyId FROM GPCustom.dbo.Companies_Parameters WHERE ParameterCode = 'RAISTONE' AND ParBit = 1)
			AND (@CompanyId IS Null	OR (CompanyId = @CompanyId AND @CompanyId IS NOT Null))

	OPEN curCompanies 
	FETCH FROM curCompanies INTO @Company

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Query = N'SELECT LTRIM(RTRIM(v.VNDCHKNM)) AS "Destination"
				,REPLACE(LTRIM(RTRIM(c.CompanyName)),''–'',''-'') AS "BuyerName" -- the Companies table in GPCustom has "hyphens" that are not actualy ASCII hyphens
				,''' + @Company + ''' AS "SourceSystem"
				,LTRIM(RTRIM(ofile.VCHRNMBR)) AS "SourceReference"
				,LTRIM(RTRIM(v.VENDNAME)) AS "SupplierName"
				,LTRIM(RTRIM(ofile.VENDORID)) AS "SupplierId"
				,CASE WHEN ofile.doctype = ''5'' THEN ''Credit Note'' ELSE ''Invoice'' END AS "Type"
				,ofile.DOCDATE AS "InvoiceDate"
				,''USD'' AS "Currency"
				,CASE WHEN ofile.doctype = ''5'' THEN NULL ELSE ofile.DUEDATE END AS "PaymentDate"
				,CONCAT(''' + @Company + ''','' '', ofile.VCHRNMBR) AS "InvoiceId"
				,''APPROVED'' AS "InvoiceStatus"
				,ofile.CURTRXAM AS "InvoiceAmount"
				,''0'' AS "DiscountAmount"
				,LTRIM(RTRIM(ofile.DOCNUMBR)) AS "SupplierReference"
				,ofile.TRXDSCRN AS "InternalReferenceNote"
				,ofile.DEX_ROW_ID
			FROM ' + @Company + '.dbo.PM20000 ofile
				INNER JOIN ' + @Company + '.dbo.PM00200 v ON v.VENDORID = ofile.VENDORID
				INNER JOIN GPCustom.dbo.Companies c ON c.CompanyId = ''' + @Company + '''
				INNER JOIN GPCustom.dbo.GPVendorMaster m ON v.VENDORID = m.VendorId AND m.RapidPay = 1 AND m.Company = c.CompanyId
			WHERE ofile.HOLD = 0 -- do not send items that are on hold
				AND ofile.CURTRXAM > 0 -- do not send anything to Raistone we already paid for some reason
				AND ofile.DOCTYPE <> 5 -- remove credit memos, these get applied to invoices in house and are not communicated '

		IF @CustomerId IS NOT Null
			SET @Query = @Query + 'AND ofile.VENDORID = ''' + RTRIM(@CustomerId) + ''''

		INSERT INTO @RaistoneExtract
		EXECUTE(@Query)

		FETCH FROM curCompanies INTO @Company
	END

	CLOSE curCompanies
	DEALLOCATE curCompanies
END

IF @SentStatus = 0 OR @SentStatus IS Null
	SELECT	DISTINCT MAIN.Destination,
			MAIN.BuyerName,
			MAIN.SourceSystem,
			MAIN.SourceReference,
			MAIN.SupplierName,
			MAIN.SupplierId,
			MAIN.Type,
			MAIN.InvoiceDate,
			MAIN.Currency,
			MAIN.PaymentDate,
			MAIN.InvoiceId,
			MAIN.InvoiceStatus,
			MAIN.InvoiceAmount,
			MAIN.Discount,
			MAIN.SupplierReference,
			MAIN.InternalReferenceNote,
			IIF(DEX.SourceSystem IS Null, 'No Sent', 'Sent on ' + CONVERT(Char(10), ImportedOn, 101)) AS DataStatus
	FROM	@RaistoneExtract MAIN
			LEFT JOIN Raistone_DailyExtract DEX ON MAIN.SourceSystem + '_' + MAIN.SourceReference + '_' + MAIN.SupplierId = DEX.SourceSystem + '_' + DEX.SourceReference + '_' + DEX.SupplierId
	WHERE	@CustomerId IS Null
			OR (@CustomerId IS NOT Null AND MAIN.SupplierId = @CustomerId)
	ORDER BY 1
ELSE
BEGIN
	IF @SentStatus = 2
		SELECT	MAIN.Destination,
				MAIN.BuyerName,
				MAIN.SourceSystem,
				MAIN.SourceReference,
				MAIN.SupplierName,
				MAIN.SupplierId,
				MAIN.Type,
				MAIN.InvoiceDate,
				MAIN.Currency,
				MAIN.PaymentDate,
				MAIN.InvoiceId,
				MAIN.InvoiceStatus,
				MAIN.InvoiceAmount,
				MAIN.Discount,
				MAIN.SupplierReference,
				MAIN.InternalReferenceNote,
				'No Sent' AS DataStatus
		FROM	@RaistoneExtract MAIN
		WHERE	SourceSystem + '_' + SourceReference + '_' + SupplierId NOT IN (SELECT SourceSystem + '_' + SourceReference + '_' + SupplierId FROM Raistone_DailyExtract)
				AND (@CustomerId IS Null
				OR (@CustomerId IS NOT Null AND MAIN.SupplierId = @CustomerId))
		ORDER BY 1
	ELSE
		SELECT	MAIN.Destination,
				MAIN.BuyerName,
				MAIN.SourceSystem,
				MAIN.SourceReference,
				MAIN.SupplierName,
				MAIN.SupplierId,
				MAIN.Type,
				MAIN.InvoiceDate,
				MAIN.Currency,
				MAIN.PaymentDate,
				MAIN.InvoiceId,
				MAIN.InvoiceStatus,
				MAIN.InvoiceAmount,
				MAIN.Discount,
				MAIN.SupplierReference,
				MAIN.InternalReferenceNote,
				'Sent on ' + CONVERT(Char(10), ImportedOn, 101) AS DataStatus
		FROM	Raistone_DailyExtract MAIN
		WHERE	ImportedOn = CAST(GETDATE() AS Date)
				AND (@CustomerId IS Null
				OR (@CustomerId IS NOT Null AND MAIN.SupplierId = @CustomerId))
		ORDER BY 1
END