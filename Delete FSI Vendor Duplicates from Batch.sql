/*
SELECT	*
FROM	View_Integration_FSI_Vendors 
WHERE	BatchId = '1FSI20161213_1729'
ORDER BY InvoiceNumber, RowId
*/

DECLARE	@BatchId Varchar(25) = '1FSI20161213_1729'

SELECT	BatchId,
		DetailId,
		RecordCode,
		ChargeAmount1,
		VendorDocument,
		MIN(FSI_ReceivedSubDetailId) AS FSI_ReceivedSubDetailId,
		COUNT(FSI_ReceivedSubDetailId) AS Counter
INTO	#tmpDuplicates
FROM	FSI_ReceivedSubDetails
WHERE	Batchid = @BatchId
		AND RecordType = 'VND'
GROUP BY BatchId,
		DetailId,
		RecordCode,
		ChargeAmount1,
		VendorDocument
HAVING	COUNT(FSI_ReceivedSubDetailId) > 1

DELETE	FSI_ReceivedSubDetails
FROM	(SELECT * FROM #tmpDuplicates) DUPS
WHERE	FSI_ReceivedSubDetails.BatchId = DUPS.BatchId
		AND FSI_ReceivedSubDetails.DetailId = DUPS.DetailId
		AND FSI_ReceivedSubDetails.RecordCode = DUPS.RecordCode
		AND FSI_ReceivedSubDetails.ChargeAmount1 = DUPS.ChargeAmount1
		AND FSI_ReceivedSubDetails.VendorDocument = DUPS.VendorDocument
		AND FSI_ReceivedSubDetails.FSI_ReceivedSubDetailId > DUPS.FSI_ReceivedSubDetailId

DROP TABLE #tmpDuplicates