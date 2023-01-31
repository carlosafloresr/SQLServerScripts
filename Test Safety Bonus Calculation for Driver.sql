DECLARE	@Company			Varchar(5) = 'DNJ',
		@IniDate			Datetime = '12/01/2021',
		@EndDate			Datetime = '12/03/2021',
		@CreditAccount		Varchar(20),
		@DebitAccount		Varchar(20),
		@BatchId			Varchar(20) = 'test'

DECLARE	@CompNum			Int,
		@Query				Varchar(MAX),
		@GPDate				Date,
		@CalculateBasedOn	Char(1)

SET		@Company = UPPER(@Company)

DECLARE @tmpDriverBonusTable TABLE
(
		Company				varchar(5) NOT NULL,
		VendorId			varchar(10) NULL,
		PayDate				date NULL,
		Division			varchar(4) NULL,
		BonusAmount			numeric(18, 2) NULL
) 

SELECT	@DebitAccount = VarC
	FROM	Parameters
	WHERE	ParameterCode = 'SAFETYBONUSINT_DEBIT'

	SELECT	@CreditAccount = VarC
	FROM	Parameters
	WHERE	ParameterCode = 'SAFETYBONUSINT_CREDIT'

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

	SET		@Query = 'SELECT Code, Cmpy_No, Div_Code, TermDt FROM trk.driver WHERE Cmpy_No = ''' + CAST(@CompNum AS Varchar(2)) + ''' AND Type = ''O'''

	EXECUTE USP_QuerySWS_ReportData @Query, '##tmpCurSWSDrivers'

	SELECT	VendorId,
			OldDriverId,
			Division,
			TerminationDate
	INTO	#TempVendorMaster
	FROM	VendorMaster
	WHERE	Company = @Company
			AND TerminationDate IS Null

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
			AND (SAF.Company <> 'AIS'
			OR (SAF.Company = 'AIS' AND ISNULL(VMA.Division, SWS.Div_Code) <> '199'))
	ORDER BY
			VendorId
			,SAF.Period
			,SAF.BonusPayDate DESC
			,SAF.SortColumn
			,SAF.PayDate DESC

	DROP TABLE ##tmpCurSWSDrivers
	DROP TABLE #TempVendorMaster

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
		ORDER BY
				2,4
END
/*
EXECUTE USP_CalculateSafetyBonus 'dnj', '1/1/2011', '3/31/2011'
EXECUTE USP_CalculateSafetyBonusTable 'GIS', '10/3/2011'
*/