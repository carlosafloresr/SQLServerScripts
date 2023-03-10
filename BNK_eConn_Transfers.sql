USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[BNK_eConn_Transfers]    Script Date: 8/26/2016 2:23:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
===================================================================================
Author:			Percy Brown
Create date:	2012-08-07
Description:	Return transactions from bai_code 165 for export to xml node.
===============================================================================
Updated By:		Carlos A. Flores
Update on:		2016-08-12 8:01 AM
Description:	The script was changed to a dynamic one instead of static
===================================================================================
EXEC BNK_eConn_Transfers @CompanyID = 1, @ChekBkId = 'CREDIT LINE', @BAIFileName = 'BAI_20160826_0220.txt'
EXEC BNK_eConn_Transfers @CompanyID = 1, @ChekBkId = 'PAYROLL', @BAIFileName = 'BAI_20160826_0220.txt'
EXEC BNK_eConn_Transfers @CompanyID = 1, @ChekBkId = 'REGIONS AP', @BAIFileName = 'BAI_20160826_0220.txt'
EXEC BNK_eConn_Transfers @CompanyID = 11, @ChekBkId = 'DEP', @BAIFileName = 'BAI_20160826_0220.txt'
EXEC BNK_eConn_Transfers @CompanyID = 32, @ChekBkId = 'DEPOSITORY', @BAIFileName = 'BAI_20160826_0220.txt', @IsRecon = 1
===================================================================================
*/
ALTER PROCEDURE [dbo].[BNK_eConn_Transfers] 
	@CompanyID		Int,
	@ChekBkId		Varchar(15),
	@BAIFileName	Varchar(50),
	@IsRecon		Bit = 0
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT	DISTINCT BAI.BAI_DetailId, 
		BAI.TrxDate, 
		BAI.AbaNum, 
		BAI.Currency, 
		BAI.AcctNum, 
		BAI.AcctName,
		BAI_HeaderId,
		BAI.[Description], 
		BAI.BAI_Code, 
		BAI.Amount, 
		BAI.Serial_Num,
		BAI.Ref_Num, 
		BAI.Detail, 
		BAI.UploadDate, 
		BAI.IsRecon, 
		BAI.ReconDate, 
		BAI.Cmpanyid,
		BAI.Company,
		BAI.XferFromAcct,
		BAI.ACTNUMST,
		SEC.CHEKBKID AS CHEKBKIDFROM,
		SEC.ACTNUMST AS ACTNUMSTFROM,
		SEC.ChekBkId
FROM	View_BAI_BankTransactions BAI
		LEFT JOIN GP_Bank_Accounts SEC ON BAI.CmpanyId = SEC.CmpanyId AND BAI.XferFromAcct = SEC.BNKACTNM
WHERE	BAI.IsTransfer = 1
		AND BAI.Detail <> 'REGN LOAN TRANS'
		--AND BAI.BAIFileName = @BAIFileName
		AND BAI.CmpanyId = @CompanyID 
		AND BAI.IsRecon = @IsRecon
		AND BAI.AcctName = RTRIM(@ChekBkId)
ORDER BY 
		BAI.TrxDate, 
		BAI.Serial_Num, 
		BAI.Amount