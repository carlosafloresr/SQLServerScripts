EXECUTE USP_CheckFSIPaperlessBatches

UPDATE	FSI_ReceivedDetails 
SET		RecordStatus = 1
WHERE	RecordStatus = 1
		AND FSI_ReceivedDetailId IN (
			SELECT	FSI_ReceivedDetailId
			FROM	dbo.FSI_ReceivedDetails
			WHERE	BatchId IN ('7FSI111121_1515')
					AND CustomerNumber IN (
						SELECT	CustNmbr
						FROM	ILSGP01.GPCustom.dbo.CustomerMaster
						WHERE	CompanyId = 'DNJ'
								AND InvoiceEmailOption <> 1))
								
UPDATE	FSI_ReceivedHeader 
SET		Status = 4 
WHERE	BatchId IN ('7FSI111121_1515')

/*
EXECUTE USP_UpdateFSIPaperlessBatchStatus '7FSI111027_1621'

SELECT	*
FROM	View_Integration_FSI FSI 
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUS ON FSI.CustomerNumber = CUS.CustNmbr AND FSI.Company = CUS.CompanyId 
WHERE	FSI.BatchId = '7FSI111121_1515' 
		--AND CUS.InvoiceEmailOption > 1 
		--AND FSI.RecordStatus = 0
		AND FSI.InvoiceType = 'A'
		AND CustomerNumber IN (
						SELECT	CustNmbr
						FROM	ILSGP01.GPCustom.dbo.CustomerMaster
						WHERE	CompanyId = 'DNJ'
								AND InvoiceEmailOption <> 1)
*/