INSERT INTO Integrations.dbo.MSR_Accounts
		(Company
		,Customer
		,AccountType
		,AccountNumber
		,Limit
		,Equipment
		,CompanyEquipment
		,Intercompany)
SELECT	Company
		,'FTWIME' AS Customer
		,AccountType
		,AccountNumber
		,Limit
		,Equipment
		,CompanyEquipment
		,Intercompany
FROM	Integrations.dbo.MSR_Accounts
WHERE	Customer = 'MEMIDE'