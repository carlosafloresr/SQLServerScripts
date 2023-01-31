UPDATE	EscrowTransactions
SET		EscrowTransactions.InvoiceNumber = DATA.InvoiceNumber
FROM	(
		SELECT	ET.EscrowTransactionId,
				ET.VendorId,
				CASE WHEN ET.Source = 'GL' THEN ET.ProNumber ELSE RIGHT(ET.Comments, 5) END AS ProNumber,
				ET.BatchId,
				CASE WHEN FI.ReferenceNumber = '' THEN FI.InvoiceNumber ELSE FI.ReferenceNumber END AS InvoiceNumber
		FROM	EscrowTransactions ET
				LEFT JOIN ILSINT02.Integrations.dbo.FRS_Integrations FI ON ET.VendorId = FI.AccountNumber AND CASE WHEN ET.Source = 'GL' THEN ET.ProNumber ELSE RIGHT(ET.Comments, 5) END = FI.WorkOrder AND FI.IntegrationType = 'AP'
		WHERE	ET.CompanyId = 'FI'
				AND ET.AccountNumber = '5-29-2104'
				--AND ET.Source = 'GL'
				AND ET.EnteredOn > '07/01/2015'
				AND ET.BatchId LIKE 'FRS%'
		) DATA
WHERE	EscrowTransactions.EscrowTransactionId = DATA.EscrowTransactionId
/*
SELECT	top 10 *
FROM	ILSINT02.Integrations.dbo.FRS_Integrations
*/