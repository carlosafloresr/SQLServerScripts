SET NOCOUNT ON

DECLARE	@Company	Varchar(5),
		@DateIni	Char(10) = '01/01/2019',
		@DateEnd	Char(10) = '12/31/2019',
		@Query		Varchar(Max)

DECLARE @tblVendors	Table (
		Company		Varchar(5),
		VendorId	Varchar(15),
		VendorName	Varchar(100),
		TaxId		Varchar(20))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId) AS Company
FROM	Dynamics.dbo.View_AllCompanies 
WHERE	InterId NOT IN ('ATEST','ABS','HIS01','HIS04','ITEST','IILS')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = 'SELECT ''' + @Company + ''', VENDORID, VENDNAME, IIF(TXIDNMBR = '''', VENDORID, TXIDNMBR) FROM ' + @Company + '.dbo.PM00200 WHERE VNDCLSID <> ''DRV'' AND VENDNAME <> ''ADP'' ORDER BY VENDORID'
	
	INSERT INTO @tblVendors
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DECLARE @tblVndData	Table (
		Company		Varchar(5),
		VendorId	Varchar(15),
		Amount		Numeric(10,2),
		Payments	Numeric(10,2))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId) AS Company
FROM	Dynamics.dbo.View_AllCompanies 
WHERE	InterId NOT IN ('ATEST','ABS','HIS01','HIS04','ITEST','IILS')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SELECT	VendorId
	INTO	#tmpVendors
	FROM	@tblVendors
	WHERE	Company = @Company

	SET @Query = 'SELECT TOP 500 COMPANY, VENDORID, SUM(DOCAMNT) AS AMOUNT, SUM(PAYMENT) AS PAYMENT FROM (SELECT ''' + @Company + ''' AS COMPANY, VENDORID, SUM(DOCAMNT) AS DOCAMNT, SUM(IIF(CURTRXAM <> DOCAMNT, ABS(CURTRXAM - DOCAMNT), 0)) AS PAYMENT FROM ' + @Company + '.dbo.PM20000 WHERE DOCTYPE < 5 AND VOIDED = 0 AND DOCDATE BETWEEN ''' + @DateIni + ''' AND ''' + @DateEnd + ''' AND VENDORID IN (SELECT VENDORID FROM #tmpVendors) GROUP BY VENDORID'
	SET @Query = @Query + ' UNION SELECT ''' + @Company + ''' AS COMPANY, VENDORID, SUM(DOCAMNT) AS DOCAMNT, SUM(IIF(CURTRXAM <> DOCAMNT, ABS(CURTRXAM - DOCAMNT), 0)) AS PAYMENT FROM ' + @Company + '.dbo.PM30200 WHERE DOCTYPE < 5 AND VOIDED = 0 AND DOCDATE BETWEEN ''' + @DateIni + ''' AND ''' + @DateEnd + ''' AND VENDORID IN (SELECT VENDORID FROM #tmpVendors) GROUP BY VENDORID) DATA GROUP BY COMPANY, VENDORID ORDER BY 3 DESC'
	
	INSERT INTO @tblVndData
	EXECUTE(@Query)

	DROP TABLE #tmpVendors

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	TOP 100 VND.Company,
		VND.VendorId,
		VND.VendorName,
		DAT.Amount,
		DAT.Payments
FROM	@tblVndData DAT
		INNER JOIN @tblVendors VND ON DAT.Company = VND.Company AND DAT.VendorId = VND.VendorId
ORDER BY Amount DESC

--SELECT	VND.Company,
--		VND.VendorId,
--		VND.VendorName,
--		DAT.TaxId,
--		DAT.Amount
--FROM	(
--		SELECT	TOP 100 DAT.TaxId,
--				SUM(Amount) AS Amount
--		FROM	(
--				SELECT	VND.Company,
--						VND.VendorId,
--						VND.TaxId,
--						DAT.Amount
--				FROM	@tblVndData DAT
--						INNER JOIN @tblVendors VND ON DAT.Company = VND.Company AND DAT.VendorId = VND.VendorId
--				) DAT
--		GROUP BY DAT.TaxId
--		) DAT
--		INNER JOIN @tblVendors VND ON DAT.TaxId = VND.TaxId
--ORDER BY 5 DESC