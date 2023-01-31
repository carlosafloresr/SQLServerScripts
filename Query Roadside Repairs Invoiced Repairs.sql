/*
SELECT	TOP 10 *
FROM	View_RSA_Invoices2
WHERE	InvoiceDate BETWEEN '01/01/2013' AND '09/30/2013'
		AND Repair = 'RPL'
		AND Posted = 1
*/

SELECT	RTRIM(LTRIM(Company)) AS Company,
		OTRNumber,
		ProNumber,
		DriverId,
		Division,
		VendorId,
		VendorName,
		InvoiceNumber,
		InvoiceDate,
		CASE WHEN ISNULL(IsEFS, 0) = 1 THEN 'YES' ELSE 'NO' END AS IsEFS,
		CASE WHEN AfterBusinessHour = 1 THEN 'YES' ELSE 'NO' END AS AfterHours,
		CASE WHEN TypeTire = 1 THEN 'OEM' ELSE 'Other' END AS TypeTire,
		GLDescription AS DetailDescription,
		Failure_Description,
		BaseCost,
		Other,
		ServiceCharges,
		SalesTax,
		InvoiceTotal
FROM	View_RSA_Invoices2
WHERE	InvoiceDate BETWEEN '01/01/2013' AND '09/30/2013'
		AND Repair = 'RPL'
		AND Posted = 1
		AND VendorId IS NOT NULL
		AND InvoiceNumber NOT LIKE '%ALEX%'
ORDER BY Company, VendorId, InvoiceDate