create VIEW View_ExpenseRecoverables
AS
SELECT 	ER.* 
FROM 	ExpenseRecoverables ER
	LEFT JOIN EscrowTransactions ET ON ER.DriverId = ET.DriverId AND ER.Division = ET.Division AND ER.GLAccount = ET.AccountNumber AND ER.Amount = ET.Amount
WHERE 	TRXSource IS Null AND
	ET.DriverId IS Null


SELECT 	VoucherNumber,
	VendorId,
	DriverId,
	Amount,
	Comments,
	TransactionDate,
	PostingDate,
	EnteredBy 
FROM 	EscrowTransactions 
where 	accountnumber = '0-00-1102' AND CompanyiD = 'AIS'
order by VoucherNumber

SELECT * FROM AIS.DBO.PM30600 WHERE VchrNmbr = 'ER273_21380-10001' --CrdtAmnt = 143.76 or DebitAmt = 143.76

--SELECT * FROM RM00401 WHERE DocNumbr = 'DM-A12228'
SELECT * FROM PM00400 WHERE CntrlNum = '00000000000000456'
SELECT * FROM PM10000 WHERE VchrNmbr = '00000000000000456'
SELECT * FROM PM20000 WHERE VchrNmbr = '00000000000000456'
SELECT * FROM PM10100 WHERE VchrNmbr = '00000000000000456'
SELECT * FROM PM30200 WHERE VchrNmbr = '00000000000000459'
SELECT * FROM PM30600 WHERE VchrNmbr = '00000000000000456'

select * from gpcustom.dbo.EscrowTransactions