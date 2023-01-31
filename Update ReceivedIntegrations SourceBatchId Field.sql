--SELECT	*
--FROM	[SECSQL01T].[GPCustom].[dbo].[CashReceiptBatches]

UPDATE	ReceivedIntegrations
SET		SourceBatchId = DATA.BatchId
FROM	(
		SELECT	RI.ReceivedIntegrationId,
				RI.Company,
				CR.BatchId,
				ISNULL(CO.CompanyAlias, RI.Company) AS Alias
		FROM	ReceivedIntegrations RI
				INNER JOIN [SECSQL01T].[GPCustom].[dbo].[Companies] CO ON RI.Company = CO.CompanyId
				INNER JOIN [SECSQL01T].[GPCustom].[dbo].[CashReceiptBatches] CR ON RI.BatchId = 'CH' + SUBSTRING(CR.BatchId, 6, 12) AND ISNULL(CO.CompanyAlias, RI.Company) = CR.Company
		WHERE	RI.Integration = 'LCKBX'
		) DATA
WHERE	ReceivedIntegrations.ReceivedIntegrationId = DATA.ReceivedIntegrationId

SELECT * FROM ReceivedIntegrations WHERE Integration = 'LCKBX'