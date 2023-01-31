DECLARE @Company		Varchar(5) = 'IILS',
		@VendorId		Varchar(15) = '463'

SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX)

DECLARE	@tblVndData		Table (
		Company			Varchar(5),
		VendorId		Varchar(15),
		VendorName		Varchar(75),
		FiscalPeriod	Char(7),
		DocumentType	Varchar(15),
		Document		Varchar(30),
		DocDate			Date,
		PostingDate		Date,
		Amount			Numeric(10,2),
		Balance			Numeric(10,2),
		TransDescript	Varchar(30),
		SourceTable		Varchar(10))

SET @Query = N'SELECT	*
FROM	(
		SELECT	''' + @Company + ''' AS Company,
				APP.VENDORID AS VendorId,
				RTRIM(VND.VENDNAME) AS VendorName,
				RIGHT(RTRIM(FISC.GP_Period), 4) + ''-'' + LEFT(FISC.GP_Period, 2) AS FiscalPeriod,
				CASE APP.DOCTYPE WHEN 1 THEN ''Invoice''
								 WHEN 4 THEN ''Return''
								 WHEN 5 THEN ''Credit Memo''
								 ELSE ''Payment'' END AS DocumentType,
				APP.DOCNUMBR AS Document,
				CAST(APP.DOCDATE AS Date) AS DocDate,
				CAST(APP.POSTEDDT AS Date) AS PostingDate,
				CAST(APP.DOCAMNT AS Numeric(10,2)) * IIF(APP.DOCTYPE = 1, 1, -1) AS Amount,
				CAST(APP.CURTRXAM AS Numeric(10,2)) * IIF(APP.DOCTYPE = 1, 1, -1) AS Balance,
				RTRIM(APP.TRXDSCRN) AS TransDescription,
				''Open'' AS SourceTable
		FROM	' + @Company + '.dbo.PM20000 APP
				INNER JOIN ' + @Company + '.dbo.PM00200 VND ON APP.VENDORID = VND.VENDORID
				LEFT JOIN Dynamics.dbo.View_FiscalPeriod FISC ON APP.POSTEDDT BETWEEN FISC.StartDate AND FISC.EndDate 
		WHERE	APP.VENDORID = ''' + @VendorId + ''' 
				AND APP.VOIDED = 0
		UNION
		SELECT	''' + @Company + ''' AS Company,
				APP.VENDORID AS VendorId,
				RTRIM(VND.VENDNAME) AS VendorName,
				RIGHT(RTRIM(FISC.GP_Period), 4) + ''-'' + LEFT(FISC.GP_Period, 2) AS FiscalPeriod,
				CASE APP.DOCTYPE WHEN 1 THEN ''Invoice''
								 WHEN 4 THEN ''Return''
								 WHEN 5 THEN ''Credit Memo''
								 ELSE ''Payment'' END AS DocumentType,
				APP.DOCNUMBR AS Document,
				CAST(APP.DOCDATE AS Date) AS DocDate,
				CAST(APP.POSTEDDT AS Date) AS PostingDate,
				CAST(APP.DOCAMNT AS Numeric(10,2)) * IIF(APP.DOCTYPE = 1, 1, -1) AS Amount,
				CAST(APP.CURTRXAM AS Numeric(10,2)) * IIF(APP.DOCTYPE = 1, 1, -1) AS Balance,
				RTRIM(APP.TRXDSCRN) AS TransDescription,
				''History'' AS SourceTable
		FROM	' + @Company + '.dbo.PM30200 APP
				INNER JOIN ' + @Company + '.dbo.PM00200 VND ON APP.VENDORID = VND.VENDORID
				LEFT JOIN Dynamics.dbo.View_FiscalPeriod FISC ON APP.POSTEDDT BETWEEN FISC.StartDate AND FISC.EndDate 
		WHERE	APP.VENDORID = ''' + @VendorId + ''' 
				AND APP.VOIDED = 0
		) DATA
ORDER BY Vendorid, FiscalPeriod, DocDate'

INSERT INTO @tblVndData
EXECUTE(@Query)

SELECT	*
FROM	@tblVndData