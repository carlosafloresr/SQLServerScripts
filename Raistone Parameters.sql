SELECT	*
FROM	Parameters
WHERE	ParameterCode LIKE 'RAISTONE%'
		AND ParameterCode NOT LIKE 'RAISTONE_SFTP%'
ORDER BY ParameterCode

