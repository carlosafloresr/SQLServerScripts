USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorMasterTabularReport]    Script Date: 2/24/2016 11:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorMasterTabularReport 'IMC', Null, 1, NULL, 1, NULL, '02/24/2016', Null, 'CFLORES'
*/
ALTER PROCEDURE [dbo].[USP_VendorMasterTabularReport]
	@Company		Char(6),
	@Status			Char(1) = Null,
	@WithBalance	Bit = 0,
	@NoReleaseDate	Bit = Null,
	@ShowAccounts	Bit = 0,
	@VendorId		Char(10) = Null,
	@EndDate		Datetime = Null,
	@Types			Varchar(200) = Null,
	@UserId			Varchar(25) = Null
AS
DECLARE @tmpDriverMasterEscrowBalance TABLE
	(VendorId				Varchar(12) NOT NULL,
	VendorName				Varchar(100) NULL,
	Company					Varchar(6) NOT NULL,
	HireDate				Datetime NULL,
	TerminationDate			Datetime NULL,
	ScheduledReleaseDate	Datetime NULL,
	SubType					Int NOT NULL,
	Sub_Type				Varchar(8) NOT NULL,
	ApplyRate				Bit NOT NULL,
	Rate					Smallmoney NOT NULL,
	ApplyAmount				Bit NOT NULL,
	Amount					Smallmoney NOT NULL,
	EscrowBalance			Money NOT NULL,
	AccountNumber			Varchar(15) NULL,
	Account					Varchar(100) NULL,
	EscrowAcctBalance		Money NULL,
	ModifiedBy				Varchar(25) NOT NULL,
	ModifiedOn				Datetime NOT NULL,
	CompanyName				Varchar(65) NULL,
	AP_Balance				Numeric(38, 5) NOT NULL,
	EscrowModuleId			Int NULL,
	CutoffDate				Datetime NULL,
	Agent					Varchar(3),
	UserId					Varchar(25) NULL,
	RowNumber				Int NULL)


INSERT INTO @tmpDriverMasterEscrowBalance
EXECUTE USP_VendorMasterReport @Company, @Status, @WithBalance, @NoReleaseDate, @ShowAccounts, @VendorId, @EndDate, @Types, @UserId

SELECT	VendorId, 
		VendorName, 
		TerminationDate, 
		RTRIM(AccountNumber) + ' ' + RTRIM(REPLACE(Account, '&', 'and')) AS AccountNumber, 
		EscrowAcctBalance
INTO	##tmpDriverData 
FROM	@tmpDriverMasterEscrowBalance
UNION
SELECT	VendorId, 
		VendorName, 
		TerminationDate, 
		'AP Balance' AS AccountNumber, 
		AVG(AP_Balance) AS EscrowAcctBalance
FROM	@tmpDriverMasterEscrowBalance
GROUP BY
		VendorId, 
		VendorName, 
		TerminationDate

DECLARE @PivotColumnHeaders		Varchar(MAX),
		@Query					Varchar(MAX),
		@Columns				Varchar(MAX)

SELECT DISTINCT AccountNumber INTO #tmpAccounts FROM ##tmpDriverData

SELECT @PivotColumnHeaders = COALESCE(@PivotColumnHeaders + ',[' + RTRIM(AccountNumber) + ']', + '[' + RTRIM(AccountNumber) + ']') FROM #tmpAccounts
SET @Columns = SUBSTRING((SELECT DISTINCT ',ISNULL([' + AccountNumber +'],0) AS [' + AccountNumber + ']' FROM #tmpAccounts GROUP BY AccountNumber FOR XML PATH('')),2,8000)

DROP TABLE #tmpAccounts

SET @Query = N'SELECT VendorId, RTRIM(VendorName) AS VendorName, ISNULL(CONVERT(Char(10), TerminationDate, 101), '''') AS TerminationDate, ' + @Columns + ' FROM (SELECT VendorId, VendorName, TerminationDate, AccountNumber, EscrowAcctBalance FROM ##tmpDriverData) AS PivotDate PIVOT (SUM(EscrowAcctBalance) FOR AccountNumber IN (' + @PivotColumnHeaders + ')) AS PivotTable'

EXECUTE(@Query)

DROP TABLE ##tmpDriverData

-- TRUNCATE TABLE GPCustom.dbo.tmpDriverMasterEscrowBalance