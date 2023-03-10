USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CalculateSafetyBonus_Integration]    Script Date: 9/29/2022 10:54:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CalculateSafetyBonus_Integration 'AIS', '9/24/2022', '9/29/2022'

SELECT * FROM SafetyBonus WHERE VendorId = 'G0298'
*/
ALTER PROCEDURE [dbo].[USP_CalculateSafetyBonus_Integration]
		@Company	Varchar(5),
		@IniDate	Datetime = Null,
		@EndDate	Datetime = Null
AS
SET NOCOUNT ON

DECLARE	@CompNum			Int,
		@Query				Varchar(MAX),
		@GPDate				Date,
		@CalculateBasedOn	Char(1)

SET		@Company = UPPER(@Company)

DECLARE @tmpDriverBonusTable TABLE
(
		SafetyBonusId		int NOT NULL,
		Company				varchar(5) NOT NULL,
		VendorId			varchar(10) NULL,
		OldDriverId			varchar(10) NULL,
		VendorName			varchar(50) NULL,
		HireDate			datetime NULL,
		Period				char(6) NULL,
		PayDate				date NULL,
		BonusPayDate		datetime NULL,
		Miles				int NULL,
		ToPay				numeric(38, 2) NULL,
		PeriodMiles			int NULL,
		PeriodPay			numeric(18, 2) NULL,
		PeriodToPay			numeric(18, 2) NULL,
		SortColumn			int NOT NULL,
		WeeksCounter		int NULL,
		Paid				bit NOT NULL,
		LastRunWeek			datetime NULL,
		Percentage			decimal(10, 2) NOT NULL,
		Drayage				decimal(12, 2) NOT NULL,
		DrayageBonus		decimal(10, 2) NOT NULL,
		Division			varchar(4) NULL,
		BonusType			char(1) NULL,
		BonusUnits			decimal(12, 2) NULL,
		BonusAmount			numeric(18, 2) NULL,
		TerminationDate		datetime NULL,
		EmptyColumn			char(10)
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

	SET		@Query = 'SELECT Code, Cmpy_No, Div_Code, TermDt FROM trk.driver WHERE Cmpy_No = ''' + CAST(@CompNum AS Varchar(2)) + ''' AND Type <> ''C'''

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
	SELECT	SAF.SafetyBonusId,
			SAF.Company,
			RTRIM(VMA.VendorId) AS VendorId,
			VMA.OldDriverId,
			RTRIM(VMA.VendorId) + ' - ' + SAF.VendorName AS VendorName,
			SAF.HireDate,
			SAF.Period,
			CAST(SAF.PayDate AS Date) AS PayDate,
			SAF.BonusPayDate,
			SAF.Miles,
			SAF.ToPay,
			SAF.PeriodMiles,
			SAF.PeriodPay,
			SAF.PeriodToPay,
			SAF.SortColumn,
			SAF.WeeksCounter,
			SAF.Paid,
			SAF.LastRunWeek,
			SAF.Percentage,
			SAF.Drayage,
			SAF.DrayageBonus,
			ISNULL(VMA.Division, SWS.Div_Code) AS Division,
			@CalculateBasedOn AS BonusType,
			CASE WHEN @CalculateBasedOn = 'M' THEN SAF.PeriodMiles ELSE SAF.Drayage END AS BonusUnits,
			CASE WHEN @CalculateBasedOn = 'M' THEN SAF.PeriodPay ELSE SAF.DrayageBonus END AS BonusAmount,
			VMA.TerminationDate,
			'__________' AS EmptyColumn
	FROM	SafetyBonus SAF
			INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.VendorId
			LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
	WHERE	SAF.Company = @Company
			AND SAF.SortColumn = 1
			AND (SAF.PayDate BETWEEN @IniDate AND @EndDate)
			AND SAF.PeriodToPay > 0
	ORDER BY
			3
			,SAF.Period
			,SAF.BonusPayDate DESC
			,SAF.SortColumn
			,SAF.PayDate DESC

	DROP TABLE ##tmpCurSWSDrivers
	DROP TABLE #TempVendorMaster
	
	SELECT	*,
			DriverCounter = (SELECT COUNT(*) FROM @tmpDriverBonusTable T2 WHERE T1.VendorId = T2.VendorId)
	FROM	@tmpDriverBonusTable T1
	ORDER BY
			BonusPayDate 
			,VendorId
			,Period
			,SortColumn
			,PayDate DESC
END
