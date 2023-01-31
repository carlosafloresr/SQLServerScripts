SELECT	OTRNumber,
		ProNumber,
		Chassis,
		DriverId,
		Division,
		Vendor,
		Repair,
		Failure_Description,
		SUM(Cost) AS Cost
FROM	(
		SELECT	OTRNumber,
				ProNumber,
				Chassis,
				DriverId,
				Division,
				VendorName AS Vendor,
				CASE WHEN TypeRepair = 1 THEN 'T' + Repair ELSE 'MECH' END AS Repair,
				ISNULL(Failure_Description, Repair) AS Failure_Description,
				LineTotal AS Cost
		FROM	View_RSA_Invoices2
		WHERE	Posted = 1
				AND Company = 'DNJ'
				AND RepairNumber = 63307
		) DATA
GROUP BY
		OTRNumber,
		ProNumber,
		Chassis,
		DriverId,
		Division,
		Vendor,
		Repair,
		Failure_Description
ORDER BY Repair, Failure_Description
		
/*
SELECT	Company,
		RepairNumber,
		ProNumber,
		Chassis,
		DriverId,
		Division,
		Total AS Cost,
		CASE WHEN TypeRepair = 1 THEN 'T' + Repair ELSE Repair END AS Repair,
		ISNULL(Failure_Description, Repair) AS Failure_Description
SELECT	*
FROM	View_RSA_Invoices2
WHERE	Posted = 1
		AND EFSDate > '01/01/2015'
ORDER BY InvoiceDate, RepairNumber
*/