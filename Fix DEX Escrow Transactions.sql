/*
SELECT	*
FROM	ILSINT01.Integrations.dbo.Integrations_AP
WHERE	Integration = 'DXP'
		AND BatchId = 'DEX110812130000'

SELECT	*
FROM	EscrowTransactions
WHERE	VoucherNumber = 'IDV12130700148437'

AccountNumber = '0-00-1800'
		AND CompanyId = 'IMC'
		AND right(VoucherNumber, 5) = '75314'
		--and VendorId = '3652'
*/
UPDATE	EscrowTransactions
SET		EscrowTransactions.InvoiceNumber = CASE WHEN EscrowTransactions.InvoiceNumber IS NULL THEN RECS.DocNumbr ELSE EscrowTransactions.InvoiceNumber END,
		EscrowTransactions.Comments = RECS.DistRef
FROM	(
		SELECT	DISTINCT AP.DocNumbr
				,AP.BatchId AS BatchNumber
				,AP.DistRef
				,ET.*
		FROM	EscrowTransactions ET
				INNER JOIN ILSINT01.Integrations.dbo.Integrations_AP AP ON AP.Integration = 'DXP' AND ET.VoucherNumber = AP.VchNumWk AND ET.CompanyId = AP.Company AND ET.AccountNumber = AP.ActNumSt
		WHERE	ET.Source = 'AP'
		) RECS
WHERE	EscrowTransactions.EscrowTransactionId = RECS.EscrowTransactionId

/*
SELECT	*
FROM	ILSINT01.Integrations.dbo.Integrations_AP
WHERE	Integration = 'DXP'
		AND BatchId = 'DEX110812130000'
*/