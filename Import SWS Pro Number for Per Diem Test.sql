DECLARE	@Customer	Varchar(12),
		@Query		Varchar(MAX),
		@ProNumber	Varchar(20)

TRUNCATE TABLE PerDiemProNumbers

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT RTRIM(CustNmbr) AS CustNmbr
FROM	View_CustomerTiers 
WHERE	(CustNmbr IN (SELECT FreightBillTo FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE BillType > 0 AND FreightBillTo <> '' AND CompanyId = 'DNJ')
		OR CustNmbr IN (SELECT CustNmbr FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE BillType > 0 AND CompanyId = 'DNJ')
		OR CustNmbr IN (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'DNJ')
		OR CustomerNo IN (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'DNJ'))

OPEN curData
FETCH FROM curData INTO @Customer

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET	@Query = N'SELECT div_code as division, pro FROM TRK.Order WHERE shdate > ''2011/01/30'' AND bt_code = ''' + @Customer + ''' AND cmpy_no = 7 ORDER BY 1 LIMIT 25'
	
	EXECUTE dbo.USP_QuerySWS @Query, '##tmpData'

	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO PerDiemProNumbers
		SELECT	RTRIM(division) + '-' + rtrim(pro), @Customer
		FROM	##tmpData
		WHERE	RTRIM(division) + '-' + rtrim(pro) NOT IN (SELECT ProNumber FROM PerDiemProNumbers)
	END

	DROP TABLE ##tmpData
	
	FETCH FROM curData INTO @Customer
END

CLOSE curData
DEALLOCATE curData

SELECT	DISTINCT RTRIM(CustNmbr) AS CustNmbr
FROM	View_CustomerTiers 
WHERE	(CustNmbr IN (SELECT FreightBillTo FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE BillType > 0 AND FreightBillTo <> '' AND CompanyId = 'DNJ')
		OR CustNmbr IN (SELECT CustNmbr FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE BillType > 0 AND CompanyId = 'DNJ')
		OR CustNmbr IN (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'DNJ')
		OR CustomerNo IN (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'DNJ'))

SELECT * FROM PerDiemProNumbers