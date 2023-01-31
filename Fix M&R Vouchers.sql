UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RTRIM(RECS.DOCNUMBR),
		ExpenseRecovery.Vendor =  LEFT(RECS.Vendor, 30)
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.VCHRNMBR, PM30200.VCHRNMBR) AS VCHRNMBR, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR, ExpenseRecovery.DocNumber, RTRIM(PM00200.VendorId) + '-' + RTRIM(PM00200.VENDNAME) AS Vendor
		FROM	ExpenseRecovery
				LEFT JOIN AIS..PM20000 ON ExpenseRecovery.DocNumber = PM20000.DOCNUMBR AND PM20000.DOCTYPE <> 6
				LEFT JOIN AIS..PM30200 ON ExpenseRecovery.DocNumber = PM30200.DOCNUMBR AND PM30200.DOCTYPE <> 6
				LEFT JOIN AIS..PM00200 ON ISNULL(PM20000.VENDORID, PM30200.VENDORID) = PM00200.VENDORID
		WHERE	Company = 'AIS'
				AND (DocNumber = '' 
				OR ExpenseRecovery.DocNumber <> ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR)
				OR ExpenseRecovery.Vendor = '')
) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
		AND RECS.DOCNUMBR IS NOT NULL
		AND RECS.VENDOR IS NOT NULL
		
UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RTRIM(RECS.DOCNUMBR),
		ExpenseRecovery.Vendor =  LEFT(RECS.Vendor, 30)
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.VCHRNMBR, PM30200.VCHRNMBR) AS VCHRNMBR, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR, ExpenseRecovery.DocNumber, RTRIM(PM00200.VendorId) + '-' + RTRIM(PM00200.VENDNAME) AS Vendor
		FROM	ExpenseRecovery
				LEFT JOIN GIS..PM20000 ON ExpenseRecovery.DocNumber = PM20000.DOCNUMBR AND PM20000.DOCTYPE <> 6
				LEFT JOIN GIS..PM30200 ON ExpenseRecovery.DocNumber = PM30200.DOCNUMBR AND PM30200.DOCTYPE <> 6
				LEFT JOIN GIS..PM00200 ON ISNULL(PM20000.VENDORID, PM30200.VENDORID) = PM00200.VENDORID
		WHERE	Company = 'GIS'
				AND (DocNumber = '' 
				OR ExpenseRecovery.DocNumber <> ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR)
				OR ExpenseRecovery.Vendor = '')
) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
		AND RECS.DOCNUMBR IS NOT NULL
		AND RECS.VENDOR IS NOT NULL
		
UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RTRIM(RECS.DOCNUMBR),
		ExpenseRecovery.Vendor =  LEFT(RECS.Vendor, 30)
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.VCHRNMBR, PM30200.VCHRNMBR) AS VCHRNMBR, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR, ExpenseRecovery.DocNumber, RTRIM(PM00200.VendorId) + '-' + RTRIM(PM00200.VENDNAME) AS Vendor
		FROM	ExpenseRecovery
				LEFT JOIN IMC..PM20000 ON ExpenseRecovery.DocNumber = PM20000.DOCNUMBR AND PM20000.DOCTYPE <> 6
				LEFT JOIN IMC..PM30200 ON ExpenseRecovery.DocNumber = PM30200.DOCNUMBR AND PM30200.DOCTYPE <> 6
				LEFT JOIN IMC..PM00200 ON ISNULL(PM20000.VENDORID, PM30200.VENDORID) = PM00200.VENDORID
		WHERE	Company = 'IMC'
				AND (DocNumber = '' 
				OR ExpenseRecovery.DocNumber <> ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR)
				OR ExpenseRecovery.Vendor = '')
) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
		AND RECS.DOCNUMBR IS NOT NULL
		AND RECS.VENDOR IS NOT NULL
		
UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RTRIM(RECS.DOCNUMBR),
		ExpenseRecovery.Vendor =  LEFT(RECS.Vendor, 30)
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.VCHRNMBR, PM30200.VCHRNMBR) AS VCHRNMBR, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR, ExpenseRecovery.DocNumber, RTRIM(PM00200.VendorId) + '-' + RTRIM(PM00200.VENDNAME) AS Vendor
		FROM	ExpenseRecovery
				LEFT JOIN NDS..PM20000 ON ExpenseRecovery.DocNumber = PM20000.DOCNUMBR AND PM20000.DOCTYPE <> 6
				LEFT JOIN NDS..PM30200 ON ExpenseRecovery.DocNumber = PM30200.DOCNUMBR AND PM30200.DOCTYPE <> 6
				LEFT JOIN NDS..PM00200 ON ISNULL(PM20000.VENDORID, PM30200.VENDORID) = PM00200.VENDORID
		WHERE	Company = 'NDS'
				AND (DocNumber = '' 
				OR ExpenseRecovery.DocNumber <> ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR)
				OR ExpenseRecovery.Vendor = '')
) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
		AND RECS.DOCNUMBR IS NOT NULL
		AND RECS.VENDOR IS NOT NULL
		
UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RTRIM(RECS.DOCNUMBR),
		ExpenseRecovery.Vendor =  LEFT(RECS.Vendor, 30)
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.VCHRNMBR, PM30200.VCHRNMBR) AS VCHRNMBR, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR, ExpenseRecovery.DocNumber, RTRIM(PM00200.VendorId) + '-' + RTRIM(PM00200.VENDNAME) AS Vendor
		FROM	ExpenseRecovery
				LEFT JOIN DNJ..PM20000 ON ExpenseRecovery.DocNumber = PM20000.DOCNUMBR AND PM20000.DOCTYPE <> 6
				LEFT JOIN DNJ..PM30200 ON ExpenseRecovery.DocNumber = PM30200.DOCNUMBR AND PM30200.DOCTYPE <> 6
				LEFT JOIN DNJ..PM00200 ON ISNULL(PM20000.VENDORID, PM30200.VENDORID) = PM00200.VENDORID
		WHERE	Company = 'DNJ'
				AND (DocNumber = '' 
				OR ExpenseRecovery.DocNumber <> ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR)
				OR ExpenseRecovery.Vendor = '')
) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
		AND RECS.DOCNUMBR IS NOT NULL
		AND RECS.VENDOR IS NOT NULL