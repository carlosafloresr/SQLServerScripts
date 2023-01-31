
SELECT	DISTINCT Company,
		InvoiceNumber,
		EFSNumber,
		IdVendor
INTO	#tmpInvoices
FROM	View_RSA_Invoices2
WHERE	Posted = 1
		AND IsEFS = 1

SELECT	VND.RSA_VendorsNetworkId AS VendorId,
		GPV.Company,
		VND.Vendor,
		VND.Address,
		VND.City,
		VND.State,
		VND.ZIP,
		CASE VND.Phone 
					WHEN Null THEN ''
					WHEN '' THEN ''
					ELSE SUBSTRING(REPLACE(REPLACE(REPLACE(VND.Phone, '-', ''), ')', ''), '(', ''), 1, 3) + '-' + SUBSTRING(REPLACE(REPLACE(REPLACE(VND.Phone, '-', ''), ')', ''), '(', ''), 4, 3) + '-' + SUBSTRING(REPLACE(REPLACE(REPLACE(VND.Phone, '-', ''), ')', ''), '(', ''), 7, 4)
					END AS Phone,
		RTRIM(GPV.VendorId) AS EFS_VendorId
INTO	#tmpVendors
FROM	View_RSA_VendorsNetwork VND
		INNER JOIN RSA_VendorsNetworkGP GPV ON VND.RSA_VendorsNetworkId = GPV.Fk_RSA_VendorsNetworkId
WHERE	VND.Payment = 'EFS Check'
		AND VND.Active = 1 
ORDER BY GPV.Company, GPV.VendorId

SELECT	Company,
		VendorId,
		Vendor,
		Address,
		City,
		State,
		ZIP,
		Phone,
		SPACE(15) AS TaxId,
		SUM(DOCAMNT) AS Amount
FROM	(
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	AIS.dbo.PM20000 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'AIS'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	AIS.dbo.PM30200 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'AIS'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	DNJ.dbo.PM20000 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'DNJ'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	DNJ.dbo.PM30200 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'DNJ'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	GIS.dbo.PM20000 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'GIS'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	GIS.dbo.PM30200 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'GIS'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	IMC.dbo.PM20000 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'IMC'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	IMC.dbo.PM30200 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'IMC'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	NDS.dbo.PM20000 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'NDS'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		UNION
		SELECT	RS.VendorId,
				RS.Company,
				RS.Vendor,
				RS.Address,
				RS.City,
				RS.State,
				RS.ZIP,
				RS.Phone,
				PM.DOCAMNT
		FROM	NDS.dbo.PM30200 PM
				INNER JOIN #tmpInvoices IV ON (PM.DOCNUMBR = IV.InvoiceNumber OR PM.DOCNUMBR = IV.EFSNumber) AND IV.Company = 'NDS'
				INNER JOIN #tmpVendors RS ON RS.VendorId = IV.IdVendor AND RS.EFS_VendorId = PM.VENDORID AND RS.Company = IV.Company
		WHERE	PM.PSTGDATE BETWEEN '1/1/2013' AND '12/31/2013'
		) DAT
GROUP BY
		Company,
		VendorId,
		Vendor,
		Address,
		City,
		State,
		ZIP,
		Phone
ORDER BY
		Company,
		Amount DESC

DROP TABLE #tmpVendors
DROP TABLE #tmpInvoices