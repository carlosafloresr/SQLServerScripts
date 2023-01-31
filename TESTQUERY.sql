ALTER PROCEDURE USP_DriversWithBalance
	@DataBase	Char(10),
	@VndClsId 	Char(6),
	@Account	Char(15)
AS
DECLARE	@Query		Varchar(2000)
SET	@Query		= 'SELECT VendName, PM.VendorId, CASE WHEN Ten99Type = 4 THEN ''YES'' ELSE ''NO'' END AS IS1099, CAST(Balance AS Char(10)) AS Balance FROM ' + @DataBase + 
	'.dbo.PM00200 PM INNER JOIN GPCustom.dbo.View_EscrowBalances_ForInterest EI ON PM.VendorId = EI.VendorId AND EI.AccountNumber = ''' +	@Account + ''' AND ' +
	'EI.CompanyId = ''' + @DataBase + ''' WHERE VendStts = 1 AND VndClsId = ''' + @VndClsId + ''' ORDER BY PM.VendorId'
EXECUTE (@Query)
GO

/*

EXECUTE USP_DriversWithBalance 'AISTE', 'DDD', '0-00-2790'

SELECT 	VendName, 
	VendorId, 
	CASE WHEN Ten99Type = 4 THEN 'YES' ELSE 'NO' END AS IS1099 
FROM 	(FRTES.DBO.PM00200 
WHERE 	VendStts = 1 AND 
	VndClsId = 'DDD'
ORDER BY VendorId
*/

print CAST(Balance AS SmallMoney)