create VIEW View_EscrowAccounts
AS
SELECT	ESA.EscrowAccountId
		,ESA.CompanyId
		,CPY.CompanyNumber
		,ESA.Fk_EscrowModuleId
		,ESM.ModuleDescription
		,ESA.AccountIndex
		,ESA.AccountNumber
		,ESA.AccountAlias
		,CASE WHEN ESA.RemittanceAdvise = 1 OR ESM.RemittanceAdvise = 1 THEN 1 ELSE 0 END AS RemittanceAdvise
		,ESM.BalanceInquiry
		,ESA.Nature
		,ESA.ShortCode
		,ESA.Increase
		,ESA.RequiresSalesDocument
		,ESA.ExpenseRecoveryByProNumber
		,ESA.MobileAppVisible
FROM	GPCustom.dbo.EscrowAccounts ESA
		INNER JOIN GPCustom.dbo.EscrowModules ESM ON ESA.Fk_EscrowModuleId = ESM.EscrowModuleId
		INNER JOIN GPCustom.dbo.Companies CPY ON ESA.CompanyId = CPY.CompanyId