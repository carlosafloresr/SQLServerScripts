USE GPCustom
GO
/****** Object:  StoredProcedure [dbo].[USP_SalesStatement_w_SWSData]    Script Date: 10/19/2022 9:40:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE USP_IntercompanyReport_DataExtraction
		@Period		Int,
		@Company1	Varchar(5),
		@Company2	Varchar(5)
AS
/*
====================================================================================================================
Author:			Carlos A. Flores
Create Date:	12/07/2022
Change:			Extracion of intercompany transactions under a selected fiscal period
====================================================================================================================
EXECUTE USP_IntercompanyReport_DataExtraction 11, 'AIS', 'IMC'
EXECUTE USP_IntercompanyReport_DataExtraction 11, 'DNJ', 'OIS'
EXECUTE USP_IntercompanyReport_DataExtraction 11, 'DNJ', 'OIS'
====================================================================================================================
*/
SET NOCOUNT ON

DECLARE	@Query		Varchar(MAX)

DECLARE	@tblIntData	Table (
		Company		Varchar(5), 
		TrxDate		Varchar(10),
		Account		Varchar(15), 
		Journal		Varchar(12), 
		Reference	Varchar(50), 
		Debit		Numeric(10,2), 
		Credit		Numeric(10,2), 
		FiscalMonth	Int,
		Summary		Int)

SET @Query = N'SELECT ''' + @Company1 + ''' AS Company, CONVERT(Char(10), TRXDATE, 101), RTRIM(G5.ACTNUMST) AS ACCOUNT, JRNENTRY, UPPER(RTRIM(REFRENCE)), DEBITAMT, CRDTAMNT, PERIODID AS Month, 0 AS Summary
FROM	' + @Company1 + '..GL20000 G2
		INNER JOIN ' + @Company1 + '..GL00105 G5 ON G2.ACTINDX = G5.ACTINDX AND G5.ACTNUMST IN (SELECT Account FROM IntercompanyReport_Accounts WHERE Company = ''' + @Company1 + ''' AND Intercompany = ''' + @Company2 + ''' AND Inactive = 0)
WHERE	PERIODID = ' + CAST(@Period AS Varchar)

INSERT INTO @tblIntData
EXECUTE(@Query)

SET @Query = N'SELECT ''' + @Company2 + ''' AS Company, CONVERT(Char(10), TRXDATE, 101), RTRIM(G5.ACTNUMST) AS ACCOUNT, JRNENTRY, UPPER(RTRIM(REFRENCE)), DEBITAMT, CRDTAMNT, PERIODID AS Month, 0 AS Summary
FROM	' + @Company2 + '..GL20000 G2
		INNER JOIN ' + @Company2 + '..GL00105 G5 ON G2.ACTINDX = G5.ACTINDX AND G5.ACTNUMST IN (SELECT Account FROM IntercompanyReport_Accounts WHERE Company = ''' + @Company2 + ''' AND Intercompany = ''' + @Company1 + ''' AND Inactive = 0)
WHERE	PERIODID = ' + CAST(@Period AS Varchar)

INSERT INTO @tblIntData
EXECUTE(@Query)

INSERT INTO @tblIntData
SELECT	Company,
		'' AS TrxDate,
		Account,
		'' AS Journal,
		Account + ' - Total' AS Reference,
		SUM(Debit) AS Debit,
		SUM(Credit) AS Credit,
		FiscalMonth,
		2 AS Summary
FROM	@tblIntData
GROUP BY Company, Account, FiscalMonth

INSERT INTO @tblIntData
SELECT	Company,
		'' AS TrxDate,
		'' AS Account,
		'' AS Journal,
		'COMPANY TOTAL' AS Reference,
		SUM(Debit) AS Debit,
		SUM(Credit) AS Credit,
		FiscalMonth,
		1 AS Summary
FROM	@tblIntData
GROUP BY Company, FiscalMonth

INSERT INTO @tblIntData
SELECT	'ZZZZZ' AS Company,
		'' AS TrxDate,
		'' AS Account,
		'' AS Journal,
		'S U M M A R Y' AS Reference,
		SUM(Debit) AS Debit,
		SUM(Credit) AS Credit,
		FiscalMonth,
		3 AS Summary
FROM	@tblIntData
WHERE	Summary = 0
GROUP BY FiscalMonth

SELECT	Company,
		TrxDate,
		Account,
		Journal,
		IIF(Summary IN (1,2), Company + ' - ' + Reference, Reference) AS Reference,
		Debit,
		Credit,
		FiscalMonth,
		Summary,
		IIF(Summary IN (1,3), Credit - Debit, 0) AS Difference
FROM	@tblIntData
ORDER BY Company, Summary, TrxDate, Journal