UPDATE	FSI_ReceivedDetails
SET		FSI_ReceivedDetails.Equipment = DATA.Equipment
FROM	(
		SELECT	BatchId,
							DetailId,
							MAX(RecordCode) AS Equipment
					FROM	FSI_ReceivedSubDetails
					WHERE	RecordType = 'EQP'
					GROUP BY
							BatchId,
							DetailId
		) DATA
WHERE	FSI_ReceivedDetails.BatchId = DATA.BatchId
		AND FSI_ReceivedDetails.DetailId = DATA.DetailId
		AND FSI_ReceivedDetails.Equipment IS Null