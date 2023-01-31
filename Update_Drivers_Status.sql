-- DELETE GPVENDORS WHERE COMPANY NOT IN ('AIS', 'IMC')
-- TRUNCATE TABLE VendorMaster
-- SELECT * FROM VendorMaster
--INSERT INTO VendorMaster (Company, VendorId, HireDate, TerminationDate
/*
SELECT * FROM GPVendors

INSERT INTO VendorMaster (Company, VendorId, HireDate, TerminationDate, SubType, ApplyRate, Rate, ApplyAmount, Amount, ModifiedBy, ModifiedOn)
SELECT	Company,
		DriverId,
		HireDate,
		TerminationDate,
		CASE WHEN Rate IS Null OR Rate = 0 THEN 1 ELSE 2 END,
		CASE WHEN Rate IS Null OR Rate = 0 THEN 0 ELSE 1 END,
		ISNULL(Rate, 0),
		CASE WHEN Amount IS Null OR Amount = 0 THEN 0 ELSE 1 END,
		ISNULL(Amount, 0),
		'CFLORES',
		GETDATE()
FROM	GPVendors
*/

-- SELECT Hold, * FROM ais.dbo.PM00200

UPDATE	IMC.dbo.PM00200
SET		Hold = 1
FROM	VendorMaster VM
WHERE	PM00200.VendorId = VM.VendorId AND
		VM.TerminationDate IS NOT Null AND
		VM.Company = 'IMC'