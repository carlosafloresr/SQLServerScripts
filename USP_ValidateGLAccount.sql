ALTER PROCEDURE USP_ValidateGLAccount (@Company Varchar(5), @GLAccount Varchar(20) = Null, @AccountIndex Int = Null)
AS
IF @Company = 'AIS'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	AIS.dbo.GL00105 GL5
			INNER JOIN AIS.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'DNJ'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	DNJ.dbo.GL00105 GL5
			INNER JOIN DNJ.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'FI'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	FI.dbo.GL00105 GL5
			INNER JOIN FI.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'GIS'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	GIS.dbo.GL00105 GL5
			INNER JOIN GIS.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'IILS'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	IILS.dbo.GL00105 GL5
			INNER JOIN IILS.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'IMC'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	IMC.dbo.GL00105 GL5
			INNER JOIN IMC.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'NDS'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	NDS.dbo.GL00105 GL5
			INNER JOIN NDS.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'RCCL'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	RCCL.dbo.GL00105 GL5
			INNER JOIN RCCL.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

IF @Company = 'RCMR'
BEGIN
	SELECT	GL5.ActIndx,
			GL5.ActNumSt,
			GL0.ActDescr,
			GL0.Active
	FROM	RCMR.dbo.GL00105 GL5
			INNER JOIN RCMR.dbo.GL00100 GL0 ON GL0.ActIndx = GL5.ActIndx
	WHERE	(@GLAccount IS NOT Null AND GL5.ActNumSt = @GLAccount) OR
			(@AccountIndex IS NOT Null AND GL5.ActIndx = @AccountIndex)
END

/*
EXECUTE USP_ValidateGLAccount 'imc', '1-01-6140'
EXECUTE USP_ValidateGLAccount 'AIS', Null, 1507
*/

SELECT * FROM KarmakIntegration