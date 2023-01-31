USE [GPCustom]
GO

DECLARE	@DateIni	Date = '01/01/2022',
		@DateEnd	Date = '03/24/2022',
		@Company	Varchar(5),
		@Query		Varchar(3000)

DECLARE @tblData	Table (
		Company		Varchar(5),
		VendorId	Varchar(15),
		TransType	Varchar(15),
		Counter		Int,
		Amount		Numeric(12,2))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	GPCustom.dbo.Companies 
WHERE	Trucking = 1
		AND IsTest = 0
		AND CompanyId NOT IN ('GSA','NDS')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Company ' + @Company

	SET @Query = N'SELECT ''' + @Company + ''' AS Company, VENDORID,
		CASE DOCTYPE WHEN 1 THEN ''Invoice''
					 WHEN 4 THEN ''Return''
					 WHEN 5 THEN ''Credit Memo''
					 ELSE ''Payment'' END AS TransType,
		COUNT(*) AS Counter,
		SUM(DOCAMNT) AS Amount
FROM	(
		SELECT	VENDORID, DOCNUMBR, DOCAMNT, DOCTYPE
		FROM	' + @Company + '.dbo.PM20000
		WHERE	DOCDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
				AND VOIDED = 0
		UNION
		SELECT	VENDORID, DOCNUMBR, DOCAMNT, DOCTYPE
		FROM	' + @Company + '.dbo.PM20000
		WHERE	DOCDATE BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + ''' 
				AND VOIDED = 0
		) DATA
GROUP BY VENDORID,
		CASE DOCTYPE WHEN 1 THEN ''Invoice''
					 WHEN 4 THEN ''Return''
					 WHEN 5 THEN ''Credit Memo''
					 ELSE ''Payment'' END
ORDER BY 2, 3'
		
	INSERT INTO @tblData
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies 

SELECT	Company, VendorId, 
		SUM(IIF(TransType = 'Invoice', Amount, 0)) AS Invoice_Amount, 
		SUM(IIF(TransType = 'Invoice', Counter, 0)) AS Invoice_Count, 
		SUM(IIF(TransType = 'Credit Memo', Amount * - 1, 0)) AS CrdMemo_Amount, 
		SUM(IIF(TransType = 'Credit Memo', Counter, 0)) AS CrdMemo_Count, 
		SUM(IIF(TransType = 'Payment', Amount * -1, 0)) AS Payment_Amount, 
		SUM(IIF(TransType = 'Payment', Counter, 0)) AS Payment_Count
FROM	@tblData
GROUP BY Company, VendorId
ORDER BY 1, 2