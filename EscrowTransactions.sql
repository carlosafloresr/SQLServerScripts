SELECT * FROM EscrowTransactions WHERE VoucherNumber = 'ERDM_207420027' AND CompanyId = 'AISTE' AND Fk_EscrowModuleId = 5 AND AccountNumber = '0-00-1102' AND AccountType = 2 AND Source = 'AP'

update EscrowTransactions set AccountType = 2 WHERE Fk_EscrowModuleId = 2
update EscrowTransactions set Source = 'AP' WHERE Source = 'DM' Fk_EscrowModuleId = 5

DELETE EscrowTransactions WHERE LEFT(VoucherNumber, 2)= 'ED'

SELECT * FROM EscrowTransactions WHERE VoucherNumber = 'EDA0030_3253_473' AND CompanyId = 'AISTE' AND Fk_EscrowModuleId = 2 AND AccountNumber = '0-02-2790' AND AccountType = 2 AND Source = 'AP'
SELECT * FROM EscrowTransactions WHERE VoucherNumber = 'EDA0107_13851_119' AND CompanyId = 'AISTE' AND Fk_EscrowModuleId = 2 AND AccountNumber = '0-00-2790' AND AccountType = 2 AND Source = 'AP'