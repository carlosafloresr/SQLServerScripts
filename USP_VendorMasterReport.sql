USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorMasterReport]    Script Date: 2/17/2016 1:19:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorMasterReport 'IMC', 'A', 1, NULL, 1, NULL, '02/17/2016', Null, 'CFLORES'
EXECUTE USP_VendorMasterReport 'AIS', 'A', 1, NULL, 1, NULL, '02/17/2016', Null, 'CFLORES'
*/
ALTER PROCEDURE [dbo].[USP_VendorMasterReport]
	@Company		Varchar(6),
	@Status			Char(1) = Null,
	@WithBalance	Bit = 0,
	@NoReleaseDate	Bit = Null,
	@ShowAccounts	Bit = 0,
	@VendorId		Varchar(10) = Null,
	@EndDate		Datetime = Null,
	@Types			Varchar(200) = Null,
	@UserId			Varchar(25) = Null
AS
IF @VendorId IS NOT Null
BEGIN
	SET	@Status			= Null
	SET @WithBalance	= Null
	SET	@NoReleaseDate	= Null
	SET	@ShowAccounts	= 1
END

IF @WithBalance IS Null
	SET @WithBalance = 0

IF @Types = ''
	SET @Types = Null

DECLARE	@CutoffDate	Datetime,
		@Query		Varchar(MAX)

IF @EndDate IS Null
	SET @CutoffDate = CAST(CONVERT(Char(10), GETDATE(), 101) AS Datetime)
ELSE
	SET @CutoffDate = @EndDate

SET @Query = N'SELECT VM.VendorId,
		REPLACE(LEFT(dbo.PROPER(ISNULL(PM.VendName, ''*** NOT IN GREAT PLAINS ***'')), 60), ''#'' + RTRIM(VM.VendorId), '''')  AS VendorName,
		VM.Company,
		VM.HireDate,
		VM.TerminationDate,
		VM.ScheduledReleaseDate,
		VM.SubType,
		CASE WHEN VM.SubType = 1 THEN ''Regular'' ELSE ''My Truck'' END Sub_Type,
		VM.ApplyRate,
		VM.Rate,
		VM.ApplyAmount,
		VM.Amount,
		ISNULL(EB.EscrowBalance, 0.0) AS EscrowBalance,
		ES.AccountNumber,
		CASE WHEN ES.Account IS Null OR ES.Account = '''' THEN ''No Description'' ELSE ES.Account END AS Account,
		ES.EscrowAcctBalance,
		VM.ModifiedBy,
		VM.ModifiedOn,
		CO.CompanyName,
		ISNULL(BA.Balance, 0.0) AS AP_Balance,
		ES.Fk_EscrowModuleId AS EscrowModuleId,
		''' + CONVERT(Char(10), @CutoffDate, 101) + ''' AS CutoffDate,
		VM.Agent,''' + @UserId + ''' AS UserId
FROM	VendorMaster VM
		INNER JOIN Companies CO ON VM.Company = CO.CompanyId
		INNER JOIN ' + RTRIM(@Company) + '.dbo.PM00200 PM ON VM.VendorId = PM.VendorId
		LEFT JOIN (
				SELECT	ET.VendorId,
						SUM(ET.Amount) AS EscrowBalance
				FROM	View_EscrowTransactions ET
				WHERE	ET.CompanyId = ''' + RTRIM(@Company) + '''
						AND ET.PostingDate IS NOT Null
						AND ET.PostingDate <= ''' + CONVERT(Char(10), @CutoffDate, 101) + ''''
				IF @Types IS NOT Null
						SET @Query = @Query + N'AND dbo.AT(ET.Fk_EscrowModuleId, ''' + RTRIM(@Types) + ''', 1) > 0)) '

				SET @Query = @Query + N'GROUP BY
						ET.VendorId
				  ) EB ON VM.VendorId = EB.VendorId
		LEFT JOIN (
				SELECT	ET.CompanyId,
						ET.VendorId,
						ET.AccountNumber,
						ET.Fk_EscrowModuleId,
						ISNULL(ET.AccountAlias, GL.ActDescr) AS Account,
						SUM(ET.Amount) AS EscrowAcctBalance
				FROM	View_EscrowTransactions ET
						INNER JOIN ' + RTRIM(@Company) + '.dbo.GL00100 GL ON ET.AccountIndex = GL.ActIndx
				WHERE	ET.CompanyId = ''' + RTRIM(@Company) + '''
						AND ET.PostingDate IS NOT Null
						AND ET.PostingDate <= ''' + CONVERT(Char(10), @CutoffDate, 101) + ''''

				IF @Types IS NOT Null
					SET @Query = @Query + N'AND dbo.AT(ET.Fk_EscrowModuleId, ''' + RTRIM(@Types) + ''', 1) > 0)) '

				SET @Query = @Query + N'GROUP BY
						ET.CompanyId,
						ET.VendorId,
						ET.AccountNumber,
						ISNULL(ET.AccountAlias, GL.ActDescr),
						ET.Fk_EscrowModuleId
				  ) ES ON VM.VendorId = ES.VendorId
		LEFT JOIN (
					SELECT	VendorId,
							SUM(CASE WHEN DocType = 5 THEN -1 ELSE 1 END * CurTrxAm) AS Balance
					FROM	' + RTRIM(@Company) + '.dbo.PM20000
					WHERE	PosteDDT <= ''' + CONVERT(Char(10), @CutoffDate, 101) + '''
					GROUP BY Vendorid
				  ) BA ON ES.VendorId = BA.VendorId
WHERE	VM.Company = ''' + RTRIM(@Company) + '''
		AND ES.Fk_EscrowModuleId NOT IN (5,6,9,10) '

	IF @Status IS NOT Null
	BEGIN
		IF @Status = 'A'
			SET @Query = @Query + N'AND VM.TerminationDate IS Null '
		ELSE
			SET @Query = @Query + N'AND VM.TerminationDate IS NOT Null '
	END

	IF @WithBalance = 1
		SET @Query = @Query + N'AND ISNULL(ES.EscrowAcctBalance, 0.0) <> 0 '

	IF @NoReleaseDate IS NOT Null
	BEGIN
		IF @NoReleaseDate = 1
			SET @Query = @Query + N'AND VM.ScheduledReleaseDate IS NOT Null '
		ELSE
			SET @Query = @Query + N'AND ScheduledReleaseDate IS Null '
	END

	IF @VendorId IS NOT Null
		SET @Query = @Query + N'AND VM.VendorId = ''' + RTRIM(@VendorId) + ''' '

SET @Query = @Query + N'ORDER BY VM.VendorId'

EXECUTE(@Query)
