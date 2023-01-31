USP_Karmak_KimIntegration 'KIM', 1, 'CFLORES'

/*
SELECT	* 
FROM	[RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders 
WHERE	InvoiceNumber BETWEEN 6384 AND 6546
		AND RepairCode = 'INSTALL'
		
UPDATE	KarmakIntegration
SET		Processed = 3
WHERE	WeekEndDate < '2010-02-20'

UPDATE	KarmakIntegration
SET		Account1 = Null,
		Amount1 = Null,
		Description1 = Null,
		Account2 = Null,
		Amount2 = Null,
		Description2 = Null,
		Account3 = Null,
		Amount3 = Null,
		Description3 = Null
WHERE	WeekEndDate = '2010-02-20'
*/

-- SELECT * FROM KarmakIntegration WHERE WeekEndDate = '2010-02-20'