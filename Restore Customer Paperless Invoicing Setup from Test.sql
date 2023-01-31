UPDATE	CustomerMaster
SET		InvoiceEmailOption = DATA.InvoiceEmailOption
FROM	(
		SELECT	CM.CompanyId,
				CM.custnmbr,
				TC.InvoiceEmailOption
		FROM	CUSTOMERMASTER CM
				INNER JOIN (SELECT DISTINCT Company, Customer FROM ILSINT02.Integrations.dbo.PaperlessInvoices WHERE RunDate >= '04/01/2018') PP ON CM.CompanyId = PP.Company AND CM.CustNmbr = PP.Customer
				INNER JOIN LENSASQL001T.GPCustom.dbo.CustomerMaster TC ON CM.CompanyId = TC.CompanyId AND CM.CustNmbr = TC.CustNmbr AND TC.InvoiceEmailOption > 1
		WHERE	CM.InvoiceEmailOption = 1
				AND CM.Inactive = 0
		) DATA
WHERE	CustomerMaster.CompanyId = DATA.CompanyId 
		AND CustomerMaster.CustNmbr = DATA.CustNmbr 
