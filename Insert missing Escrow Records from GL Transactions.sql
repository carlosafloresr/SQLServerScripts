DECLARE @tblSpecialData Table (Company Varchar(5), VendorId Varchar(12), DrayageBonus Numeric(10,2))

INSERT INTO @tblSpecialData
SELECT	Company, VendorId, DrayageBonus
FROM	GPCustom.dbo.SAFETYBONUS
WHERE	COMPANY = 'OIS'
		AND PERIOD = '2022-1'
		AND SORTCOLUMN = 0
ORDER BY VENDORID

INSERT INTO GPCustom.dbo.EscrowTransactions
		(Source, 
		VoucherNumber, 
		ItemNumber, 
		CompanyId, 
		Fk_EscrowModuleId, 
		AccountNumber, 
		AccountType, 
		VendorId, 
		Amount, 
		Comments, 
		TransactionDate, 
		PostingDate, 
		EnteredBy, 
		EnteredOn, 
		ChangedBy, 
		ChangedOn,
		BatchId)
SELECT 	'GL' AS [Source],
		GL1.Orctrnum,
		GL1.OrigSeqNum,
		DB_NAME() AS Company,
		ESA.Fk_EscrowModuleId,
		RTRIM(GL5.ACTNUMST) AS AccountNumber,
		6 AS AccountType,
		SPD.Vendorid, --GL1.Ormstrid,
		CASE WHEN CrdtAmnt > 0 THEN CrdtAmnt ELSE DebitAmt * -1 END AS Amount,
		GL1.Refrence,
		GL1.OrpStDdt,
		GL1.OrpStDdt,
		GL1.UswhpStd,
		GL1.TrxDate,
		GL1.UswhpStd,
		GL1.TrxDate,
		GL1.ORGNTSRC
FROM	GL20000 GL1
		INNER JOIN GL00105 GL5 ON GL1.ACTINDX = GL5.ACTINDX
		INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON GL5.ACTNUMST = ESA.AccountNumber AND ESA.CompanyId = DB_NAME()
		LEFT JOIN @tblSpecialData SPD ON CASE WHEN CrdtAmnt > 0 THEN CrdtAmnt ELSE DebitAmt * -1 END = SPD.DrayageBonus AND SPD.VendorId LIKE (RIGHT(RTRIM(GL1.Refrence), 5) + '%')
WHERE	GL1.ORGNTSRC = 'SBA_20220204'
		--AND GL5.ACTNUMST = '0-00-2590'
		