SELECT	*
FROM	Parameters
WHERE	--ParameterCode = 'FSIVENDORDEBACCT' --'ICB_BALANCEACCOUNT'
		ParameterCode LIKE 'ICB_DEBACCT'
ORDER BY ParameterCode, Company

/*
INSERT INTO Parameters (Company, ParameterCode, Description, VarType, VarC)
SELECT	Company, 
		'ICB_BALANCEACCOUNT' AS ParameterCode, 
		'ICB Balance Account' AS Description, 
		VarType, 
		VarC
FROM	dbo.Parameters
WHERE	VarType = 'C'
		AND ParameterCode = 'FSIVENDORPREPAYCREACCT'
*/