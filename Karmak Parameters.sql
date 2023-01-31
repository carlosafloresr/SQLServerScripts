SELECT	ParameterCode, Description, VarType, 
		CASE WHEN VarType = 'N' THEN CAST(VarN AS Varchar)
			 WHEN VarType = 'C' THEN VarC END AS vALUE
FROM	Parameters
WHERE	ParameterCode LIKE 'KARMAK_%'
ORDER BY ParameterCode