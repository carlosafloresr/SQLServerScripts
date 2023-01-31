SELECT	G5.ACTINDX,  
		G5.ACTNUMST,
		G1.ACTDESCR,
		IIF(EA.AccountNumber IS Null, 'N', 'Y') AS EscrowRequired,
		ISNULL(EM.FormId, '') AS FormType
FROM	GL00105 G5
		INNER JOIN GL00100 G1 ON G5.ACTINDX = G1.ACTINDX
		LEFT JOIN GPCustom.dbo.EscrowAccounts EA ON G5.ACTNUMST = EA.AccountNumber AND EA.CompanyId = DB_NAME()
		LEFT JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
ORDER BY G5.ACTNUMST