/*
SELECT	*
FROM	PARAMETERS
WHERE	ParameterCode = 'EFSMC_APACCOUNT'
*/
INSERT INTO PARAMETERS (Company, ParameterCode, Description, Vartype, VarC)
VALUES
		('NDS',
		'EFSMC_APACCOUNT',
		'EFS Manual Checks Ap Account',
		'C',
		'00-00-2070')