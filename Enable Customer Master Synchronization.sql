SELECT	*
FROM	CustomerMaster
WHERE	CompanyId = 'PTS'

UPDATE	CustomerMaster
SET		Changed = 1,
		Trasmitted = 0
WHERE	CompanyId = 'PTS'
