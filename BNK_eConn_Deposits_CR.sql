USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[BNK_eConn_Deposits_CR]    Script Date: 8/16/2016 8:30:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
================================================================================
Author:			Percy Brown
Create date:	2012-08-07
Description:	Return transactions from bai_code 175 for export to xml node.
================================================================================
Updated By:		Carlos A. Flores
Update on:		2016-08-10 9:30 AM
Description:	The script was changed to a dynamic one instead of static
================================================================================
EXEC [dbo].[BNK_eConn_Deposits_CR] @CompanyID = 1, @ChekBkId = 'REGIONS AP'
EXEC [dbo].[BNK_eConn_Deposits_CR] @CompanyID = 4, @ChekBkId = 'REGIONS - DEP'
EXEC [dbo].[BNK_eConn_Deposits_CR] @CompanyID = 1, @ChekBkId = 'DEP'
EXEC [dbo].[BNK_eConn_Deposits_CR] @CompanyID = 20, @ChekBkId = 'DEPOSITORY'
EXEC [dbo].[BNK_eConn_Deposits_CR] @CompanyID = 21, @ChekBkId = 'DEPOSIT'
EXEC [dbo].[BNK_eConn_Deposits_CR] @CompanyID = 24, @ChekBkId = 'DISB'
================================================================================
*/
ALTER PROCEDURE [dbo].[BNK_eConn_Deposits_CR] 
	@CompanyID	Int,
	@ChekBkId	Varchar(15)
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN
	DECLARE	@CompanyDB	Varchar(5),
			@Query		Varchar(Max)

	SELECT	@CompanyDB = RTRIM(InterId)
	FROM	DYNAMICS.dbo.View_AllCompanies
	WHERE	CmpanyId = @CompanyID

	SET @Query = N'SELECT	CONVERT(varchar(12), BAI.TrxDate, 101) AS TrxDate, 
						BAI.AbaNum, 
						BAI.Currency, 
						BAI.AcctNum, 
						BAI.AcctName, 
						BAI.FK_Bank_HeaderId, 
						BAI.[Description],
						BAI.BAI_Code, 
						CM.RCPTAMT AS [Amount], 
						CM.RCPTNMBR AS Serial_Num,
						BAI.Ref_Num, 
						BAI.Detail, 
						BAI.UploadDate, 
						BAI.IsRecon, 
						BAI.ReconDate, 
						BAI.Cmpanyid,
						CM.GLPOSTDT, 
						CM.CHEKBKID, 
						CM.RCPTNMBR, 
						CM.CMRECNUM, 
						CM.RCPTAMT, 
						CM.AUDITTRAIL, 
						SRCPTAMT
				FROM	dbo.BAI_Detail BAI 
						INNER JOIN (
									SELECT	CHEKBKID, 
											GLPOSTDT,
											RCPTNMBR,
											CMRECNUM,
											CM.RCPTAMT,
											SUM(CM.RCPTAMT) OVER (PARTITION BY CM.AUDITTRAIL) AS SRCPTAMT, 
											AUDITTRAIL
									FROM	' + @CompanyDB + '.dbo.CM20300 CM 
									WHERE	CM.DEPOSITED = 0
									) CM ON BAI.Amount = CM.SRCPTAMT
				WHERE	BAI.BAI_Code = ''175'' 
						AND CM.CHEKBKID = ''' + RTRIM(@ChekBkId) + '''
						AND BAI.Cmpanyid = ''' + CAST(@CompanyID AS Varchar) + ''''

	EXECUTE(@Query)
END