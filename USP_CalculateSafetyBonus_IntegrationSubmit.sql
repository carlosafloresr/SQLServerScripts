USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CalculateSafetyBonus_IntegrationSubmit]    Script Date: 10/10/2022 1:39:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CalculateSafetyBonus_IntegrationSubmit 'GIS', '5/17/2018', '5/17/2018', '5/18/2018', 'CFLORES'
EXECUTE USP_CalculateSafetyBonus_IntegrationSubmit 'AIS', '10/06/2022', '10/06/2022', '10/06/2022', 'CFLORES', 1
*/
ALTER PROCEDURE [dbo].[USP_CalculateSafetyBonus_IntegrationSubmit]
		@Company		Varchar(5),
		@IniDate		Datetime,
		@EndDate		Datetime,
		@PostingDate	Date,
		@UserId			Varchar(25),
		@JustSelect		Bit = 0
AS
SET NOCOUNT ON

DECLARE	@CompNum			Int,
		@Query				Varchar(MAX),
		@GPDate				Date,
		@CalculateBasedOn	Char(1),
		@CreditAccount		Varchar(20),
		@DebitAccount		Varchar(20),
		@BatchId			Varchar(20),
		@VendorId			Varchar(15),
		@Division			Char(2),
		@AccountNumber		Varchar(20),
		@Debit				Numeric(10,2),
		@Credit				Numeric(10,2),
		@Description		Varchar(30),
		@Records			Int,
		@DocNumber			Varchar(25),
		@BatchDate			Varchar(15)

SET		@Company = UPPER(@Company)

DECLARE @tmpDriverBonusTable TABLE
(
		Company				varchar(5) NOT NULL,
		VendorId			varchar(10) NULL,
		PayDate				date NULL,
		Division			varchar(4) NULL,
		BonusAmount			numeric(18, 2) NULL
) 

IF EXISTS(SELECT Company FROM SafetyBonusParameters WHERE Company = @Company)
BEGIN
	SELECT	@GPDate				= GrandfatherDate,
			@CalculateBasedOn	= CalculateBasedOn
	FROM	SafetyBonusParameters
	WHERE	Company = @Company

	IF @GPDate IS Null
		SET @GPDate = '01/01/2012'

	SELECT	@CompNum = CompanyNumber 
	FROM	Companies 
	WHERE	CompanyId = @Company

	IF EXISTS (SELECT Name FROM tempdb.SYS.tables WHERE Name = '##tmpCurSWSDrivers')
		DROP TABLE ##tmpCurSWSDrivers

	SET	@Query = 'SELECT Code, Cmpy_No, Div_Code, TermDt FROM trk.driver WHERE Cmpy_No = ''' + CAST(@CompNum AS Varchar(2)) + ''' AND Type <> ''C'''

	EXECUTE USP_QuerySWS_ReportData @Query, '##tmpCurSWSDrivers'
	
	SELECT	VendorId,
			OldDriverId,
			Division,
			TerminationDate
	INTO	#TempVendorMaster
	FROM	VendorMaster
	WHERE	Company = @Company
			AND TerminationDate IS Null
			AND VENDORID not IN ('A0267',
'A0681',
'A0699',
'A0768',
'A0979',
'A1264',
'A1375',
'A1391',
'A1467',
'A1593',
'A1717',
'A1736',
'A50124',
'A50211',
'A50240',
'A50525',
'A50538',
'A50598',
'A50626',
'A50680',
'A50779',
'A50780',
'A50789',
'A50946',
'A50948',
'A50954',
'A50965',
'A50994',
'A51075',
'A51090',
'A51093',
'A51129',
'A51158',
'A51193',
'A51194',
'A51196',
'A51200',
'A51202',
'A51213',
'A51230',
'A51258',
'A51298',
'A51300',
'A51335',
'A51336',
'A51382',
'A51457',
'A51479',
'A51482',
'A51493',
'A51511',
'A51538',
'A51560',
'A51617',
'A51639',
'A51662',
'A51693',
'A51699',
'A51702',
'A51761',
'A51866',
'A51899',
'A51913',
'A51978',
'A51981',
'A51991',
'A52017',
'A52049',
'A52075',
'A52085',
'A52093',
'A52095',
'A52110',
'A52133',
'A52136',
'A52137',
'A52176',
'A52183',
'A52199',
'A52202',
'A52216',
'A52222',
'A52223',
'A52226',
'A52230',
'A52240',
'A52251',
'A52252',
'A52254',
'A52257',
'A52284',
'A52289',
'A52296',
'A52301',
'A52303',
'A52305',
'A52308',
'A52311',
'A52316',
'A52317',
'A52324',
'A52331')

	SELECT	@DebitAccount = VarC
	FROM	Parameters
	WHERE	ParameterCode = 'SAFETYBONUSINT_DEBIT'

	SELECT	@CreditAccount = VarC
	FROM	Parameters
	WHERE	ParameterCode = 'SAFETYBONUSINT_CREDIT'

	IF @JustSelect = 0
	BEGIN
		INSERT INTO @tmpDriverBonusTable
		SELECT	SAF.Company,
				RTRIM(VMA.VendorId) AS VendorId,
				CAST(SAF.PayDate AS Date) AS PayDate,
				COALESCE(RDM.Division_Replace, VMA.Division, SWS.Div_Code) AS Division,
				CASE WHEN @CalculateBasedOn = 'M' THEN SAF.PeriodPay ELSE SAF.DrayageBonus END AS BonusAmount
		FROM	SafetyBonus SAF
				INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.VendorId
				LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
				LEFT JOIN RSA_Divisions_Mapping RDM ON SAF.Company = RDM.Company AND ISNULL(VMA.Division, SWS.Div_Code) = RDM.Division_Original AND RDM.MappingType = 'PDM'
		WHERE	SAF.Company = @Company
				AND SAF.SortColumn = 1
				AND (SAF.PayDate BETWEEN @IniDate AND @EndDate)
				AND SAF.PeriodToPay > 0
				--AND (SAF.Company <> 'AIS'
				--OR (SAF.Company = 'AIS' AND ISNULL(VMA.Division, SWS.Div_Code) <> '199'))
		ORDER BY
				3
				,SAF.Period
				,SAF.BonusPayDate DESC
				,SAF.SortColumn
				,SAF.PayDate DESC

		SET @Records = @@ROWCOUNT
	
		PRINT 'Records: ' + CAST(@@ROWCOUNT AS Varchar)
	END
	ELSE
	BEGIN
		SELECT	SAF.Company,
				RTRIM(VMA.VendorId) AS VendorId,
				CAST(SAF.PayDate AS Date) AS PayDate,
				COALESCE(RDM.Division_Replace, VMA.Division, SWS.Div_Code) AS Division,
				CASE WHEN @CalculateBasedOn = 'M' THEN SAF.PeriodPay ELSE SAF.DrayageBonus END AS BonusAmount,
				ISNULL(VMA.Division, SWS.Div_Code) AS Division
		FROM	SafetyBonus SAF
				INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.VendorId
				LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
				LEFT JOIN RSA_Divisions_Mapping RDM ON SAF.Company = RDM.Company AND ISNULL(VMA.Division, SWS.Div_Code) = RDM.Division_Original AND RDM.MappingType = 'PDM'
		WHERE	SAF.Company = @Company
				AND SAF.SortColumn = 1
				AND (SAF.PayDate BETWEEN @IniDate AND @EndDate)
				AND SAF.PeriodToPay > 0
				--AND (SAF.Company <> 'AIS'
				--OR (SAF.Company = 'AIS' AND ISNULL(VMA.Division, SWS.Div_Code) <> '199'))
		ORDER BY
				2,3
				,SAF.Period
				,SAF.BonusPayDate DESC
				,SAF.SortColumn
				,SAF.PayDate DESC

		SET @Records = 0
	END

	DROP TABLE ##tmpCurSWSDrivers
	DROP TABLE #TempVendorMaster
	
	IF @Records > 0
	BEGIN
		SET @BatchDate = CAST(YEAR(@PostingDate) AS Varchar) + dbo.PADL(MONTH(@PostingDate), 2, '0') + dbo.PADL(DAY(@PostingDate), 2, '0')
		SET @BatchId = 'SBA_' + @BatchDate

		PRINT 'Batch Number: ' + @BatchId

		DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	*
		FROM	(
				SELECT	Company,
						Null AS VendorId,
						Division,
						REPLACE(@DebitAccount, 'DD', RTRIM(Division)) AS AccountNumber,
						SUM(BonusAmount) AS Debit,
						0 AS Credit,
						'Safety Bonus Accrual Div ' + RTRIM(Division) AS Description,
						@BatchId AS DocNumber
				FROM	@tmpDriverBonusTable T1
				GROUP BY
						Company,
						Division
				UNION
				SELECT	Company,
						VendorId,
						Division,
						@CreditAccount AS AccountNumber,
						0 AS Debit,
						SUM(BonusAmount) AS Credit,
						'Safety Bonus Accrual Drv ' + RTRIM(VendorId) AS Description,
						@BatchId -- RTRIM(VendorId) + '_' + @BatchDate AS DocNumber
				FROM	@tmpDriverBonusTable T1
				GROUP BY
						Company,
						VendorId,
						Division
				) DATA
		ORDER BY
				3, 2

		DELETE IntegrationsDB.Integrations.dbo.Integrations_GL WHERE BatchId = @BatchId AND Company = @Company
		DELETE IntegrationsDB.Integrations.dbo.ReceivedIntegrations WHERE BatchId = @BatchId AND Company = @Company

		OPEN curTransactions 
		FETCH FROM curTransactions INTO @Company, @VendorId, @Division, @AccountNumber, @Debit, @Credit, @Description, @DocNumber

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL	'SBA', 
																	@Company, 
																	@BatchId, 
																	@PostingDate, 
																	'Monthly Driver Bonus Accrual', 
																	@PostingDate, 
																	2, 
																	@UserId,
																	@AccountNumber,
																	@Credit,
																	@Debit,
																	@Description,
																	@VendorId,
																	Null,
																	@DocNumber,
																	@Division
		
			FETCH FROM curTransactions INTO @Company, @VendorId, @Division, @AccountNumber, @Debit, @Credit, @Description, @DocNumber
		END

		CLOSE curTransactions
		DEALLOCATE curTransactions

		EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations 'SBA', @Company, @BatchId
	END
END
/*
EXECUTE USP_CalculateSafetyBonus 'dnj', '1/1/2011', '3/31/2011'
EXECUTE USP_CalculateSafetyBonusTable 'GIS', '10/3/2011'
*/