DECLARE	@Company	Varchar(5) = 'AIS',
		@Server		Varchar(20) = 'SECSASQL001U'

UPDATE	Integrations_AP
SET		AP_Processed = 0
WHERE	PSTGDATE >= '08/15/2018'
		AND Company = @Company
		AND BatchId = 'DEX180815120002'

INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer)
SELECT	DISTINCT Integration, Company, BatchId, @Server AS ServerName
FROM	Integrations_AP
WHERE	PSTGDATE >= '08/15/2018'
		AND Company = @Company
		AND BatchId = 'DEX180815120002'
/*
UNION
SELECT	DISTINCT Integration, Company, BatchId, @Server
FROM	Integrations_AR
WHERE	DOCDATE BETWEEN '08/12/2018' AND '08/16/2018'
		AND Company = @Company
UNION
SELECT	DISTINCT Integration, Company, BatchId, @Server
FROM	Integrations_GL
WHERE	TrxDate BETWEEN '08/12/2018' AND '08/16/2018'
		AND Company = @Company
		--AND Integration = 'ADP'
UNION
SELECT	DISTINCT Integration, Company, BACHNUMB, @Server
FROM	Integrations_SOP
WHERE	PostingDate BETWEEN '08/12/2018' AND '08/16/2018'
		AND Company = @Company
UNION
SELECT	'FSI', Company, BatchId, @Server
FROM	FSI_ReceivedHeader
WHERE	ReceivedOn BETWEEN '08/15/2018' AND '08/15/2018 11:59 PM'
		AND Company = @Company
UNION
SELECT	'FPT', Company, BatchId, @Server
FROM	FPT_ReceivedHeader
WHERE	ReceivedOn BETWEEN '08/12/2018' AND '08/16/2018 11:59 PM'
		AND Company = @Company
UNION
SELECT	'DPY', Company, BatchId, @Server
FROM	SECSASQL001U.GPCustom.dbo.Integration_APHeader
WHERE	ReceivedOn BETWEEN '08/12/2018' AND '08/16/2018 11:59 PM'
		AND Company = @Company

UPDATE	FSI_ReceivedDetails
SET		Processed = 0,
		RecordStatus = 0
WHERE	BatchId IN (SELECT	BatchId
					FROM	FSI_ReceivedHeader
					WHERE	ReceivedOn BETWEEN '08/15/2018' AND '08/15/2018 11:59 PM'
							AND Company = @Company)

UPDATE	FSI_ReceivedSubDetails
SET		Processed = 0
WHERE	BatchId IN (SELECT	BatchId
					FROM	FSI_ReceivedHeader
					WHERE	ReceivedOn BETWEEN '08/15/2018' AND '08/15/2018 11:59 PM'
							AND Company = @Company)

UPDATE	FPT_ReceivedDetails
SET		Processed = 0
WHERE	BatchId IN (SELECT	BatchId
					FROM	FPT_ReceivedHeader
					WHERE	ReceivedOn BETWEEN '08/12/2018' AND '08/16/2018 11:59 PM'
							AND Company = @Company)

UPDATE	Integrations_AP
SET		AP_Processed = 0
WHERE	PSTGDATE = '08/15/2018'
		AND Company = @Company

UPDATE	Integrations_AR
SET		Processed = 0
WHERE	DOCDATE BETWEEN '08/12/2018' AND '08/16/2018'
		AND Company = @Company

UPDATE	Integrations_GL
SET		Processed = 0
WHERE	TrxDate BETWEEN '08/12/2018' AND '08/16/2018'
		AND Company = @Company

UPDATE	Integrations_SOP
SET		Processed = 0
WHERE	PostingDate BETWEEN '08/12/2018' AND '08/16/2018'
		AND Company = @Company

UPDATE	SECSASQL001U.GPCustom.dbo.Integration_APHeader
SET		Status = 0
WHERE	ReceivedOn BETWEEN '08/12/2018' AND '08/16/2018 11:59 PM'
		AND Company = @Company

UPDATE	SECSASQL001U.GPCustom.dbo.Integration_APDetails
SET		Processed = 0
WHERE	BatchId IN (SELECT	BatchId
					FROM	LENSASQL001.GPCustom.dbo.Integration_APHeader
					WHERE	ReceivedOn BETWEEN '08/12/2018' AND '08/16/2018 11:59 PM'
							AND Company = @Company)

DELETE	ReceivedIntegrations
WHERE	GPServer = 'SECSASQL001U'
*/