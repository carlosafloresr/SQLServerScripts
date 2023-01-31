CREATE PROCEDURE USP_FRS_PrepareForProduction
AS
UPDATE	Parameters
SET		VarC = 'FI'
WHERE	ParameterCode = 'NEWPORT_FRS_COMPANY'

DELETE	ILSINT02.Integrations.dbo.FRS_Integrations

DELETE	LENSASQL002.Manifest.dbo.Transactions

DELETE	LENSASQL002.Manifest.dbo.AdditionalValues
GO