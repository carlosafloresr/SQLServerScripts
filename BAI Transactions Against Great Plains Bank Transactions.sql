-- EXECUTE USP_Bank_Accounts

SELECT	BAI.Description,
		BAI.BAI_Code,
		BAI.Amount,
		BAI.Serial_Num,
		BAI.Detail,
		BAI.AcctNum,
		BAI.AcctName,
		BAI.UploadDate,
		BAI.TrxDate,
		BAI.BAI_Code,
		GPT.TrxAmnt,
		GPT.CMRECNUM,
		GPT.sRecNum
FROM	View_BAI_BankTransactions BAI
		LEFT JOIN AIS.dbo.CM20200 GPT ON BAI.Serial_Num = GPT.CMTrxNum AND BAI.Amount = GPT.TrxAmnt --AND BAI.AcctName  = GPT.CHEKBKID
WHERE	BAI.BAIFileName = 'BAI_20160824_0221.txt'
		AND BAI.Company = 'AIS'
		--AND IsTransfer = 1
		--AND IsRecon = 1
		--AND Amount = 45898.46

SELECT	*
FROM	AIS.dbo.CM20600
WHERE	CMXFTDATE > '08/01/2016'
--		AND ORIGAMT = 45898.46

SELECT	*
FROM	AIS.dbo.CM20200
WHERE	
--CHEKBKID = 'AP'
		--AND TRXDATE >= '08/23/2016'
		CMTrxNum = '00002016236          '
--CMCHKBKID = 'AP'