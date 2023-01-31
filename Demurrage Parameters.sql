SELECT	Company, ParameterCode, Description, VarC AS Value, ParameterId
FROM	Parameters
WHERE	ParameterCode like 'DEMURRAGE%'
		--AND Company = 'GLSO' 
ORDER BY Company, ParameterCode
 
/*
UPDATE	Parameters
SET		VarC = '395'
WHERE	ParameterId = 786

UPDATE	Parameters
SET		VarC = 'DEM'
WHERE	ParameterCode = 'DEMURRAGE_ACCCODE'

select * from Parameters where Parameterid = 789
delete Parameters where Parameterid = 732
*/
