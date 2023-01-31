/*
SELECT * FROM VendorMaster order by Company, VendorId
SELECT * FROM GIS.dbo.PM00200 WHERE VndClsId = 'DRV'
*/
/*
DECLARE	@Company Varchar(5)
SET @Company = 'NDS'

UPDATE	VendorMaster 
SET		Company = @Company
WHERE	VendorId IN (SELECT VendorId FROM NDS.dbo.PM00200 WHERE VndClsId = 'DRV')

DECLARE	@Company Varchar(5)
SET @Company = 'IMC'

DELETE	VendorMaster 
WHERE	Company = @Company
		AND VendorId NOT IN (SELECT VendorId FROM IMC.dbo.PM00200 WHERE VndClsId = 'DRV')

*/
DELETE	VendorMaster
FROM	(
SELECT	VEN.VendorId
		,VEN.Company
		,MAX(VEN.ModifiedOn) AS ModifiedOn
FROM	VendorMaster VEN
		INNER JOIN (SELECT	VendorId
							,Company
							,COUNT(VendorId) AS Counter
					FROM	VendorMaster 
					GROUP BY VendorId, Company
					HAVING COUNT(VendorId) > 1) CNT ON VEN.VendorId = CNT.VendorId AND VEN.Company = CNT.Company
GROUP BY VEN.VendorId, VEN.Company) DUP
WHERE	VendorMaster.VendorId = DUP.VendorId 
		AND VendorMaster.Company = DUP.Company
		AND VendorMaster.ModifiedOn = DUP.ModifiedOn