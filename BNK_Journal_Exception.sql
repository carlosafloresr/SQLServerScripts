USE GPCustom
GO
/****** Object:  StoredProcedure dbo.BNK_Journal_Exception    Script Date: 8/16/2016 9:49:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
============================================================================================================================
Author:			Percy Brown
Create date:	2012-09-26
Description:	Retrieve bank transactions that are not entered 
				in the cash management journal of Dynamics GP
============================================================================================================================
EXEC BNK_Journal_Exception @UpLoadDate = '2016-08-11', @AcctNum = '8000525354', @ChekBkId = 'DEP', @CompanyID = 1
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '8000525367', @ChekBkId = 'PAYROLL', @CompanyID = 1
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '8000525370', @ChekBkId = 'REGIONS AP', @CompanyID = 1
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '4394639422', @ChekBkId = 'CREDIT LINE', @CompanyID = 1
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0118900666', @ChekBkId = 'REGIONS - A/P', @CompanyID = 4
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0118904971', @ChekBkId = 'REGIONS - DEP', @CompanyID = 4
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '6037658534', @ChekBkId = 'REGIONS - CRLN', @CompanyID = 4
EXEC BNK_Journal_Exception @UpLoadDate = '2012-11-28', @AcctNum = '001700183614775', @ChekBkId = 'FIRST TN', @CompanyID = 5
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0055943314', @ChekBkId = 'AP', @CompanyID = 11
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0055943306', @ChekBkId = 'DEP', @CompanyID = 11
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0034228330', @ChekBkId = 'DRV SVCS', @CompanyID = 11
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '6037455592', @ChekBkId = 'CR LINE', @CompanyID = 11
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0082668027', @ChekBkId = 'AP', @CompanyID = 20
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0082668019', @ChekBkId = 'DEPOSITORY', @CompanyID = 20
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0082668035', @ChekBkId = 'DRIV', @CompanyID = 20
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '6037603084', @ChekBkId = 'CRLINE', @CompanyID = 20
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0096553251', @ChekBkId = 'AP DISB', @CompanyID = 21
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0096553235', @ChekBkId = 'DEPOSIT', @CompanyID = 21
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '6037630897', @ChekBkId = 'CR LINE', @CompanyID = 21
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '0118902936', @ChekBkId = 'DISB', @CompanyID = 24
EXEC BNK_Journal_Exception @UpLoadDate = '2012-09-27', @AcctNum = '6037682278', @ChekBkId = 'CR LINE', @CompanyID = 24
============================================================================================================================
*/
ALTER PROCEDURE dbo.BNK_Journal_Exception
		@UpLoadDate		datetime,
		@AcctNum		Varchar(15),
		@ChekBkId		Varchar(15),
		@CompanyID		int
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @UpDate		Datetime = CAST(CONVERT(Char(10), @UpLoadDate, 101) AS Datetime),
			@CompanyDB	Varchar(5),
			@Query		Varchar(Max)

	SELECT	@CompanyDB = RTRIM(InterId)
	FROM	DYNAMICS.dbo.View_AllCompanies
	WHERE	CmpanyId = @CompanyID

	SET @Query = N'SELECT	BAI.BAI_DetailId, 
			BAI.TrxDate, 
			BAI.AbaNum, 
			BAI.Currency, 
			BAI.AcctNum, 
			BAI.AcctName,
			BAI.FK_Bank_HeaderId, 
			BAI.Description, 
			BAI.BAI_Code, 
			BAI.Amount, 
			BAI.Serial_Num, 
			BAI.Ref_Num,
			BAI.Detail, 
			BAI.UploadDate, 
			BAI.IsRecon, 
			BAI.ReconDate, 
			BAI.Cmpanyid, 
			''' + RTRIM(@ChekBkId) + ''' AS CHEKBKID, 
			''' + @CompanyDB + ''' AS COMPANYNAME 
	FROM	BAI_Detail BAI WITH(NOLOCK) 
	WHERE	BAI.BAI_Code = ''455''
			AND BAI.AcctNum = ''' + RTRIM(@AcctNum) + '''
			AND BAI.UploadDate >= ''' + CONVERT(Char(10), @UpDate, 101) + '''
			AND BAI.Cmpanyid = ' + CAST(@CompanyID AS Varchar) + '
			AND BAI.Amount NOT IN (	SELECT	SUM(TRXAMNT) OVER(PARTITION BY AUDITTRAIL) AS TRXAMNT 
									FROM	' + @CompanyDB + '.dbo.CM20200 
									WHERE	TRXDATE BETWEEN DATEADD(dd, -7, ''' + CONVERT(Char(10), @UpDate, 101) + ''') AND ''' + CONVERT(Char(10), @UpDate, 101) + ''' 
											AND CHEKBKID = ''' + RTRIM(@ChekBkId) + ''')
	UNION ALL
	SELECT	BAI.BAI_DetailId, 
			BAI.TrxDate, 
			BAI.AbaNum, 
			BAI.Currency, 
			BAI.AcctNum, 
			BAI.AcctName,
			BAI.FK_Bank_HeaderId, 
			BAI.Description, 
			BAI.BAI_Code, 
			BAI.Amount, 
			BAI.Serial_Num, 
			BAI.Ref_Num,
			BAI.Detail, 
			BAI.UploadDate, 
			BAI.IsRecon, 
			BAI.ReconDate, 
			BAI.Cmpanyid, 
			''' + RTRIM(@ChekBkId) + ''' AS CHEKBKID, 
			''' + @CompanyDB + ''' AS COMPANYNAME 
	FROM	dbo.BAI_Detail BAI WITH(NOLOCK) 
	WHERE	BAI.BAI_Code = ''475''
			AND BAI.AcctNum = ''' + RTRIM(@AcctNum) + '''
			AND BAI.UploadDate >= ''' + CONVERT(Char(10), @UpDate, 101) + '''
			AND BAI.Cmpanyid = ' + CAST(@CompanyID AS Varchar) + '
			AND BAI.Amount NOT IN (	SELECT	TRXAMNT 
									FROM	' + @CompanyDB + '.dbo.CM20200 
									WHERE	TRXDATE BETWEEN DATEADD(dd, -90, ''' + CONVERT(Char(10), @UpDate, 101) + ''') AND ''' + CONVERT(Char(10), @UpDate, 101) + ''' 
											AND CHEKBKID = ''' + RTRIM(@ChekBkId) + ''')'
    
	--PRINT @Query
	EXECUTE(@Query)
END