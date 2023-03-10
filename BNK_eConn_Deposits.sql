USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[BNK_eConn_Deposits]    Script Date: 8/26/2016 2:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
===============================================================================
Author:			Percy Brown
Create date:	2012-08-07
Description:	Return transactions from bai_code 165 for export to xml node.
===============================================================================
Updated By:		Carlos A. Flores
Update on:		2016-08-10 9:20 AM
Description:	The script was changed to a dynamic one instead of static
===============================================================================
EXEC [dbo].[BNK_eConn_Deposits] @CompanyID = 1, @ChekBkId = 'REGIONS AP', @BAIFileName= 'BAI_20160817_0220.txt'
EXEC [dbo].[BNK_eConn_Deposits] @CompanyID = 4, @ChekBkId = 'REGIONS - DEP', @BAIFileName= 'BAI_20160817_0220.txt'
EXEC [dbo].[BNK_eConn_Deposits] @CompanyID = 1, @ChekBkId = 'DEP', @BAIFileName= 'BAI_20160817_0220.txt'
EXEC [dbo].[BNK_eConn_Deposits] @CompanyID = 20, @ChekBkId = 'DEPOSITORY', @BAIFileName= 'BAI_20160817_0220.txt'
EXEC [dbo].[BNK_eConn_Deposits] @CompanyID = 21, @ChekBkId = 'DEPOSIT', @BAIFileName= 'BAI_20160817_0220.txt'
EXEC [dbo].[BNK_eConn_Deposits] @CompanyID = 24, @ChekBkId = 'DISB', @BAIFileName= 'BAI_20160817_0220.txt'
===============================================================================
*/
ALTER PROCEDURE [dbo].[BNK_eConn_Deposits] 
	@CompanyID		Int,
	@ChekBkId		Varchar(15),
	@BAIFileName	Varchar(50)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN
	DECLARE	@CompanyDB	Varchar(5),
			@Query		Varchar(Max)

	SELECT	@CompanyDB = RTRIM(InterId)
	FROM	DYNAMICS.dbo.View_AllCompanies
	WHERE	CmpanyId = @CompanyID

	SET @Query = N'SELECT	BAI.TrxDate, 
					BAI.AbaNum, 
					BAI.Currency, 
					BAI.AcctNum, 
					'''' AS AcctName, 
					BAI.BAI_HeaderId AS FK_Bank_HeaderId, 
					BAI.[Description],
					BAI.BAI_Code, 
					BAI.Amount, 
					CASE WHEN RTRIM(ISNULL(BAI.Serial_Num, CM.RCPTNMBR)) = '''' THEN CM.RCPTNMBR ELSE BAI.Serial_Num END AS Serial_Num,
					BAI.Ref_Num, 
					BAI.Detail, 
					BAI.UploadDate, 
					BAI.IsRecon, 
					BAI.ReconDate, 
					BAI.CmpanyId,
					BAI.Company,
					CM.GLPOSTDT, 
					CM.CHEKBKID, 
					CM.RCPTNMBR, 
					CM.CMRECNUM, 
					CM.RCPTAMT, 
					CM.AUDITTRAIL, 
					BAI.Amount AS SRCTAMT 
			FROM	dbo.View_BAI_BankTransactions BAI 
					INNER JOIN ' + @CompanyDB + '.dbo.CM20300 CM ON BAI.Amount = CM.RCPTAMT 
			WHERE	BAI.IsDeposit = 1
					AND CM.CHEKBKID = ''' + RTRIM(@ChekBkId) + '''
					AND BAI.CmpanyId = ''' + CAST(@CompanyID AS Varchar) + '''
					AND CM.DEPOSITED = 0'

	EXECUTE(@Query)

	-- AND BAI.BaiFileName = ''' + RTRIM(@BAIFileName) + '''
END