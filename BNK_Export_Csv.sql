USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[BNK_Export_Csv]    Script Date: 8/29/2016 8:43:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=================================================================================
Author:			Percy Brown
Create date:	2012-06-18
Description:	Return data from *.BAI2 file for export to csv file.
=================================================================================
EXECUTE BNK_Export_Csv @CompanyID = 1
EXECUTE BNK_Export_Csv @CompanyID = 11
=================================================================================
*/
ALTER PROCEDURE [dbo].[BNK_Export_Csv] 
	@CompanyID Int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	0 AS RecTypeCode
			,RTRIM(AcctNum) AS AcctNum
			,RTRIM(Detail) AS Detail
			,RTRIM(Serial_Num) AS Serial_Num
			,CONVERT(varchar(12), TrxDate, 101) AS TrxDate
			,CONVERT(numeric(19,2), Amount) AS Amount
			,CASE BAI_Code
				WHEN '142' THEN 'DEP' --ACH Credit Received
				WHEN '145' THEN 'DEP' --ACH CONCENTRATION CREDIT
				WHEN '164' THEN 'DEP' --CORPORATE TRADE PAYMENT CREDIT
				WHEN '165' THEN 'DEP' --ACH CREDIT/ACH DEPOSIT
				WHEN '171' THEN 'DEP' --ADVANCE FROM CREDIT LINE
				WHEN '174' THEN 'DEP' --Deposit
				WHEN '175' THEN 'DEP' --DEPOSIT
				WHEN '195' THEN 'DEP' --WIRE TRANSFER CREDIT
				WHEN '275' THEN 'DEP' --ZBA TRANSFER CREDIT
				WHEN '445' THEN 'CHK' --ACH CONCENTRATION DEBIT
				WHEN '455' THEN 'CHK' --ACH DEBIT
				WHEN '475' THEN 'CHK' --CHECK
				WHEN '481' THEN 'CHK' --PAYMENT TO CREDIT LINE
				WHEN '575' THEN 'CHK' --ZBA Debit
				WHEN '577' THEN 'CHK' --ZBA TRANSFER DEBIT
				ELSE 'UNK' END AS TrxCode
	FROM	dbo.BAI_Detail WITH(NOLOCK)
	WHERE	Cmpanyid = @CompanyID
END

