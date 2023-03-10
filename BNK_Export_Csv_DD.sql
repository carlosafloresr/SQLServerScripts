USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[BNK_Export_Csv_DD]    Script Date: 8/16/2016 2:49:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
======================================================================================================================
Author:			Percy Brown
Create date:	2012-06-25
Description:	Return transactions from bai_code 455 for export to csv file.
======================================================================================================================
EXECUTE BNK_Export_Csv_DD @CompanyID = 24, @ChekBkId = 'DISB', @StartDate = '2016-08-17', @AcctNum = '0118902936'
EXECUTE BNK_Export_Csv_DD @CompanyID = 1, @ChekBkId = 'DEP', @StartDate = '2016-08-10', @AcctNum = '8000525354'
EXECUTE BNK_Export_Csv_DD @CompanyID = 11, @ChekBkId = 'DRV SVCS', @StartDate = '2016-08-10', @AcctNum = '0034228330'
======================================================================================================================
*/
ALTER PROCEDURE [dbo].[BNK_Export_Csv_DD] 
	@CompanyID	int,
	@ChekBkId	varchar(15),
	@StartDate	datetime,
	@AcctNum	varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @EndDate	Datetime = ISNULL((SELECT MAX(TrxDate) FROM dbo.BAI_Header WITH(NOLOCK) WHERE Cmpanyid = @CompanyID AND AcctNum = @AcctNum), GETDATE()),
			@CompanyDB	Varchar(5),
			@Query		Varchar(Max)

	SELECT	@CompanyDB = RTRIM(InterId)
	FROM	DYNAMICS.dbo.View_AllCompanies
	WHERE	CmpanyId = @CompanyID
	
	SET @Query = N'SELECT	0 AS RecTypeCode,
						''' + RTRIM(@AcctNum) + ''' AS AcctNum,
						RTRIM(paidtorcvdfrom) AS Detail,
						RTRIM(CMTrxNum) AS Serial_Num,
						CONVERT(Varchar(12), TRXDATE, 101) AS TrxDate,
						CONVERT(Numeric(19,2), Checkbook_Amount) AS Amount,
						''CHK'' AS TrxCode
				FROM	' + @CompanyDB + '.dbo.CM20200 WITH(NOLOCK)
				WHERE	VOIDED = 0 
						AND TRXDATE BETWEEN ''' + CONVERT(Char(10), @StartDate, 101) + ''' AND ''' + CONVERT(Char(10), @EndDate, 101) + '''
						AND CHEKBKID = ''' + RTRIM(@ChekBkId) + ''' 
						AND SRCDOCNUM IN (	SELECT	PMNTNMBR 
											FROM	GPCustom.dbo.PM10300 WITH(NOLOCK) 
											WHERE	DOCDATE BETWEEN ''' + CONVERT(Char(10), @StartDate, 101) + ''' AND ''' + CONVERT(Char(10), @EndDate, 101) + ''' 
													AND CHEKBKID = ''' + RTRIM(@ChekBkId) + ''' 
													AND RIGHT(RTRIM(BACHNUMB), 2) = ''DD'')'
	PRINT @Query
	EXECUTE(@Query)

	--IF @CompanyID = 1 --IMC
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM IMC.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 3 --RCMR
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM RCMR.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 4 --FI
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM FI.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 5 --RCCL
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM RCCL.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 11 --AIS
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM AIS.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 13 --IILS
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM IILS.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 20 --NDS
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM NDS.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 21 --GIS
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM GIS.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 22 --IMCC
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM IMCC.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
	--IF @CompanyID = 24 --DNJ
	--	BEGIN
	--		SELECT 0 AS RecTypeCode
	--		, @AcctNum AS AcctNum
	--		, RTRIM(paidtorcvdfrom) AS Detail
	--		, RTRIM(CMTrxNum) AS Serial_Num
	--		, CONVERT(varchar(12), TRXDATE, 101) AS TrxDate
	--		, CONVERT(numeric(19,2), Checkbook_Amount) AS Amount
	--		, 'CHK' AS TrxCode
	--		FROM DNJ.dbo.CM20200 WITH(NOLOCK)
	--		 WHERE VOIDED= 0 AND TRXDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId 
	--		 AND SRCDOCNUM IN(SELECT PMNTNMBR FROM GPCustom.dbo.PM10300 WITH(NOLOCK) 
	--		 WHERE DOCDATE BETWEEN @StartDate AND @EndDate AND CHEKBKID = @ChekBkId AND RIGHT(RTRIM(BACHNUMB),2)='DD')
	--	 END
END