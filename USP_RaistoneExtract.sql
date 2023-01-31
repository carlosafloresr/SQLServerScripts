 USE GPCUSTOM
GO

/*
****************************************************************
	GP AP OPEN TRANSACTIONS EXPORT FOR RAISTONE (RAPID PAY)
****************************************************************
	 CREATED BY: BRIAN CATT			     CREATED ON: 01/10/2022
****************************************************************
	MODIFIED BY: CARLOS A FLORES		MODIFIED ON: 08/12/2022
   MODIFICATION: The log company was changed to save using the DB 
   name instead the company id. And under the csv export use the 
   company id instead the db name
****************************************************************
	MODIFIED BY: CARLOS A FLORES		MODIFIED ON: 12/20/2022
   MODIFICATION: Added an option to just send the daily process 
   email for situations were the email fails to submit.
****************************************************************
EXECUTE GPCustom.dbo.USP_RaistoneExtract 1
****************************************************************
*/
ALTER PROCEDURE USP_RaistoneExtract 
		@JustSendEmail	Bit = 0
WITH EXECUTE AS OWNER AS 
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
		@FileName		Varchar(150),
		@tmpFileName	Varchar(200),
		@RunDate		Date = GETDATE()

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

IF @JustSendEmail = 0
BEGIN
	DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT LTRIM(RTRIM(CompanyId))
	FROM	GPCustom.dbo.Companies 
	WHERE	CompanyId IN (SELECT CompanyId FROM GPCustom.dbo.Companies_Parameters WHERE ParameterCode = 'RAISTONE' AND ParBit = 1)

	OPEN curCompanies 
	FETCH FROM curCompanies INTO @Company

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		--Modifed by Carlos A. Flores on 08/12/2022: Changed back the Company Id for the DB name
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

	SET @FileName = '\\priapint01p\shared\Raistone\All\IN_' + @DatePortion + '_IMCCompanies_' + RTRIM(@DaySeconds) + '_ALL.csv'

	SELECT	*
	INTO	##tmpRaistoneDataAll
	FROM	(
			SELECT	DISTINCT '"' + RTRIM(MAIN.BuyerName) + '"'
					+ ',' + CASE WHEN MAIN.SourceSystem = 'IMC' THEN 'IMCG' ELSE MAIN.SourceSystem END --Modifed by Carlos A. Flores on 08/12/2022: Export the Company Id instead the DB name
					+ ',"' + RTRIM(MAIN.SupplierName) + '"'
					+ ',' + RTRIM(MAIN.SupplierId)
					+ ',' + RTRIM(MAIN.Type)
					+ ',' + FORMAT(MAIN.InvoiceDate,'MM/dd/yyyy')
					+ ',' + RTRIM(MAIN.Currency)
					+ ',' + CASE
						WHEN MAIN.PaymentDate IS NULL THEN ''
						WHEN DATEDIFF(DAY,MAIN.PaymentDate,MAIN.InvoiceDate) < 20 THEN FORMAT(DATEADD(DAY,30,MAIN.InvoiceDate),'MM/dd/yyyy') 
						ELSE FORMAT(MAIN.PaymentDate,'MM/dd/YYYY')
						END
					+ ',"' + RTRIM(MAIN.SupplierReference) + '"'
					+ ',' + RTRIM(MAIN.InvoiceStatus)
					+ ',' + CAST(MAIN.InvoiceAmount AS Varchar)
					+ ',' + CAST(MAIN.Discount AS Varchar)
					+ ',"' + RTRIM(MAIN.InvoiceId) + '"'
					+ ',' + RTRIM(MAIN.InternalReferenceNote) 
					+ ',' + IIF(BKP.SupplierId IS Null, 'N', 'Y') AS TextValue
			FROM	@RaistoneExtract MAIN
					LEFT JOIN (SELECT DISTINCT SourceSystem, SourceReference, SupplierId FROM Raistone_DailyExtract) BKP ON MAIN.SourceSystem = BKP.SourceSystem AND MAIN.SourceReference = BKP.SourceReference AND MAIN.SupplierId = BKP.SupplierId
			) DATA
	ORDER BY 1

	SET @Query = '"SELECT ''BuyerName,SourceSystemBuyerId,SupplierName,SourceSystemSupplierId,Type,InvoiceIssueDate,Currency,ExpectedPaymentDate,SupplierInvoiceNumber,InvoiceStatus,InvoiceAmount,DiscountAmount,SourceSystemDocumentId,InternalReferenceNote'' '
	SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpRaistoneDataAll" QUERYOUT ' + @FileName + ' -c -t, -T'

	EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output

	IF OBJECT_ID('tempdb..##tmpRaistoneDataAll') IS NOT NULL 
		DROP TABLE ##tmpRaistoneDataAll

	--DELETE	Raistone_DailyExtract
	--WHERE	ImportedOn NOT IN (SELECT DISTINCT TOP 2 ImportedOn FROM Raistone_DailyExtract ORDER BY ImportedOn DESC)

	DELETE	@RaistoneExtract
	WHERE	SourceSystem + '_' + SourceReference + '_' + SupplierId IN (SELECT SourceSystem + '_' + SourceReference + '_' + SupplierId FROM Raistone_DailyExtract)

	SELECT	@Counter	= COUNT(*),
			@Amount		= SUM(InvoiceAmount)
	FROM	@RaistoneExtract

	IF @Counter > 0
	BEGIN
		SET @FileName = '\\PRIAPINT01P\Shared\Raistone\IN_' + @DatePortion + '_IMCCompanies_' + RTRIM(@DaySeconds) + '.csv'

		SET @tmpFileName = REPLACE(@FileName, '\\PRIAPINT01P\Shared\Raistone\', '')

		INSERT INTO [dbo].[Raistone_DailyExtract]
				([Destination]
				,[BuyerName]
				,[SourceSystem]
				,[SourceReference]
				,[SupplierName]
				,[SupplierId]
				,[Type]
				,[InvoiceDate]
				,[Currency]
				,[PaymentDate]
				,[InvoiceId]
				,[InvoiceStatus]
				,[InvoiceAmount]
				,[Discount]
				,[SupplierReference]
				,[InternalReferenceNote]
				,[DEX_ROW_ID])
		SELECT	[Destination]
				,[BuyerName]
				,[SourceSystem]
				,[SourceReference]
				,[SupplierName]
				,[SupplierId]
				,[Type]
				,[InvoiceDate]
				,[Currency]
				,[PaymentDate]
				,[InvoiceId]
				,[InvoiceStatus]
				,[InvoiceAmount]
				,[Discount]
				,[SupplierReference]
				,[InternalReferenceNote]
				,[DEX_ROW_ID]
		FROM	@RaistoneExtract

		IF NOT EXISTS(SELECT FileName FROM Raistone_DailyExtract_Files WHERE FileDate = @RunDate)
		BEGIN
			INSERT INTO Raistone_DailyExtract_Files 
					([FileRows], [FileAmount], [FileName], [FileDate])
			VALUES
					(@Counter, @Amount, @tmpFileName, @RunDate)
		END
	END
	ELSE
	BEGIN
		SET @FileName = '*** No file exported ***'
		SET @Amount = 0
	END
END
ELSE
BEGIN
	SELECT	@Counter	= [FileRows],
			@Amount		= [FileAmount],
			@FileName	= [FileName]
	FROM	Raistone_DailyExtract_Files
	WHERE	FileDate	= @RunDate
END

SET @Body = @HTMLTable
SET @Body = @Body + '<tr><td style="text-align:center;background-color:Yellow;width:100px;">Export Date</td>'
SET @Body = @Body + '<td style="text-align:center;background-color:Yellow;width:100px;">Invoices Count</td>'
SET @Body = @Body + '<td style="text-align:center;background-color:Yellow;width:100px;">Invoices Amount</td>'
SET @Body = @Body + '<td style="text-align:center;background-color:Yellow;width:250px;">File Name</td></tr>'

SET @Body = @Body + '<tr><td style="text-align:center;color:blue;vertical-align:top;">' + FORMAT(GETDATE(),'d', 'en-US') + '</td>'
SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + CAST(@Counter AS Varchar) + '</td>'
SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">$ ' + FORMAT(@Amount,'n2') + '</td>'
SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + REPLACE(@FileName, '\\PRIAPINT01P\Shared\Raistone\', '') + '</td></tr>'

SET @Body = @Body + '</table></body></html>'

IF @Counter > 0 AND @JustSendEmail = 0
BEGIN
	SELECT	*
	INTO	##tmpRaistoneData
	FROM	(
			SELECT	'"' + RTRIM(BuyerName) + '"'
					+ ',' + CASE WHEN SourceSystem = 'IMC' THEN 'IMCG' ELSE SourceSystem END --Modifed by Carlos A. Flores on 08/12/2022: Export the Company Id instead the DB name
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
					+ ',"' + RTRIM(SupplierReference) + '"'
					+ ',' + RTRIM(InvoiceStatus)
					+ ',' + CAST(InvoiceAmount AS Varchar)
					+ ',' + CAST(Discount AS Varchar)
					+ ',"' + RTRIM(InvoiceId) + '"'
					+ ',' + RTRIM(InternalReferenceNote) AS TextValue
			FROM	@RaistoneExtract
			) DATA
	ORDER BY 1

	--New file header
	SET @Query = '"SELECT ''Buyer_Name,Source_System_Buyer_ID,SupplierName,Source_System_Supplier_ID,TYPE,Invoice Issue Date,CURRENCY,Expected Payment Date,Supplier Invoice Number,Invoice Status,Invoice Amount,Discount Amount,Source_System_Document_ID,Internal Reference'' '
	SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpRaistoneData" QUERYOUT ' + @FileName + ' -c -t, -T'

	EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output
	
	IF OBJECT_ID('tempdb..##tmpRaistoneData') IS NOT NULL 
		DROP TABLE ##tmpRaistoneData
END

PRINT 'Counter: ' + CAST(@Counter AS Varchar)
PRINT 'Error #: ' + CAST(@@ERROR AS Varchar)

IF @@ERROR = 0
BEGIN
	EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'GP Notifications2',  
									@recipients = @Email,
									@copy_recipients = @EmailCC,
									@subject = @EmailSubject,
									@body_format = 'HTML',
									@body = @Body
END