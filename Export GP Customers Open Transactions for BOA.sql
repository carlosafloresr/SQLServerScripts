SET NOCOUNT ON

DECLARE	@Company			Varchar(5),
		@CompanyAlias		Varchar(10),
		@CompanyNumber		Int,
		@CustomerNumber		Varchar(15),
		@InvoiceNumber		Varchar(30),
		@Result				Int,
		@Query				Varchar(MAX),
		@DOSCommand			Varchar(4000),
		@DatePortion		Char(6) = dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(dbo.PADL(YEAR(GETDATE()), 4, '0'), 2)

DECLARE	@tblCustomers		Table (
		Company_Code		Varchar(5),
		Customer_Number		Varchar(20),
		Customer_Name		Varchar(100),
		National_Account	Varchar(20),
		Invoice_Number		Varchar(25),
		Transaction_Type	Varchar(20),
		Invoice_Amount		Numeric(10,2),
		Credit_Debit		Char(1),
		Open_Amount			Numeric(10,2),
		Currency			Char(3),
		Invoice_Date		Date,
		Due_Date			Date,
		Fiscal_Year			Char(4),
		Purchase_Order		Varchar(30),
		BookingNumber		Varchar(30),
		Billing_Ref			Varchar(30),
		Container_ID		Varchar(20),
		WorkOrderNum		Varchar(20) Null)

DECLARE	@tblOrder			Table (OrderNumber Int)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyID) AS CompanyId
FROM	DYNAMICS.dbo.View_Companies
WHERE	CompanyID IN ('AIS', 'DNJ', 'GIS', 'HMIS', 'IMC', 'OIS', 'PDS', 'GLSO')
ORDER BY 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	@CompanyAlias	= CompanyAlias, 
			@CompanyNumber	= CompanyNumber 
	FROM	GPCustom.dbo.View_CompaniesAndAgents 
	WHERE	CompanyId = @Company

	SET @Query = N'SELECT ''' + @CompanyAlias + ''' AS Company,
		TRA.CUSTNMBR,
		CUS.CUSTNAME,
		TRA.CPRCSTNM,
		RTRIM(TRA.DOCNUMBR) AS DOCNUMBR,
		CASE TRA.RMDTYPAL 
			WHEN 1 THEN ''INVOICE''
			WHEN 3 THEN ''DEBIT MEMO''
			WHEN 7 THEN ''CREDIT MEMO''
			WHEN 8 THEN ''RETURN''
			WHEN 9 THEN ''PAYMENT''
		END,
		TRA.ORTRXAMT,
		IIF(TRA.RMDTYPAL < 7, ''D'', ''C''),
		TRA.CURTRXAM,
		''USD'',
		TRA.DOCDATE,
		TRA.DUEDATE,
		YEAR(TRA.POSTDATE),
		'''' AS Purchase_Ord,
		'''' AS BookingNumber,
		ISNULL(FSI.BillToRef, '''') AS Billing_Ref,
		ISNULL(FSI.Equipment, '''') AS Container_ID,
		ISNULL(FSI.WorkOrder, '''') AS WorkOrderNum
FROM	' + @Company + '.dbo.RM20101 TRA
		INNER JOIN ' + @Company + '.dbo.RM00101 CUS ON TRA.CUSTNMBR = CUS.CUSTNMBR
		LEFT JOIN PRISQL004P.Integrations.dbo.FSI_ReceivedDetails FSI ON TRA.CUSTNMBR = FSI.CustomerNumber AND TRA.DOCNUMBR = FSI.InvoiceNumber
WHERE	TRA.CURTRXAM <> 0'
	
	INSERT INTO @tblCustomers
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DROP TABLE IF EXISTS ##tmpBOACustomerBalances;

SELECT	*
INTO	##tmpBOACustomerBalances
FROM	(
		SELECT	Company_Code + '|' + RTRIM(Customer_Number) 
				+ '|' + RTRIM(Customer_Name) 
				+ '|' + RTRIM(National_Account)
				+ '|' + RTRIM(Invoice_Number) + '|' + Transaction_Type
				+ '|' + CAST(Invoice_Amount AS Varchar)
				+ '|' + Credit_Debit
				+ '|' + CAST(Open_Amount AS Varchar)
				+ '|' + Currency
				+ '|' + CONVERT(Char(10), Invoice_Date, 101)
				+ '|' + CONVERT(Char(10), Due_Date, 101)
				+ '|' + Fiscal_Year
				+ '|' +	Purchase_Order
				+ '|' + BookingNumber
				+ '|' + Billing_Ref
				+ '|' + Container_ID 
				+ '|' + WorkOrderNum AS TextValue,
				ROW_NUMBER() OVER(ORDER BY Company_Code, Customer_Name, Invoice_Number) AS RowCounter
		FROM	@tblCustomers
		) DATA
ORDER BY 2

SET @Query = '"SELECT ''Company_Code|Customer_Number|Customer_Name|National_Account|Invoice_Number|Transaction_Type|Invoice_Amount|Credit_Debit|Open_Amount|Currency|Invoice_Date|Due_Date|Fiscal_Year|Purchase_Order|BookingNumber|Billing_Ref|Container_ID|WorkOrderNum'' '
SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpBOACustomerBalances" QUERYOUT \\d5j5mw52\TEMP\IMCC_Open_AR_' + @DatePortion + '.txt -c -t, -T'
-- \\priapint01p\bankfiles$\Outbound\OpenAr
--PRINT @DOSCommand
EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output

-- SELECT * FROM ##tmpBOACustomerBalances

DROP TABLE IF EXISTS ##tmpBOACustomerBalances;