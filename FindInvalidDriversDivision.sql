UPDATE	Drivers 
SET		Division = dbo.PADL(RTRIM(LTRIM(Division)), 2, '0')

SELECT	*
FROM	VendorMaster
WHERE	TerminationDate IS Null
		AND Division = '00'

WHERE	VendorId IN (SELECT VendorId FROM Drivers)

SELECT	*
FROM	Drivers
WHERE	VendorId IN (SELECT VendorId FROM VendorMaster)

SELECT	*
FROM	Drivers
WHERE	VendorId IN (SELECT VendorId FROM VendorMaster)

UPDATE	VendorMaster
SET		VendorMaster.Division = Drivers.Division	
FROM	Drivers
WHERE	VendorMaster.VendorId = Drivers.VendorId