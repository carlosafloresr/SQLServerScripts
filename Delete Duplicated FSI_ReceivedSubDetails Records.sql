USE [Integrations]
GO

DECLARE	@BatchId Varchar(25) = '1FSI20161209_1617' 

SELECT	BatchId, 
		DetailId, 
		RecordType, 
		RecordCode, 
		Reference, 
		ChargeAmount1, 
		ChargeAmount2, 
		MIN(FSI_ReceivedSubDetailId) AS FSI_ReceivedSubDetailId,
		COUNT(DetailId) AS Counter
INTO	#tmpDuplicates
FROM	FSI_ReceivedSubDetails 
WHERE	BATCHID = @BatchId
GROUP BY BatchId, DetailId, RecordType, RecordCode, Reference, ChargeAmount1, ChargeAmount2
HAVING COUNT(DetailId) > 1

DELETE	FSI_ReceivedSubDetails
FROM	(SELECT * FROM #tmpDuplicates) DATA
WHERE	FSI_ReceivedSubDetails.BatchId = DATA.BatchId
		AND FSI_ReceivedSubDetails.DetailId = DATA.DetailId
		AND FSI_ReceivedSubDetails.RecordType = DATA.RecordType
		AND FSI_ReceivedSubDetails.RecordCode = DATA.RecordCode
		AND FSI_ReceivedSubDetails.Reference = DATA.Reference
		AND FSI_ReceivedSubDetails.ChargeAmount1 = DATA.ChargeAmount1
		AND FSI_ReceivedSubDetails.ChargeAmount2 = DATA.ChargeAmount2
		AND FSI_ReceivedSubDetails.FSI_ReceivedSubDetailId > DATA.FSI_ReceivedSubDetailId

DROP TABLE #tmpDuplicates