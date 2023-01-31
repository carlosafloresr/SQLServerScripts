--INSERT INTO GPCustom.dbo.EscrowTransactions
--		(Source, 
--		VoucherNumber, 
--		ItemNumber, 
--		CompanyId, 
--		Fk_EscrowModuleId, 
--		AccountNumber, 
--		AccountType, 
--		VendorId, 
--		Amount, 
--		Comments, 
--		TransactionDate, 
--		PostingDate, 
--		EnteredBy, 
--		EnteredOn, 
--		ChangedBy, 
--		ChangedOn)
SELECT 	'AP',
		GL1.Orctrnum,
		GL1.OrigSeqNum,
		DB_NAME(),
		ESA.Fk_EscrowModuleId,
		RTRIM(GL5.ACTNUMST),
		6,
		GL1.Ormstrid,
		CASE WHEN CrdtAmnt > 0 THEN CrdtAmnt ELSE DebitAmt * -1 END,
		GL1.Refrence,
		GL1.OrpStDdt,
		GL1.OrpStDdt,
		GL1.UswhpStd,
		GL1.TrxDate,
		GL1.UswhpStd,
		GL1.TrxDate
FROM	GL20000 GL1
		INNER JOIN GL00105 GL5 ON GL1.ACTINDX = GL5.ACTINDX
		INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON GL5.ACTNUMST = ESA.AccountNumber AND ESA.CompanyId = DB_NAME()
WHERE	--GL5.ACTNUMST IN ('0-00-2795','0-01-2794')
		GL1.ORMSTRID <> ''
		AND GL1.Orctrnum = 'EFSMC_08162021'