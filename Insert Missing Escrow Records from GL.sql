SELECT * FROM AIS.DBO.GL20000 WHERE JrnEntry IN (4053,
4067,
4073,
4100,
4102,
4109,
4113,
4697,
4703,
4705,
4710,
4715,
4719,
4721,
4726)
SELECT * FROM EscrowTransactions WHERE EnteredBy ='HDOYLE' AND EnteredOn >= '11/9/2007'
update EscrowTransactions set postingdate = transactiondate WHERE EnteredBy ='HDOYLE' AND EnteredOn >= '11/9/2007'
delete EscrowTransactions where EscrowTransactionid >= 18935 and Source = 'AP' and accounttype = '99'

INSERT INTO EscrowTransactions(Source, VoucherNumber, ItemNumber, CompanyId, Fk_EscrowModuleId, AccountNumber, AccountType, VendorId, Amount, Comments, TransactionDate, PostingDate, EnteredBy, EnteredOn, ChangedBy, ChangedOn)
SELECT 	'GL',
	CAST(JrnEntry AS Char(15)),
	SeqNumbr,
	'AIS',
	8,
	'0-01-2785',
	99,
	SUBSTRING(OrmStrNm, PATINDEX('%#A%', OrmStrNm) + 1, 5),
	CASE WHEN CrdtAmnt > 0 THEN CrdtAmnt ELSE DebitAmt * -1 END,
	Refrence,
	OrpStDdt,
	OrpStDdt,
	UswhpStd,
	TrxDate,
	UswhpStd,
	TrxDate
FROM 	AIS.DBO.GL20000 WHERE JrnEntry IN (4091,
4095,
4103,
4693,
4698,
4706,
4711)