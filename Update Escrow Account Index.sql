select * from gpcustom.dbo.EscrowAccounts
select * from GL00100 where ActIndx in (1776, 1777)


UPDATE 	GPCustom.dbo.EscrowAccounts
SET 	AccountIndex = GL00105.ActIndx
FROM	GL00105
WHERE	GPCustom.dbo.EscrowAccounts.AccountNumber = GL00105.ACTNUMST
		AND GPCustom.dbo.EscrowAccounts.CompanyId = 'DNJ'