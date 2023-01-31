SELECT	*
FROM	Parameters
WHERE	ParameterCode LIKE 'PRD%'
		and Company = 'all'
		--AND VarC IN ('0-00-2117')
		--AND VarC IN ('0-11-6591')

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	ParameterCode,
		'GIS' AS Company,
		Description,
		VarType,
		'0-00-2000' AS VarC
FROM	Parameters
WHERE	ParameterCode = 'PRD_DEBITACCOUNT'
		AND COMPANY = 'ALL'

INSERT INTO Parameters (ParameterCode,
		Company,
		Description,
		VarType,
		VarC)
SELECT	ParameterCode,
		'GIS' AS Company,
		Description,
		VarType,
		'1-00-5010' AS VarC
FROM	Parameters
WHERE	ParameterCode = 'PRD_CREDITACCOUNT'
		AND COMPANY = 'ALL'