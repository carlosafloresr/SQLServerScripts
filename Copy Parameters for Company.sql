INSERT INTO Parameters
		(Company,
		ParameterCode,
		Description,
		VarType,
		VarN,
		VarI,
		VarD,
		VarB,
		VarM,
		VarC,
		ApplicationName)
SELECT	'GLSO' AS Company,
		ParameterCode,
		Description,
		VarType,
		VarN,
		VarI,
		VarD,
		VarB,
		VarM,
		VarC,
		ApplicationName
FROM	GPCustom.dbo.Parameters
WHERE	COMPANY = 'PDS'
		AND PARAMETERCODE LIKE 'FSI_CTF_%'
		--AND SUBSTRING(VARC, 2, 1) = '-'
		--AND ParameterCode NOT IN (SELECT ParameterCode FROM Parameters WHERE Company = 'PTS')
		AND ParameterCode = 'FILEBOUNDSERVER'
		--AND Description LIKE '%Pre Pays'
		--AND VarType = 'C'

--SELECT	*
--FROM	Parameters 
--WHERE	Company = 'PTS'
--		AND ParameterCode LIKE '%FSI%'

/*
UPDATE	Parameters 
SET		VarC = '0-00-1050'
WHERE	Company = 'PTS'
		AND ParameterCode = 'FSISALESDEBACCT'

UPDATE	Parameters 
SET		VarC = '1-00-4010'
WHERE	Company = 'PTS'
		AND ParameterCode = 'FSISALESCREACCT'

UPDATE	Parameters 
SET		VarC = '1-00-5010'
WHERE	Company = 'PTS'
		AND ParameterCode = 'FSIVENDORDEBACCT'
*/