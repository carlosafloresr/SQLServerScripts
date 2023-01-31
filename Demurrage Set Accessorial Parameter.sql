UPDATE	GPCustom.dbo.Parameters
SET		VarC = IIF(VarC = 'NONE', '395', 'NONE')
WHERE	ParameterCode = 'DEMURRAGE_ACCCODE'
		AND Company = 'GLSO' 

SELECT	Company, ParameterCode, Description, VarC AS Value
FROM	GPCustom.dbo.Parameters
WHERE	ParameterCode LIKE 'DEMURRAGE%'
		AND Company = 'GLSO'
ORDER BY Company, ParameterCode

/*
UPDATE	GPCustom.dbo.Parameters
SET		VarC = 'NONE'
WHERE	ParameterCode = 'DEMURRAGE_ACCCODE'
		AND Company = 'GLSO'

UPDATE	GPCustom.dbo.Parameters
SET		VarC = '0-05-1865'
WHERE	ParameterCode = 'DEMURRAGE_AP_CREDIT'
		AND Company = 'GLSO'
*/
