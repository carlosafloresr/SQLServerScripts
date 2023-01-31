/*
UPDATE	FSI_ReceivedSubDetails 
SET		Processed = 1
WHERE	BatchId = '1FSI081215_1042' 
		AND RecordType = 'VND'

UPDATE	FSI_ReceivedDetails 
SET		Processed = 0
WHERE	BatchId = '4FSI081216_1223'
*/

SELECT	* 
FROM	dbo.View_FSI_Intercompany

-- SELECT DISTINCT BatchId, Company FROM View_FSI_Intercompany ORDER BY BatchId
