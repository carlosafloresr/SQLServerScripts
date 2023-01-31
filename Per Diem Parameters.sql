SELECT	Company, ParameterCode, Description, VarC AS Value
FROM	Parameters
WHERE	ParameterCode LIKE 'PRD_%'
