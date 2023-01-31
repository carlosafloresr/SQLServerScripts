DECLARE @Query			nvarchar(MAX) = '',
		@Company		nvarchar(5)	= '',
		@Delim			nvarchar(1) = '*',
		@DOSCommand		nvarchar(4000),
		@DatePortion	char(10) = GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0') + '_' + GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + '_' + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0'),
		@Counter		Int = 0,
		@Amount			Numeric(12,2),
		@Body			Varchar(MAX) = '',
		@HTMLTable		Varchar(500) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">',
		@EmailSubject	Varchar(100) = 'Raistone - IMC Control Totals ' + FORMAT(GETDATE(),'d', 'en-US'),
		@Email			Varchar(200) = (SELECT VarC FROM Parameters WHERE ParameterCode = 'RAISTONE_EMAILTO'),
		@EmailCC		Varchar(200) = 'cflores@imcc.com',
		@DaySeconds		Varchar(10) = CAST(DATEDIFF(SS, CAST(GETDATE() AS Date), GETDATE()) AS Varchar),
		@FileName		Varchar(150)

DECLARE @RaistoneExtract		Table (
		[Destination]			nvarchar(100),
		[BuyerName]				nvarchar(100),
		[SourceSystem]			nvarchar(100),
		[SourceReference]		nvarchar(100),
		[SupplierName]			nvarchar(75),
		[SupplierId]			nvarchar(25),
		[Type]					nvarchar(25),
		[InvoiceDate]			date,
		[Currency]				nvarchar(3),
		[PaymentDate]			date,
		[InvoiceId]				nvarchar(25),
		[InvoiceStatus]			nvarchar(15),
		[InvoiceAmount]			numeric(10,2),
		[Discount]				numeric(10,2),
		[SupplierReference]		nvarchar(100),
		[InternalReferenceNote] nvarchar(500),
		[DEX_ROW_ID]			int)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT LTRIM(RTRIM(CompanyId))
FROM	GPCustom.dbo.Companies 
WHERE	CompanyId IN (SELECT CompanyId FROM GPCustom.dbo.Companies_Parameters WHERE ParameterCode = 'RAISTONE' AND ParBit = 1)

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
			AND ofile.DOCTYPE <> 5 -- remove credit memos, these get applied to invoices in house and are not communicated'

	INSERT INTO @RaistoneExtract
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DELETE	@RaistoneExtract
WHERE	SourceSystem + '_' + SourceReference + '_' + SupplierId IN (SELECT SourceSystem + '_' + SourceReference + '_' + SupplierId FROM Raistone_DailyExtract)

SELECT	*
FROM	@RaistoneExtract

--SELECT	*
--	INTO	##tmpRaistoneData
--	FROM	(
--			SELECT	'"' + RTRIM(BuyerName) + '"'
--					+ ',' + RTRIM(SourceSystem)
--					+ ',"' + RTRIM(SupplierName) + '"'
--					+ ',' + RTRIM(SupplierId)
--					+ ',' + RTRIM(Type)
--					+ ',' + FORMAT(InvoiceDate,'MM/dd/yyyy')
--					+ ',' + RTRIM(Currency)
--					+ ',' + CASE
--						WHEN PaymentDate IS NULL THEN ''
--						WHEN DATEDIFF(DAY,PaymentDate,InvoiceDate) < 20 THEN FORMAT(DATEADD(DAY,30,InvoiceDate),'MM/dd/yyyy') 
--						ELSE FORMAT(PaymentDate,'MM/dd/YYYY')
--						END
--					+ ',"' + RTRIM(SupplierReference) + '"'
--					+ ',' + RTRIM(InvoiceStatus)
--					+ ',' + CAST(InvoiceAmount AS Varchar)
--					+ ',' + CAST(Discount AS Varchar)
--					+ ',"' + RTRIM(InvoiceId) + '"'
--					+ ',' + RTRIM(InternalReferenceNote) AS TextValue
--			FROM	@RaistoneExtract
--			) DATA
--	ORDER BY 1

--	SET @FileName = 'c:\Temp\IN_' + @DatePortion + '_IMCCompanies_' + RTRIM(@DaySeconds) + '.csv'
--	SET @Query = '"SELECT ''Buyer_Name,Source_System_Buyer_ID,SupplierName,Source_System_Supplier_ID,TYPE,Invoice Issue Date,CURRENCY,Expected Payment Date,Supplier Invoice Number,Invoice Status,Invoice Amount,Discount Amount,Source_System_Document_ID,Internal Reference'' '
--	SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpRaistoneData" QUERYOUT ' + @FileName + ' -c -t, -T'
--	print @FileName
--	EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output

--	IF OBJECT_ID('tempdb..##tmpRaistoneData') IS NOT NULL 
--		DROP TABLE ##tmpRaistoneData