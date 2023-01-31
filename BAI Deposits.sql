DECLARE	@FileName Varchar(50) = 'BAI_20160817_0220.txt'

SELECT	BAI.*,
		CMT.depositnumber,
		CMT.RCPTNMBR,
		CMT.receiptdate,
		CMT.RcvdFrom,
		CMT.DSCRIPTN
FROM	View_BAI_BankTransactions BAI
		LEFT JOIN OIS.dbo.CM20300 CMT ON BAI.Amount = CMT.RCPTAMT
WHERE	BAI.BegBal + BAI.DepCr + BAI.ChkDb + BAI.UnCr + BAI.UnDb + BAI.EndBal <> 0
		--AND BAI.BaiFileName = @FileName
		AND BAI.Amount = 21770.68
		--AND BAI.IsDeposit = 1
		--AND BAI.Company IN ('GLSO', 'OIS')
ORDER BY BAI.Amount
/*
SELECT	*
FROM	OIS.dbo.CM20300
WHERE	DEPOSITED = 1
*/