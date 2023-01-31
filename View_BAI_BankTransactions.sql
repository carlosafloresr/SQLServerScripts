ALTER VIEW [dbo].[View_BAI_BankTransactions]
AS
SELECT	HDR.BAI_HeaderId
		,HDR.TrxDate
		,HDR.AbaNum
		,HDR.Currency
		,HDR.AcctNum
		,RTRIM(GBA.CHEKBKID) AS AcctName
		,HDR.BegBal
		,HDR.DepCr
		,HDR.ChkDb
		,HDR.UnCr
		,HDR.UnDb
		,HDR.EndBal
		,HDR.UploadDate
		,HDR.BaiFileName
		,HDR.Cmpanyid
		,DET.Description
		,DET.BAI_Code
		,DET.Amount
		,CASE WHEN RTRIM(DET.Serial_Num) = '' THEN 'XFR' + CONVERT(varchar(8), DET.TrxDate, 112) + RIGHT(RTRIM(DET.AcctNum),4) + CAST(ROW_NUMBER() OVER(PARTITION BY DET.TrxDate ORDER BY DET.TrxDate) AS Varchar(6)) ELSE DET.Serial_Num END AS [Serial_Num]
		,REPLACE(DET.Ref_Num, '/', '') AS Ref_Num
		,REPLACE(DET.Detail, '/', '') AS Detail
		,DET.IsRecon
		,DET.ReconDate
		,COM.InterId AS Company
		,CASE WHEN DET.BAI_Code IN ('165','171','275','577','175') THEN 1 ELSE 0 END AS IsDeposit
		,CASE WHEN DET.BAI_Code IN ('171', '275', '481', '575', '577') THEN 1 ELSE 0 END AS IsTransfer
		,CASE WHEN DET.BAI_Code IN ('171', '275', '481', '575', '577') THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DET.Detail, 'TRANSFER TO ',''), 'ADV FROM CR LINE ',''), 'TRANSFER FR ', ''), 'PAY TO CR LINE ', ''), '/', '') ELSE '' END AS [XferFromAcct]
		,DET.BAI_DetailId
		,GBA.ACTNUMST
FROM	BAI_Header HDR
		INNER JOIN BAI_Detail DET ON HDR.BAI_HeaderId = DET.FK_Bank_HeaderId AND HDR.AbaNum = DET.AbaNum AND HDR.AcctNum = DET.AcctNum
		INNER JOIN DYNAMICS.dbo.View_AllCompanies COM ON HDR.CmpanyId = COM.CmpanyId 
		LEFT JOIN GP_Bank_Accounts GBA ON HDR.CmpanyId = GBA.CmpanyId AND HDR.AcctNum = GBA.BnkActNm


GO


