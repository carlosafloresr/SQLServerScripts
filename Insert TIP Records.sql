INSERT INTO TIP_IntegrationRecords
	SELECT	FSI_ReceivedSubDetailId
	FROM	FSI_ReceivedSubDetails
	WHERE	FSI_ReceivedSubDetailId NOT IN (SELECT TIPIntegrationId FROM TIP_IntegrationRecords)
			AND VndIntercompany = 1
			AND Processed = 1