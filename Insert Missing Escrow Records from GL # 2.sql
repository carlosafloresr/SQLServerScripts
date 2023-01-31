INSERT INTO EscrowTransactions(Source, VoucherNumber, ItemNumber, CompanyId, Fk_EscrowModuleId, AccountNumber, AccountType, VendorId, Amount, Comments, TransactionDate, PostingDate, EnteredBy, EnteredOn, ChangedBy, ChangedOn)
SELECT 	'AP',
		Orctrnum,
		OrigSeqNum,
		'IMC',
		11,
		'0-00-2784',
		6,
		Ormstrid,
		CASE WHEN CrdtAmnt > 0 THEN CrdtAmnt ELSE DebitAmt * -1 END,
		Refrence,
		OrpStDdt,
		OrpStDdt,
		UswhpStd,
		TrxDate,
		UswhpStd,
		TrxDate
FROM	IMC.DBO.GL20000 
WHERE	((LEFT(Refrence, 3) = 'OOT' 
		AND MONTH(TrxDate) = 7 
		AND YEAR(TrxDate) = 2008)
		OR OrgnTsrc = 'PMTRX00000619')
		AND ActIndx = 1705

/*

SELECT	*
FROM	IMC.DBO.GL20000 
WHERE	((LEFT(Refrence, 3) = 'OOT' 
		AND MONTH(TrxDate) = 7 
		AND YEAR(TrxDate) = 2008)
		OR OrgnTsrc = 'PMTRX00000619')
		AND ActIndx = 1705

SELECT	TrxDate
		,VoucherNumber
		,VendorId
		,Amount
		,AccountNumber
FROM	MissingEscrow
*/