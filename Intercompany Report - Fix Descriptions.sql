SELECT	IA.RecordId, IA.Company, IA.Intercompany, IA.Account, IA.Description, ACT.ACTDESCR
FROM	IntercompanyReport_Accounts IA
		INNER JOIN (SELECT G5.ACTNUMST, G1.ACTDESCR FROM AIS..GL00105 G5 INNER JOIN AIS..GL00100 G1 ON G5.ACTINDX = G1.ACTINDX) ACT ON IA.Account = ACT.ACTNUMST
WHERE	IA.Inactive = 0
		AND IA.Description = ''
		--AND IA.Company = 'AIS'
ORDER BY 1,2,3

--SELECT G5.ACTNUMST, G1.ACTDESCR FROM AIS..GL00105 G5 INNER JOIN AIS..GL00100 G1 ON G5.ACTINDX = G1.ACTINDX

--SELECT * FROM AIS..GL00100

/*
UPDATE	IntercompanyReport_Accounts
SET		IntercompanyReport_Accounts.Description = RTRIM(DATA.ACTDESCR)
FROM	(
		SELECT	IA.RecordId, IA.Company, IA.Intercompany, IA.Account, IA.Description, ACT.ACTDESCR
		FROM	IntercompanyReport_Accounts IA
				INNER JOIN (SELECT G5.ACTNUMST, G1.ACTDESCR FROM PDS..GL00105 G5 INNER JOIN PDS..GL00100 G1 ON G5.ACTINDX = G1.ACTINDX) ACT ON IA.Account = ACT.ACTNUMST
		WHERE	IA.Inactive = 0
				AND IA.Description = ''
				AND IA.Company = 'PDS'
		) DATA
WHERE	IntercompanyReport_Accounts.RecordId = DATA.RecordId
*/