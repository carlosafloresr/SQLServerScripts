--SELECT	DISTINCT Company,
--		BatchId,
--		InvoiceNumber,
--		PrePay,
--		ICB_AR,
--		ICB_AP
SELECT	*
FROM	View_Integration_FSI_Full --FSI_ReceivedDetails
WHERE	--ReceivedOn > '03/01/2019'
		--AND (ICB_AR = 1
		--OR ICB_AP = 1)
		--BatchId = '9FSI20190520_1634'
		--AND InvoiceType = 'C'
		--AND Intercompany = 1
		--AND InvoiceNumber = '95-141057'
		InvoiceNumber IN ('54-108976')
		AND (ICB_AP = 1 OR ICB_AR = 1)
		--AND RecordType = 'VND'
		--AND PrePay = 1
		--and ICB_AP = 0
ORDER BY BatchId

/*
UPDATE	FSI_ReceivedDetails --View_Integration_FSI_Full
SET		--ICB = 0,
		Intercompany = 0,
		Processed = 0
WHERE	BatchId = '6FSI20190312_1629'
		AND InvoiceNumber IN ('54-106784')

--DELETE TIP_IntegrationRecords WHERE TIPIntegrationId IN (5469405,5469947)

UPDATE	ReceivedIntegrations
SET		Status = 0
		,ReverseBatch = 0
WHERE	Integration = 'TIP'
		AND BatchId = '2FSI20190321_0959_SUM'

UPDATE	FSI_ReceivedSubDetails
SET		Processed = 0,
		VndIntercompany = 0
WHERE	BatchId = '3FSI20190327_1732'
		AND RecordType = 'VND'
FSI_ReceivedSubDetailId IN (25430596, 25430597)

INSERT INTO ReceivedIntegrations 
		(Integration, Company, BatchId, GPServer) 
VALUES 
		('TIP', 'IMC', '1FSI20190312_1736', 'PRISQL01P')

SELECT	*
FROM	ReceivedIntegrations
WHERE	Integration = 'TIP'
		AND BatchId = '7FSI20190308_1633'
*/