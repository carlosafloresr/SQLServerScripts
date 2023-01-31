SELECT	*
FROM	Parameters
WHERE	VarC LIKE '%ILSFTP%'

UPDATE	Parameters
SET		VarC = '\\PRIAPINT01P\ILS_Documents$\'
WHERE	ParameterCode = 'DOCSLOCATION'
