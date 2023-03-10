USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindPopUpType]    Script Date: 8/31/2016 9:35:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindPopUpType 'IMC', '1-03-6618', NULL, NULL
EXECUTE USP_FindPopUpType 'IMC', '1-09-6619', NULL, NULL
EXECUTE USP_FindPopUpType 'ATEST', '0-00-1105', NULL, NULL
EXECUTE USP_FindPopUpType 'PTS', '0-00-2782', NULL, NULL
*/
ALTER PROCEDURE [dbo].[USP_FindPopUpType]
		@Company		Varchar(5),
		@GLAccount		Varchar(25),
		@FormId			Int = Null OUTPUT,
		@FormTitle		Varchar(50) = Null OUTPUT
AS
DECLARE	@ReturnValue	Int,
		@SalesAccount	Char(4),
		@IsMandR		Bit = 0,
		@Query			Varchar(MAX)

DECLARE	@tblType		Table (IsMandR Bit)

SELECT	@SalesAccount = RTRIM(VarC)
FROM	dbo.Parameters
WHERE	ParameterCode = 'PDM_SALESACCOUNT'
		AND Company = 'ALL'

SET		@Query = N'SELECT	CASE WHEN UsrDefs2 = ''POPREPAIR'' THEN 1 ELSE 0 END AS IsMandR
				FROM	' + RTRIM(@Company) + '.dbo.GL00100 
				WHERE	ActIndx IN (SELECT	ActIndx 
									FROM	' + RTRIM(@Company) + '.dbo.GL00105 
									WHERE	ActNumSt = ''' + RTRIM(@GLAccount) + ''')'
INSERT INTO @tblType
EXECUTE(@Query)

SELECT	@IsMandR = IsMandR
FROM	@tblType

IF @IsMandR = 1
BEGIN
	SET	@ReturnValue	= 20
	SET	@FormId			= 5
	SET	@FormTitle		= 'Repairs to Customer Equipment'
END
ELSE
BEGIN
	SELECT	@ReturnValue	= ESM.EscrowModuleId,
			@FormId			= ESM.FormId,
			@FormTitle		= RTRIM(ESM.ModuleDescription)
	FROM	EscrowAccounts ESA
			INNER JOIN EscrowModules ESM ON ESA.Fk_EscrowModuleId = ESM.EscrowModuleId
	WHERE	ESA.CompanyId = @Company
			AND ESA.AccountNumber = @GLAccount
			AND ESM.EscrowModuleId <> 10
END

IF @ReturnValue IS Null
BEGIN
	SET	@ReturnValue	= 0
	SET	@FormId			= 0
	SET @FormTitle		= ''
END

PRINT 'Escrow Type: ' + CAST(@ReturnValue AS Varchar) + ' Form Type: ' + CAST(@FormId AS Varchar) + ' Is M&R: ' + CASE WHEN @IsMandR = 1 THEN 'YES' ELSE 'NO' END

RETURN @ReturnValue