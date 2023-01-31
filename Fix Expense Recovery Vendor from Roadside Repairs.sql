UPDATE	ExpenseRecovery
SET		ExpenseRecovery.Vendor = RTRIM(LEFT(DATA.Vendor, 30))
FROM	(
		SELECT	ER.Company,
				--ER.Vendor,
				ER.ProNumber,
				ER.ExpenseRecoveryId,
				RR.InvoiceNumber,
				RR.Vendor
		FROM	ExpenseRecovery ER
				LEFT JOIN View_RSA_Invoices2 RR ON ER.Company = RR.Company AND ER.ProNumber = RR.ProNumber AND ER.DocNumber = RR.InvoiceNumber
		WHERE	ER.Vendor LIKE '%EFS%'
				AND ER.Vendor <> LEFT(RR.Vendor, 30)
		) DATA
WHERE	ExpenseRecovery.ExpenseRecoveryId = DATA.ExpenseRecoveryId

/*
SELECT	top 10 *
FROM	View_RSA_Invoices2
*/