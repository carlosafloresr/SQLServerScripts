UPDATE	FSI_ReceivedSubDetails
SET		Processed = 1
WHERE	Processed = 0
		AND FSI_ReceivedSubDetailId IN (SELECT	FSI_ReceivedSubDetailId
										FROM	View_Integration_FSI_Vendors
										WHERE	BatchId IN (SELECT BatchId FROM FSI_ReceivedHeader WHERE YEAR(ReceivedOn) = YEAR(GETDATE()) AND ReceivedOn < CAST(GETDATE() AS Date)) -- AND Processed = 1)
										)