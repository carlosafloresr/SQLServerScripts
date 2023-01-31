SELECT	*
FROM	KarmakIntegration
WHERE	BatchId = 'SLSWE042217'

-- *** KAR
UPDATE	KarmakIntegration
SET		Processed = 0,
		Approved = 1,
		AcctApproved = 1
WHERE	BatchId = 'SLSWE042217'

-- *** KIM
UPDATE	KarmakIntegration
SET		Processed = 2
WHERE	KIMBATCHID = 'SLSWE042217'