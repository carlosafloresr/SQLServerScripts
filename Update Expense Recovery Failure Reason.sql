SELECT	REPLACE(Reference, DocNumber + '/', '')
		,*
FROM	ExpenseRecovery
WHERE	Company = 'IMC'
		AND Vendor IN ('15639 - Frederick Intermodal','11959 - Rivercity Maintenance')

UPDATE	ExpenseRecovery
SET		FailureReason = REPLACE(Reference, DocNumber + '/', '')
WHERE	Company = 'IMC'
		AND Vendor IN ('15639 - Frederick Intermodal','11959 - Rivercity Maintenance')
		AND FailureReason IS Null

--SELECT	*
--FROM	IMC.dbo.GL20000
--WHERE	(CrdtAmnt = 107.00
--		OR DebitAmt = 107.00)
--		AND Refrence = '594059/C10259|RPL-LFI|FS'
		
--SELECT	*
--FROM	IMC.dbo.GL30000
--WHERE	(CrdtAmnt = 107.00
--		OR DebitAmt = 107.00)
--		AND Refrence = '594059/C10259|RPL-LFI|FS'
--		AND JrnEntry = 889238

/*
SELECT	*
FROM	ILSINT01.Integrations.dbo.MSR_Intercompany
WHERE	InvoiceNumber IN (606211,594059,623755)
		
SELECT	*
FROM	ILSINT01.FI_Data.dbo.Invoices
WHERE	Inv_No IN (606211,594059,623755)

SELECT	*
FROM	ILSINT01.FI_Data.dbo.Sale
WHERE	Inv_No IN (606211,594059,623755)
*/