SELECT 	Description, 
	VarC,
	Account
FROM 	Parameters PA
	LEFT JOIN (SELECT RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + RTRIM(ActNumbr_3) AS Account FROM AIS.dbo.GL00100) GL ON rtrim(PA.VarC) = GL.Account
WHERE 	PATINDEX('%-%', VarC) > 0 AND 
	LEN(RTRIM(VarC)) < 12