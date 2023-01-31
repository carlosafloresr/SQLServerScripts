UPDATE	VendorMaster
SET		VendorMaster.Division = LTRIM(RTRIM(ActiveDrivers.Division)),
		VendorMaster.TerminationDate = Null
FROM	ActiveDrivers
WHERE	VendorMaster.VendorId = ActiveDrivers.VendorId
		AND VendorMaster.Company = ActiveDrivers.Company

update VendorMaster set TerminationDate = '1/1/1980' WHERE VendorId NOT IN (SELECT VendorId FROM ActiveDrivers) AND TerminationDate IS NULL

SELECT * FROM VendorMaster WHERE TerminationDate IS NULL ORDER BY VendorId

