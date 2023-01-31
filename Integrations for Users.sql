/*
EXECUTE USP_User_Integrations 'CFLORES'
*/
ALTER PROCEDURE USP_User_Integrations
		@UserId				Varchar(25)
AS
DECLARE	@WithGPModules		Bit,
		@WithIntegrations	Bit

DECLARE	@tblIntegration		Table (Integration Varchar(10))

IF EXISTS(SELECT TOP 1 UserId FROM User_GPModules WHERE UserId = @UserId)
	SET @WithGPModules = 1
ELSE
	SET @WithGPModules = 0

IF EXISTS(SELECT TOP 1 UserId FROM User_Integrations WHERE UserId = @UserId)
BEGIN
	SET @WithIntegrations = 1

	INSERT INTO @tblIntegration
	SELECT Integration FROM User_Integrations WHERE UserId = @UserId
END
ELSE
	SET @WithIntegrations = 0

SELECT	@UserId AS UserId,
		TBL1.GPModule,
		CASE TBL1.GPModule 
			WHEN 'AP' THEN 'Accounts Payables'
			WHEN 'AR' THEN 'Accounts Receivables'
			WHEN 'GL' THEN 'General Ledger'
			WHEN 'HR' THEN 'Human Resources'
			WHEN 'SOP' THEN 'Sale Invoices'
		END AS ModuleName,
		TBL1.Integration,
		TBL1.Description,
		CASE WHEN @WithGPModules = 0 AND @WithIntegrations = 0 THEN 1 
			 WHEN @WithGPModules = 1 AND @WithIntegrations = 0 AND EXISTS(SELECT TBL2.GPModule FROM User_GPModules TBL2 WHERE TBL2.GPModule = TBL1.GPModule AND TBL2.UserId = @UserId) THEN 1 
			 WHEN @WithGPModules = 1 AND @WithIntegrations = 1 AND EXISTS(SELECT TBL3.Integration FROM User_Integrations TBL3 WHERE TBL3.Integration = TBL1.Integration AND TBL3.UserId = @UserId) THEN 1 
		ELSE 0 END AS Selected
FROM	Integrations TBL1
WHERE	TBL1.Inactive = 0
ORDER BY TBL1.GPModule, TBL1.Integration