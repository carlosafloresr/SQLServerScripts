SELECT	*
FROM	Parameters
WHERE	VarC LIKE '\\%'
ORDER BY VARC 

UPDATE	GPCustom.dbo.Parameters
SET		VarC = '\\SECFILE04\fismb\1\'
WHERE	ParameterCode = 'FIDEPOT_EDI_DOCUMENTS'

11/14/2019 8:30 AM