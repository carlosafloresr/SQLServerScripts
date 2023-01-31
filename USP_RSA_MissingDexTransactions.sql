/*
EXECUTE USP_RSA_MissingDexTransactions
*/
ALTER PROCEDURE USP_RSA_MissingDexTransactions
AS
SELECT	DISTINCT Company
		,RepairNumber
		,RSA_InvoiceId
		,RSA_Approval
FROM	View_RSA_Invoices2 RSA
WHERE	RSA_Approval = 0
		AND Creation > DATEADD(dd, -5, GETDATE())
		AND In_DEX_AP = 0
		AND Company IS NOT Null

/*

SELECT	*
FROM	View_RSA_Invoices2
WHERE	RepairNumber = 55728

UPDATE	VendorInfo
SET		ACTIVE = 0
WHERE	Id = 15457
*/