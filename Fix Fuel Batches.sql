SELECT	*
FROM	FPT_ReceivedDetails
WHERE	BatchId IN (
					SELECT	BatchId
					FROM	FPT_ReceivedHeader
					WHERE	Company = 'NDS'
							AND WeekEndDate = '10/22/2011'
					)
					
/*
SELECT	*
FROM	FPT_ReceivedHeader
WHERE	Company = 'NDS'
		AND WeekEndDate = '10/22/2011'
		
UPDATE	FPT_ReceivedHeader
SET		Status = 0
WHERE	Company = 'NDS'
		AND WeekEndDate = '10/22/2011'
*/
UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	BatchId IN (
					SELECT	BatchId
					FROM	FPT_ReceivedHeader
					WHERE	Company = 'NDS'
							AND WeekEndDate = '10/22/2011'
					)
*/