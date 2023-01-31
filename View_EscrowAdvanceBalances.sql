CREATE VIEW View_EscrowAdvanceBalances
AS
SELECT	ET.CompanyId
		,ET.VendorId
		,ET.Fk_EscrowModuleId
		,ET.AccountNumber
		,ISNULL(EA.AccountAlias, dbo.GetAccountName(ET.CompanyId, EA.AccountIndex)) AS AccountAlias
		,SUM(ET.Amount) AS Balance
FROM	EscrowTransactions ET
		INNER JOIN EscrowAccounts EA ON ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId AND ET.CompanyId = EA.CompanyId AND ET.AccountNumber = EA.AccountNumber
WHERE	ET.Fk_EscrowModuleId IN (1,2,3,8,11)
		AND ET.PostingDate IS NOT Null
		AND ET.DeletedBy IS Null
GROUP BY
		ET.CompanyId
		,ET.VendorId
		,ET.Fk_EscrowModuleId
		,ET.AccountNumber
		,ISNULL(EA.AccountAlias, dbo.GetAccountName(ET.CompanyId, EA.AccountIndex))