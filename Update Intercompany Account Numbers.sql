UPDATE	dbo.FSI_Intercompany_Companies
SET		AccountNumber = ActNumSt
FROM	(SELECT	ActIndx, ActNumSt 
		FROM	ILSGP01.NDS.DBO.GL00105) gl
WHERE	AccountIndex = ActIndx
		AND ForCompany = 'NDS'