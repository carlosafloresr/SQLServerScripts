USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CalculateSafetyBonus]    Script Date: 12/30/2021 9:22:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CalculateSafetyBonus 'AIS', '1/1/2019', '8/8/2019', 'A50928', 0
EXECUTE USP_CalculateSafetyBonus 'DNJ', '4/10/2020', '4/16/2020', 'D50985', 0
EXECUTE USP_CalculateSafetyBonus 'GIS', '1/29/2019', '12/05/2019', 'G50489', 0
EXECUTE USP_CalculateSafetyBonus 'HMIS', '12/01/2021', '01/30/2022', 'H50170', 0
PRINT  dbo.GetDriverName('DNJ','D50985','O')
SELECT * FROM SafetyBonus WHERE VendorId = 'G0298'
*/
ALTER PROCEDURE [dbo].[USP_CalculateSafetyBonus]
		@Company	Varchar(5),
		@IniDate	Datetime = Null,
		@EndDate	Datetime = Null,
		@VendorId	Varchar(10) =  Null,
		@Summary	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@CompNum			Int,
		@Query				Varchar(MAX),
		@GPDate				Date,
		@CalculateBasedOn	Char(1),
		@AffectGoodStanding	Bit

IF @VendorId = ''
	SET @VendorId = Null

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
		PayDate				datetime NULL,
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
		TerminationDate		datetime NULL
) 
PRINT @IniDate
PRINT @EndDate
IF EXISTS(SELECT Company FROM SafetyBonusParameters WHERE Company = @Company)
BEGIN
	SELECT	@GPDate				= GrandfatherDate,
			@CalculateBasedOn	= CalculateBasedOn,
			@AffectGoodStanding	= AffectsGoodStanding
	FROM	SafetyBonusParameters
	WHERE	Company = @Company

	IF @GPDate IS Null
		SET @GPDate = '01/01/2012'

	SELECT	@CompNum = CompanyNumber 
	FROM	Companies 
	WHERE	CompanyId = @Company

	IF EXISTS (SELECT Name FROM tempdb.SYS.tables WHERE Name = '##tmpCurSWSDrivers')
		DROP TABLE ##tmpCurSWSDrivers

	SET		@Query = 'SELECT DISTINCT Code, Cmpy_No, Div_Code, TermDt FROM trk.driver WHERE Cmpy_No = ''' + CAST(@CompNum AS Varchar(2)) + ''' AND Type = ''O'''

	EXECUTE USP_QuerySWS_ReportData @Query, '##tmpCurSWSDrivers'

	SELECT	DISTINCT VendorId,
			OldDriverId,
			Division,
			TerminationDate
	INTO	#TempVendorMaster
	FROM	VendorMaster
	WHERE	Company = @Company
			AND TerminationDate IS Null
			AND (@VendorId IS Null
			OR VendorId = @VendorId)
			AND (@AffectGoodStanding = 0
			OR (@AffectGoodStanding = 1 AND InGoodStanding = 1))

	IF @IniDate IS Null AND @EndDate IS Null
	BEGIN
		INSERT INTO @tmpDriverBonusTable
		SELECT	DISTINCT SAF.SafetyBonusId,
				SAF.Company,
				RTRIM(VMA.VendorId) AS VendorId,
				VMA.OldDriverId,
				dbo.GetDriverName(SAF.Company,VMA.VendorId,'O') AS VendorName,--SAF.VendorName,
				SAF.HireDate,
				SAF.Period,
				SAF.PayDate,
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
				VMA.TerminationDate
		FROM	SafetyBonus SAF
				INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.VendorId
				LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
		WHERE	SAF.Company = @Company
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND SAF.VendorId = @VendorId))
				AND SWS.TermDt IS Null
		UNION
		SELECT	DISTINCT SAF.SafetyBonusId,
				SAF.Company,
				RTRIM(VMA.VendorId) AS VendorId,
				VMA.OldDriverId,
				dbo.GetDriverName(SAF.Company,VMA.VendorId,'O') AS VendorName,
				SAF.HireDate,
				SAF.Period,
				SAF.PayDate,
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
				VMA.TerminationDate
		FROM	SafetyBonus SAF
				INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.OldDriverId
				LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
		WHERE	SAF.Company = @Company
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VMA.VendorId = @VendorId))
				AND SWS.TermDt IS Null
		ORDER BY
				3
				,SAF.Period
				,SAF.BonusPayDate
				,SAF.SortColumn
				,SAF.PayDate DESC
	END
	ELSE
	BEGIN
		IF @IniDate IS NOT Null AND @EndDate IS NOT Null
		BEGIN
			INSERT INTO @tmpDriverBonusTable
			SELECT	DISTINCT SAF.SafetyBonusId,
					SAF.Company,
					RTRIM(VMA.VendorId) AS VendorId,
					VMA.OldDriverId,
					dbo.GetDriverName(SAF.Company,VMA.VendorId,'O') AS VendorName,
					SAF.HireDate,
					SAF.Period,
					SAF.PayDate,
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
					VMA.TerminationDate
			FROM	SafetyBonus SAF
					INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.VendorId
					LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
			WHERE	SAF.Company = @Company
					AND (SAF.BonusPayDate BETWEEN @IniDate AND @EndDate)
					AND (@VendorId IS Null OR (@VendorId IS NOT Null AND SAF.VendorId = @VendorId))
			UNION
			SELECT	DISTINCT SAF.SafetyBonusId,
					SAF.Company,
					RTRIM(VMA.VendorId) AS VendorId,
					VMA.OldDriverId,
					dbo.GetDriverName(SAF.Company,VMA.VendorId,'O') AS VendorName,
					SAF.HireDate,
					SAF.Period,
					SAF.PayDate,
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
					VMA.TerminationDate
			FROM	SafetyBonus SAF
					INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.OldDriverId
					LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
			WHERE	SAF.Company = @Company
					AND (SAF.BonusPayDate BETWEEN @IniDate AND @EndDate)
					AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VMA.VendorId = @VendorId))
			ORDER BY
					3
					,SAF.Period
					,SAF.BonusPayDate DESC
					,SAF.SortColumn
					,SAF.PayDate DESC
		END
		ELSE
		BEGIN
			INSERT INTO @tmpDriverBonusTable
			SELECT	DISTINCT SAF.SafetyBonusId,
					SAF.Company,
					RTRIM(VMA.VendorId) AS VendorId,
					VMA.OldDriverId,
					dbo.GetDriverName(SAF.Company,VMA.VendorId,'O') AS VendorName,
					SAF.HireDate,
					SAF.Period,
					SAF.PayDate,
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
					VMA.TerminationDate
			FROM	SafetyBonus SAF
					INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.VendorId
					LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
			WHERE	SAF.Company = @Company
					AND SAF.BonusPayDate BETWEEN @IniDate AND @EndDate
					AND (@VendorId IS Null OR (@VendorId IS NOT Null AND SAF.VendorId = @VendorId))
					AND SWS.TermDt IS Null
			UNION
			SELECT	DISTINCT SAF.SafetyBonusId,
					SAF.Company,
					RTRIM(VMA.VendorId) AS VendorId,
					VMA.OldDriverId,
					dbo.GetDriverName(SAF.Company,VMA.VendorId,'O') AS VendorName,
					SAF.HireDate,
					SAF.Period,
					SAF.PayDate,
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
					VMA.TerminationDate
			FROM	SafetyBonus SAF
					INNER JOIN #TempVendorMaster VMA ON SAF.VendorId = VMA.OldDriverId
					LEFT JOIN ##tmpCurSWSDrivers SWS ON SAF.VendorId = SWS.Code
			WHERE	SAF.Company = @Company
					AND SAF.BonusPayDate BETWEEN @IniDate AND @EndDate
					AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VMA.VendorId = @VendorId))
					AND SWS.TermDt IS Null
			ORDER BY
					3
					,SAF.Period
					,SAF.BonusPayDate
					,SAF.SortColumn
					,SAF.PayDate DESC
		END
	END

	DROP TABLE ##tmpCurSWSDrivers
	DROP TABLE #TempVendorMaster

	SELECT	0 AS SafetyBonusId,
			Company,
			VendorId,
			OldDriverId,
			VendorName,
			HireDate,
			Period,
			MAX(PayDate) AS PayDate,
			BonusPayDate,
			SUM(Miles) AS Miles,
			SUM(ToPay) AS ToPay,
			SUM(PeriodMiles) AS PeriodMiles,
			SUM(PeriodPay) AS PeriodPay,
			SUM(PeriodToPay) AS PeriodToPay,
			SortColumn,
			MAX(WeeksCounter) AS WeeksCounter,
			0 AS Paid,
			MAX(LastRunWeek) AS LastRunWeek,
			MAX(Percentage) AS Percentage,
			SUM(Drayage) AS Drayage,
			SUM(DrayageBonus) AS DrayageBonus,
			Division,
			BonusType,
			SUM(BonusUnits) AS BonusUnits,
			SUM(BonusAmount) AS BonusAmount,
			MIN(TerminationDate) AS TerminationDate
	INTO	##tmpDetailSummary
	FROM	@tmpDriverBonusTable
	WHERE	SortColumn = 0
	GROUP BY
			Company,
			VendorId,
			OldDriverId,
			VendorName,
			HireDate,
			Period,
			BonusPayDate,
			SortColumn,
			Division,
			BonusType

	DELETE	@tmpDriverBonusTable
	WHERE	SortColumn = 0

	INSERT INTO @tmpDriverBonusTable
	SELECT	*
	FROM	##tmpDetailSummary

	DROP TABLE ##tmpDetailSummary

	DECLARE	@tblSummaryData	Table (
			BonusPayDate	Date,
			VendorId		Varchar(15),
			RowNumber		Int)

	INSERT INTO @tblSummaryData
	SELECT	*, 
			ROW_NUMBER() OVER(PARTITION BY BonusPayDate ORDER BY BonusPayDate, VendorId) AS RowNumber
	FROM	(
			SELECT	DISTINCT BonusPayDate,
					VendorId
			FROM	@tmpDriverBonusTable 
			WHERE	SortColumn = 0
			) DATA

	SELECT	DISTINCT SAF.SafetyBonusId,
			SAF.Company,
			SAF.VendorId,
			SAF.OldDriverId,
			SAF.VendorName,
			SAF.HireDate,
			SAF.Period,
			SAF.PayDate,
			CAST(SAF.BonusPayDate AS Date) AS BonusPayDate,
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
			SAF.Division,
			SAF.BonusType,
			SAF.BonusUnits,
			SAF.BonusAmount,
			SAF.TerminationDate,
			TotalDriverPeriodUnits = (SELECT SUM(CASE WHEN @CalculateBasedOn = 'M' THEN TMP.PeriodMiles ELSE TMP.Drayage END) FROM @tmpDriverBonusTable TMP WHERE TMP.BonusPayDate = SAF.BonusPayDate AND TMP.Period = SAF.Period AND TMP.SortColumn = 0),
			TotalDriverPeriodAmount = (SELECT SUM(CASE WHEN @CalculateBasedOn = 'M' THEN TMP.PeriodPay ELSE TMP.DrayageBonus END) FROM @tmpDriverBonusTable TMP WHERE TMP.BonusPayDate = SAF.BonusPayDate AND TMP.Period = SAF.Period AND TMP.SortColumn = 0),
			Counter = (SELECT COUNT(*) FROM @tmpDriverBonusTable TMP WHERE TMP.VendorId = SAF.VendorId AND TMP.Period = SAF.Period AND TMP.SortColumn = 1),
			IIF(SAF.BonusType = 'D', 'Drayage', 'Miles') AS BonusTypeText,
			CONVERT(Char(10), SAF.BonusPayDate, 101) AS BonusPayDateText,
			CNT.DataCounter,
			DNT.RowNumber,
			DRV.VendorCounter
	FROM	@tmpDriverBonusTable SAF
			INNER JOIN (SELECT	DISTINCT BonusPayDate,
								COUNT(*) AS DataCounter
						FROM	@tmpDriverBonusTable 
						WHERE	SortColumn = 0
						GROUP BY BonusPayDate) CNT ON SAF.BonusPayDate = CNT.BonusPayDate
			INNER JOIN (SELECT	DISTINCT VendorId, 
								COUNT(BonusPayDate) AS VendorCounter
						FROM	@tmpDriverBonusTable 
						WHERE	SortColumn = 0
						GROUP BY VendorId) DRV ON SAF.VendorId = DRV.VendorId
			INNER JOIN @tblSummaryData DNT ON SAF.BonusPayDate = DNT.BonusPayDate AND SAF.VendorId = DNT.VendorId
	ORDER BY
			BonusPayDate 
			,VendorId
			,Period
			,SortColumn
			,PayDate DESC
END
/*
EXECUTE USP_CalculateSafetyBonus 'dnj', '1/1/2011', '3/31/2011'
EXECUTE USP_CalculateSafetyBonusTable 'GIS', '10/3/2011'
ROW_NUMBER() OVER(PARTITION BY BonusPayDate ORDER BY BonusPayDate,VendorId,Period,SortColumn,PayDate DESC) AS RowNumber
*/