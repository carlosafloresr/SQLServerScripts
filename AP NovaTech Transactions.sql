/*
EXECUTE USP_APTransactions_NovaTech '01/01/2019', '11/15/2019'
*/
ALTER PROCEDURE USP_APTransactions_NovaTech
		@DateStart	Date,
		@DateEnd	Date
AS
DECLARE @Vendor1	Varchar(20) = '%Novatech%',
		@Vendor2	Varchar(20) = '%NovaCopy%',
		@Company	Varchar(5),
		@VendorId	Varchar(20),
		@Vendors	Varchar(500),
		@Query		Varchar(MAX)

DECLARE	@tblVendors	Table (Company Varchar(5), VendorId	varchar(20), VendorName Varchar(75))

DECLARE @tblData	Table (Company Varchar(5), VendorId	varchar(20), VendorName Varchar(75), InvoiceNumber Varchar(30), InvoiceDate Date, Amount Numeric(10,2), Paid Numeric(10,2), Balance Numeric(10,2), Description Varchar(30))

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	Companies 
WHERE	CompanyId NOT IN ('ABS','ATEST','FIDMO')

OPEN curData 
FETCH FROM curData INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + @Company + ''',RTRIM(VENDORID), RTRIM(VENDNAME) FROM ' + @Company + '.dbo.PM00200 WHERE VENDNAME LIKE ''' + @Vendor1 + ''' OR VENDNAME LIKE ''' + @Vendor2 + ''''
		
	INSERT INTO @tblVendors
	EXECUTE(@Query)

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT	VendorId 
		INTO	#tmpVneors
		FROM	@tblVendors
		WHERE	Company = @Company

		SET @Query = 'SELECT ''' + @Company + ''',RTRIM(P1.VENDORID) AS VendorId, RTRIM(VENDNAME) AS VENDNAME, docnumbr, DOCDATE, DOCAMNT, DOCAMNT - CURTRXAM AS PAID, CURTRXAM, RTRIM(TRXDSCRN) 
					FROM	' + @Company + '.dbo.PM30200 P1 
							INNER JOIN ' + @Company + '.dbo.PM00200 P2 ON P1.VENDORID = P2.VENDORID 
					WHERE	P1.VENDORID IN (SELECT VendorId FROM #tmpVneors) 
							AND P1.DOCDATE BETWEEN ''' + CONVERT(Char(10), @DateStart, 101) + ''' AND ''' + CONVERT(Char(10), @DateEnd, 101) + '''
					UNION 
					SELECT ''' + @Company + ''',RTRIM(P1.VENDORID) AS VendorId, RTRIM(VENDNAME) AS VENDNAME, docnumbr, DOCDATE, DOCAMNT, DOCAMNT - CURTRXAM AS PAID, CURTRXAM, RTRIM(TRXDSCRN) 
					FROM	' + @Company + '.dbo.PM20000 P1 
							INNER JOIN ' + @Company + '.dbo.PM00200 P2 ON P1.VENDORID = P2.VENDORID 
					WHERE	P1.VENDORID IN (SELECT VendorId FROM #tmpVneors) 
							AND P1.DOCDATE BETWEEN ''' + CONVERT(Char(10), @DateStart, 101) + ''' AND ''' + CONVERT(Char(10), @DateEnd, 101) + ''''

		INSERT INTO @tblData
		EXECUTE(@Query)

		DROP TABLE #tmpVneors
	END
	FETCH FROM curData INTO @Company
END

CLOSE curData
DEALLOCATE curData

SELECT	* 
FROM	@tblData
ORDER BY Company, InvoiceDate, VendorId

-- SELECT * FROM AIS.dbo.PM30200 P1 INNER JOIN AIS.dbo.PM00200 P2 ON P1.VENDORID = P2.VENDORID WHERE P1.VENDORID = '11631'