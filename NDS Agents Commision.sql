DECLARE	@Agent			Varchar(2) = '22',
		@DateIni		Date = '08/13/2017',
		@DateEnd		Date = '08/19/2017'

DECLARE	@Query			Varchar(MAX),
		@CountCD		Int,
		@CountInv		Int,
		@CountOrder		Int,
		@FuelRebate		Numeric(10,2)

SET @Query = N'SELECT INV.*, BRO.date_created, LOD.Loads FROM TRK.Invoice INV LEFT JOIN Public.grails_brokerage_order BRO ON INV.brokerage_order_id = BRO.id LEFT JOIN (SELECT Cmpy_No, Inv_code, COUNT(*) AS Loads '
SET @Query = @Query + 'FROM TRK.InvEquip GROUP BY Cmpy_No, Inv_code) LOD ON INV.Cmpy_No = LOD.Cmpy_No AND INV.Code = LOD.Inv_code WHERE INV.cmpy_no = ' + @Agent + ' AND INV.invdate BETWEEN ''' + CONVERT(Varchar, @DateIni, 102) + ''' AND ''' + CONVERT(Varchar, @DateEnd, 102) + ''' AND INV.type <> ''S'' AND INV.pdate IS NOT Null'

EXECUTE USP_QuerySWS @Query, '##tmpData'

SELECT	@CountCD = COUNT(*)
FROM	##tmpData
WHERE	type IN ('C','D')

SELECT	@CountOrder = COUNT(*)
FROM	##tmpData
WHERE	type not in ('C','D')
		AND brokerage_order_id is null

SELECT	@CountInv = COUNT(*)
FROM	##tmpData

SELECT	@FuelRebate = SUM(fcramt)
FROM	##tmpData

PRINT '   Invoices: ' + CAST(@CountInv AS Varchar)
PRINT '        C&D: ' + CAST(@CountCD AS Varchar)
PRINT '     Orders: ' + CAST(@CountOrder AS Varchar)
PRINT 'Fuel Rebate: ' + CAST(@FuelRebate AS Varchar)

SELECT	*, CASE WHEN type not in ('C','D') AND brokerage_order_id is null THEN ISNULL(Loads, 1) ELSE 0 END AS AllLoads
FROM	##tmpData
--WHERE	type not in ('C','D')
--		AND brokerage_order_id is null

DROP TABLE ##tmpData