/*
****************************************************************
	GP AP OPEN TRANSACTIONS EXPORT FOR RAISTONE (RAPID PAY)
****************************************************************
	 CREATED BY: BRIAN CATT			     CREATED ON: 01/10/2022
	MODIFIED BY: CARLOS A FLORES		MODIFIED ON: 03/11/2022
****************************************************************
*/
DECLARE @Query			nvarchar(MAX) = '',
		@Company		nvarchar(5)	= '',
		@Delim			nvarchar(1) = '*',
		@DOSCommand		nvarchar(4000),
		@DatePortion	char(10) = GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0') + '_' + GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + '_' + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0')

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
		[InternalReferenceNote] nvarchar(500))

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
			,CASE 
				WHEN ofile.doctype = ''5''
				THEN ''Credit Note''
				ELSE ''Invoice''
				END AS "Type"
			,ofile.DOCDATE AS "InvoiceDate"
			,''USD'' AS "Currency"
			,CASE
				WHEN ofile.doctype = ''5''
				THEN NULL
				ELSE ofile.DUEDATE 
				END AS "PaymentDate"
			,CONCAT(''' + @Company + ''','','', ofile.VCHRNMBR) AS "InvoiceId"
			,''APPROVED'' AS "InvoiceStatus"
			,ofile.CURTRXAM AS "InvoiceAmount"
			,''0'' AS "DiscountAmount"
			,LTRIM(RTRIM(ofile.DOCNUMBR)) AS "SupplierReference"
			,ofile.TRXDSCRN AS "InternalReferenceNote"
		FROM ' + @Company + '.dbo.PM20000 ofile
			LEFT OUTER JOIN ' + @Company + '.dbo.PM00200 v ON v.VENDORID = ofile.VENDORID
			LEFT OUTER JOIN GPCustom.dbo.Companies c ON c.CompanyId = ''' + @Company + '''
		WHERE v.VNDCHKNM LIKE ''Raistone Purchasing LLC%''
			AND ofile.HOLD = 0 -- do not send items that are on hold
			AND ofile.CURTRXAM > 0 -- do not send anything to Raistone we already paid for some reason
			AND ofile.DOCTYPE <> 5 -- remove credit memos, these get applied to invoices in house and are not communicated'

	INSERT INTO @RaistoneExtract
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
INTO	##tmpRaistoneData
FROM	(
		SELECT	'"' + RTRIM(BuyerName) + '"'
				+ ',' + RTRIM(SourceSystem)
				+ ',"' + RTRIM(SupplierName) + '"'
				+ ',' + RTRIM(SupplierId)
				+ ',' + RTRIM(Type)
				+ ',' + FORMAT(InvoiceDate,'MM/dd/yyyy')
				+ ',' + RTRIM(Currency)
				+ ',' + CASE
					WHEN PaymentDate IS NULL THEN ''
					WHEN DATEDIFF(DAY,PaymentDate,InvoiceDate) < 20 THEN FORMAT(DATEADD(DAY,30,InvoiceDate),'MM/dd/yyyy') 
					ELSE FORMAT(PaymentDate,'MM/dd/YYYY')
					END
				+ ',' + RTRIM(SupplierReference)
				+ ',' + RTRIM(InvoiceStatus)
				+ ',' + CAST(InvoiceAmount AS Varchar)
				+ ',' + CAST(Discount AS Varchar)
				+ ',' + RTRIM(InvoiceId)
				+ ',' + RTRIM(InternalReferenceNote) AS TextValue
		FROM	@RaistoneExtract
		) DATA
ORDER BY 1

SET @Query = '"SELECT ''BuyerName,SourceSystemBuyerId,SupplierName,SourceSystemSupplierId,Type,InvoiceIssueDate,Currency,ExpectedPaymentDate,SupplierInvoiceNumber,InvoiceStatus,InvoiceAmount,DiscountAmount,SourceSystemDocumentId,InternalReferenceNote'' '
SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpRaistoneData" QUERYOUT \\PRIAPINT01P\Shared\Raistone\IN_' + @DatePortion + '_IMCCompanies_27000.csv -c -t, -T'

EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output

IF OBJECT_ID('tempdb..##tmpRaistoneData') IS NOT NULL 
	DROP TABLE ##tmpRaistoneData
