DECLARE	@Company		Varchar(5) = 'AIS',
		@ProNumber		Varchar(30),
		@Document		Varchar(30),
		@Reference		Varchar(40),
		@Query			Varchar(MAX)

SET NOCOUNT ON

DECLARE @tblOpenARData	Table (
		Company				Varchar(5),
		CustomerId			Varchar(25),
		CustomerName		Varchar(75),
		DocumentNumber		Varchar(30),
		Type				Varchar(10),
		DocDate				Date,
		Amount				Numeric(10,2),
		Balance				Numeric(10,2),
		Age					Smallint,
		Due					Numeric(10,2),
		[0_to_30_Days]		Numeric(10,2),
		[31_to_60_Days]		Numeric(10,2),
		[61_to_90_Days]		Numeric(10,2),
		[91_to_180_Days]	Numeric(10,2),
		[181_and_Over]		Numeric(10,2),
		PerDiem				Char(3),
		ProNumber			Varchar(20),
		Container			Varchar(25),
		ReferenceNum		Varchar(40),
		DriverId			Varchar(20))

SET @Query = N'SELECT ''' + RTRIM(@Company) + ''' AS Company,
		TRA.CUSTNMBR AS CustomerId,
		CUS.CUSTNAME AS CustomerName,
		TRA.DOCNUMBR AS DocumentNumber,
		CUS.CUSTCLAS AS Type,
		CAST(TRA.DOCDATE AS Date) AS Date,
		CAST(TRA.ORTRXAMT AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) AS Amount,
		CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) AS Balance,
		DATEDIFF(dd, TRA.DOCDATE, GETDATE()) AS Age,
		CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) AS Due,
		CASE WHEN TRA.DUEDATE <= 30 THEN CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) ELSE 0 END [0_to_30_Days],
		CASE WHEN TRA.DUEDATE BETWEEN 31 AND 60 THEN CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) ELSE 0 END [31_to_60_Days],
		CASE WHEN TRA.DUEDATE BETWEEN 61 AND 90 THEN CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) ELSE 0 END [61_to_90_Days],
		CASE WHEN TRA.DUEDATE BETWEEN 91 AND 180 THEN CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) ELSE 0 END [91_to_180_Days],
		CASE WHEN TRA.DUEDATE > 180 THEN CAST(TRA.CURTRXAM AS Numeric(10,2)) * IIF(TRA.RMDTYPAL = 1, 1, -1) ELSE 0 END [181_and_Over],
		IIF(TRA.CUSTNMBR LIKE ''PD%'', ''YES'', ''NO'') AS PerDiem,
		ISNULL(RTRIM(INV.ProNumber), '''') AS ProNumber,
		--ISNULL(INV.ChassisNumber, '''') AS ChassisNumber,
		ISNULL(INV.TrailerNumber, '''') AS Container,
		ISNULL(INV.AuthorizationNumber, '''') AS ReferenceNum,
		ISNULL(INV.VendorId, '''') AS DriverId
FROM	' + RTRIM(@Company) + '.dbo.RM20101 TRA
		INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00101 CUS ON TRA.CUSTNMBR = CUS.CUSTNMBR
		LEFT JOIN GPCustom.dbo.SalesInvoices INV ON TRA.CUSTNMBR = INV.CustomerId AND TRA.DOCNUMBR = INV.InvoiceNumber AND INV.CompanyId = ''' + RTRIM(@Company) + '''
WHERE	TRA.CUSTNMBR LIKE ''PD%''
ORDER BY TRA.CUSTNMBR, TRA.DOCDATE, TRA.DOCNUMBR'

INSERT INTO @tblOpenARData
EXECUTE(@Query)

DECLARE curGPDataRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(ProNumber), RTRIM(DocumentNumber)
FROM	@tblOpenARData
WHERE	ProNumber <> ''
		AND ReferenceNum = ''

OPEN curGPDataRecords 
FETCH FROM curGPDataRecords INTO @ProNumber, @Document

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	@Reference = RTRIM(BilltoRef)
	FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Sales
	WHERE	Company = @Company
			AND InvoiceNumber = @ProNumber

	IF @Reference IS NOT Null
		UPDATE @tblOpenARData SET ReferenceNum = @Reference WHERE DocumentNumber = @Document AND (ProNumber = @ProNumber OR (LEFT(@ProNumber, 1) = '0' AND ProNumber = SUBSTRING(@ProNumber, 2, 20)))

	FETCH FROM curGPDataRecords INTO @ProNumber, @Document
END

CLOSE curGPDataRecords
DEALLOCATE curGPDataRecords

SELECT	*
FROM	@tblOpenARData

-- SELECT TOP 100 * FROM RM20101