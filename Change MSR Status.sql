SELECT	* 
FROM	View_MSR_Intercompany
WHERE	BatchId = 'AR_RCMR_101208' order by invoicenumber
		AND (InvoiceTotal <> (Amount1 + Amount2 + Amount3)
		OR (Account1 IS Null
		OR (Account2 IS Null AND Amount2 <> 0)
		OR (Account3 IS Null AND Amount3 <> 0)))
/*
UPDATE	MSR_Intercompany
SET		Processed = 0
WHERE	BatchId = 'AR_RCMR_101208'
		AND MSR_IntercompanyId IN (	SELECT	MSR_IntercompanyId 
									FROM	View_MSR_Intercompany 
									WHERE	BatchId = 'AR_RCMR_101208'
											AND Intercompany = 'IMC')

UPDATE	MSR_Intercompany
SET		Account1 = '3-09-6160'
WHERE	BatchId = 'AR_RCMR_101208'
		AND InvoiceNumber = '424949'
			
SELECT * FROM MSR_Intercompany
*/
/*
select sum(amount) from (
SELECT	distinct docnumber, amount
FROM	MSR_ReceviedTransactions
WHERE	BatchId = 'AR_FI_101112'
		AND Intercompany = 1) recs

SELECT	* 
FROM	View_MSR_Intercompany 
WHERE	BatchId = 'AR_FI_101112'
ORDER BY Intercompany, DocNumber

SELECT	sum(invoicetotal)
FROM	View_MSR_Intercompany 
WHERE	BatchId = 'AR_FI_101112'
		AND Intercompany = 'IMC'
*/