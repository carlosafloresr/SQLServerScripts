-- select * from EscrowTransactions where EnteredBy = 'MIG_00_1081

-- update EscrowTransactions set AccountNumber = '0-' + ltrim(rtrim(AccountNumber)) where Left(EnteredBy, 4) = 'MIG_'

SELECT MIN(PostingDate) AS FirstDate, MAX(PostingDate) AS LastDate FROM EscrowTransactions WHERE CompanyId = 'IMCT' AND Fk_EscrowModuleId = 2 AND AccountNumber = '0-00-2790'

update	EscrowTransactions 
set		EscrowTransactions.Fk_EscrowModuleId = EscrowAccounts.Fk_EscrowModuleId
from	EscrowAccounts
where	Left(EscrowTransactions.EnteredBy, 4) = 'MIG_' and
		EscrowAccounts.AccountNumber = EscrowTransactions.AccountNumber AND
		EscrowAccounts.CompanyId = EscrowTransactions.CompanyId and
		EscrowTransactions.AccountNumber = '0-00-1081'


select * from EscrowTransactions where Left(EscrowTransactions.EnteredBy, 4) = 'MIG_' and AccountNumber = '0-00-1081'

delete EscrowTransactions where Left(EscrowTransactions.VoucherNumber, 5) = 'EBAL_'

select * from EscrowTransactions where Left(EscrowTransactions.VoucherNumber, 5) = 'EBAL_'

update EscrowTransactions set EnteredBy = 'MIG_00_1081', ChangedBy = 'MIG_00_1081' where Left(EscrowTransactions.EnteredBy, 4) = 'MIG_' and AccountNumber = '0-00-1081'

delete dynamics.dbo.SY00800 where BCHSOURC = 'aaWizardInstall'

update EscrowTransactions set VendorId = LTRIM(RTRIM(VendorId))

SELECT ES.*, UPPER(ActDescr) AS ActDescr FROM EscrowAccounts ES LEFT JOIN IMCT.dbo.GL00100 GL ON ES.AccountIndex = GL.ActIndx WHERE ES.CompanyId = 'IMCT' AND ES.Fk_EscrowModuleId = 8 AND AccountNumber IN (SELECT AccountNumber FROM EscrowTransactions WHERE CompanyId = 'IMCT' AND Fk_EscrowModuleId = 8) ORDER BY ES.AccountNumber 

select * from EscrowTransactions where vouchernumber = '27979'

SELECT ES.*, UPPER(ActDescr) AS ActDescr FROM EscrowAccounts ES LEFT JOIN IMCT.dbo.GL00100 GL ON ES.AccountIndex = GL.ActIndx WHERE ES.CompanyId = 'IMCT' AND ES.Fk_EscrowModuleId = 5 AND AccountNumber IN (SELECT AccountNumber FROM EscrowTransactions WHERE CompanyId = 'IMCT' AND Fk_EscrowModuleId = 5) ORDER BY ES.AccountNumber

SELECT ES.*, UPPER(ActDescr) AS ActDescr FROM EscrowAccounts ES LEFT JOIN IMCT.dbo.GL00100 GL ON ES.AccountIndex = GL.ActIndx WHERE ES.CompanyId = 'IMCT' AND ES.Fk_EscrowModuleId = 5 ORDER BY ES.AccountNumber