SELECT	*
FROM	(
		SELECT	*,
				CASE WHEN Difference = ISNULL(TotalFSI,0) THEN 'FULL MATCH'
					 WHEN Difference = FSIAmount AND TransTypeId = 1 THEN 'FSIP MATCH'
					 WHEN Difference = FSIAmount AND TransTypeId <> 1 THEN 'ITEM MATCH'
					 ELSE '' END AS Different
		FROM	(
				SELECT	MIS.Invoice,
						MIS.Amount AS SWSAmount,
						MIS.GPAmount AS Difference,
						FSI.Amount AS FSIAmount,
						FSI.TransType,
						FSI.TransTypeId,
						TotalFSI = (SELECT SUM(TMP.Amount) FROM View_FSI_NonSale TMP WHERE TMP.Company = MIS.Company AND TMP.InvoiceNumber = MIS.Invoice),
						FSI.BatchId,
						FSI.IntegrationType,
						FSI.[PrepayReference],
						CAST(FSI.RecordId AS Varchar) + ',' AS RecordId
				FROM	FSI_MissingInvoices MIS
						LEFT JOIN View_FSI_NonSale FSI ON MIS.Invoice = FSI.InvoiceNumber AND FSI.Company = MIS.Company
				WHERE	MIS.Company = 'GLSO'
						AND MIS.Amount = MIS.GPAmount
				) DATA
		) TMP
WHERE	Different <> ''
		--and integrationtype  IN ('FSIP','FSIG')
ORDER BY integrationtype, BatchId
--TransTypeId, 10 DESC, BatchId, IntegrationType
/*
SELECT	*
FROM	View_Integration_FSI_Full
WHERE	InvoiceNumber = '95-165298'
*/