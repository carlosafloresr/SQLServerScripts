/*
UPDATE Integrations_AR SET Processed = 0 WHERE BatchId = 'LB050120120000'
UPDATE ReceivedIntegrations SET Status = 0 WHERE BatchId = 'LB050120120000' AND Integration = 'CASHAR'
*/

SELECT	*
FROM	SECSQL01T.GPCustom.dbo.View_CashReceipt
WHERE	BatchId LIKE '%050120%' and checknumber = '159753'
ORDER BY CustomerNumber, CheckNumber, InvoiceNumber

SELECT	*
FROM	SECSQL01T.GPCustom.dbo.View_CashReceipt_BatchSummary
WHERE	BatchId LIKE '%050120%'
		AND NationalAccount = '95000'

--SELECT	CASH.BACHNUMB,
--		CASH.CUSTNMBR,
--		CASH.DOCNUMBR,
--		CASH.ORTRXAMT,
--		APPL.ApplyFrom,
--		APPL.ApplyTo,
--		APPL.ApplyAmount
--FROM	Integrations_Cash CASH
--		LEFT JOIN Integrations_ApplyTo APPL ON CASH.DOCNUMBR = APPL.ApplyFrom AND APPL.BatchId LIKE '%042120%'
--WHERE	CASH.BACHNUMB LIKE '%050120%'
--		AND CASH.CRDTAMNT = 0
--ORDER BY CUSTNMBR

--SELECT	CUSTNMBR,
--		DOCNUMBR,
--		DOCAMNT,
--		ApplyTo
--FROM	Integrations_AR
--WHERE	BatchId LIKE '%050120%'
--		AND CRDTAMNT = 0
--ORDER BY CUSTNMBR, DOCNUMBR

SELECT	*
FROM	Integrations_ApplyTo
WHERE	BatchId LIKE '%050120%'
		and CustomerVendor= '95000'
ORDER BY CustomerVendor, ApplyFrom, ToCreate 