USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Bank_Accounts_WithData]    Script Date: 8/29/2016 8:58:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Bank_Accounts_WithData 'FirstTennessee_20160816.txt' 
EXECUTE USP_Bank_Accounts_WithData 'BAI_20160824_0221.txt'
*/
ALTER PROCEDURE [dbo].[USP_Bank_Accounts_WithData]
		@BAIFileName	Varchar(50)
AS
EXECUTE USP_Import_GPCheckBooks

SELECT	GBA.*,
		HDR.UploadDate AS LastDate
FROM	GP_Bank_Accounts GBA
		INNER JOIN BAI_Header HDR ON GBA.BNKACTNM = HDR.AcctNum AND GBA.CMPANYID = HDR.CMPANYID
WHERE	HDR.BaiFileName = @BAIFileName
		AND HDR.BegBal + HDR.DepCr + HDR.ChkDb + HDR.UnCr + HDR.UnDb + HDR.EndBal <> 0
ORDER BY
		GBA.Company,
		GBA.BnkActNm