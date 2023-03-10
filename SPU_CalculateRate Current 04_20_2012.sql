USE [Accounting]
GO
/****** Object:  StoredProcedure [dbo].[SPU_CalculateRate]    Script Date: 04/20/2012 4:14:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXECUTE SPU_CalculateRate '03/29/2012', Null, 1, '20S'
EXECUTE SPU_CalculateRate '02/1/2012', '03/27/2012', 1, '20S'
EXECUTE SPU_CalculateRate '02/01/2012', '02/20/2012', 1, '40O', Null, 0, 'PD6040', 'ALL'

*/
ALTER PROCEDURE [dbo].[SPU_CalculateRate]
		@StartDate			date,
		@StopDate			date = Null,
		@PrincipalID		varchar(50),
		@Equipment			varchar(50),
		@Location			varchar(50) = Null,
		@IsJ1				bit = 0,
		@CustomerNo			varchar(15) = Null,
		@MoveType			varchar(3) = 'ALL'
AS
BEGIN
	SET NOCOUNT ON;
	SET @location = ISNULL(@location, 'All')

	DECLARE @rateid					Int = null,
			@Freeweekends			Bit = null,
			@Freeholidays			Int = null,
			@equipmentType			Int = null ,
			@equipmentSize			Int = null,
			@useddays				Int = null,
			@freeday				Int = null,
			@date					Date = null, 
			@enddate				Date = null,
			@chargeddays			Int = 0,
			@LastWeekDay			Int = 0,
			@CalculatedWeekEndDays	Int = 0,
			@CalculatedHoliDays		Int = 0,
			@BilledDays				Int = 0,
			@Rate					Numeric(10,2),
			@TierStartDay			Int,
			@TierEndDay				Int,
			@PendingDays			Int = 0,
			@StartBillingDate		Date,
			@TempDate				Date,
			@Costo					Float = 0,
			@OptionalDate			Date

	IF @StopDate IS Null
		SET @OptionalDate = DATEADD(dd, 30, @StartDate)

	DECLARE @HolidaysDays table ([hdate] date)

	-- Holidays
	DECLARE db_cursor CURSOR FOR  
	SELECT	[DATE], [EndDate]
	FROM	dbo.Holidays
	WHERE	Holidays.Location LIKE @location
			AND [Date] IS NOT Null
			AND [Date] BETWEEN @startDate AND ISNULL(@StopDate, @OptionalDate)

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @Date, @EndDate   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		IF @enddate is null
		BEGIN
				INSERT INTO @HolidaysDays ([hdate]) VALUES (@date)
		END
		ELSE
		BEGIN
			INSERT INTO @HolidaysDays 
			SELECT [DATE] FROM [dbo].[Dates] (@date ,@enddate)
		END
		       
		FETCH NEXT FROM db_cursor INTO @date, @enddate  
	END

	CLOSE db_cursor   
	DEALLOCATE db_cursor 

	SELECT	@equipmentSize = EquipmentSizeId 
	FROM	EquipmentSize 
	WHERE	EquipmentSize.ShortDesc = SUBSTRING(@equipment, 1, 2)

	SELECT	@equipmentType = EquipmentTypeId 
	FROM	EquipmentType 
	WHERE	EquipmentType.ShortDesc = SUBSTRING(@equipment, 3, 1)

	--*************************
	--  CUSTOMER CALCULATION
	--*************************
	SELECT	@Freeweekends	= Weekends,
			@Freeholidays	= Holidays,
			@Rateid			= RateID,
			@Freeday		= FreeDays
	FROM	dbo.View_CustomerTiers 
	WHERE	ExpirationDate >= ISNULL(@StopDate, @OptionalDate)
			AND PrincipalKey = @PrincipalID
			AND MoveTypeCode = @MoveType
			AND EquipmentTypeId LIKE '%' + CONVERT(varchar(50), @equipmentType) + '%'
			AND EquipmentSizeID LIKE '%' + CONVERT(varchar(50), @equipmentSize) + '%'

	SET @StartBillingDate = DATEADD(dd, @Freeday - 1, @StartDate)
		
	SELECT	@useddays				= COUNT(*),
			@CalculatedWeekEndDays	= SUM(CASE WHEN @Freeweekends = 0 AND [DATE] <= @StartBillingDate AND [weekday] IN ('0','1') THEN 1 ELSE 0 END),
			@CalculatedHoliDays		= SUM(CASE WHEN @Freeholidays = 0 AND [DATE] <= @StartBillingDate AND HDate IS NOT NULL THEN 1 ELSE 0 END)
	FROM	dbo.Dates (@startDate, ISNULL(@StopDate, @OptionalDate))
			LEFT JOIN @HolidaysDays ON [DATE] = HDate

	SET @TempDate = DATEADD(dd, 1, @StartBillingDate)
	SET @StartBillingDate = DATEADD(dd, @CalculatedWeekEndDays, @StartBillingDate)

	-- Find New Weekend Days
	WHILE @TempDate < DATEADD(dd, @CalculatedWeekEndDays, @StartBillingDate)
	BEGIN
		IF DATEPART(DW, @TempDate) = 1 OR DATEPART(DW, @TempDate) = 7
			SET @LastWeekDay = @LastWeekDay + 1
				
		SET @TempDate = DATEADD(DD, 1, @TempDate)
	END

	IF @LastWeekDay > 0 AND @Freeweekends = 0
	BEGIN
		SET @StartBillingDate = DATEADD(dd, @LastWeekDay, @StartBillingDate)
		SET @CalculatedWeekEndDays = @CalculatedWeekEndDays + @LastWeekDay
	END

	IF @CalculatedHoliDays > 0
	BEGIN
		SET @StartBillingDate = DATEADD(dd, @CalculatedHoliDays, @StartBillingDate)
	END

	PRINT 'Last Free Day:' + CAST(@StartBillingDate AS Varchar)
	PRINT 'Weekend Days: ' + CAST(@CalculatedWeekEndDays AS Varchar)
	PRINT 'Holiday Days: ' + CAST(@CalculatedHoliDays AS Varchar)

	SET @chargeddays	= @useddays 
	SET @BilledDays		= CASE WHEN @useddays - @CalculatedWeekEndDays - @CalculatedHoliDays <= @Freeday THEN 0 ELSE @useddays - @CalculatedWeekEndDays - @CalculatedHoliDays - @Freeday END
	SET @PendingDays	= @BilledDays

	-- Calculate Rate
	IF @BilledDays > 0
	BEGIN
		DECLARE db_cursor CURSOR FOR 
		SELECT	Rate,
				TierStartDay,
				TierEndDay
		FROM	dbo.LPTiers
		WHERE	RateID = @rateid
				AND TierStartDay <= @BilledDays
		ORDER BY TierStartDay
			
		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @Rate, @TierStartDay, @TierEndDay  

		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			IF @BilledDays >= @TierEndDay
			BEGIN
				SET @Costo = @Costo + (@Rate * @TierEndDay)
				SET @PendingDays = @PendingDays - @TierEndDay
			END
			ELSE
			BEGIN
				SET @Costo = @Costo + (@Rate * @PendingDays)
				SET @PendingDays = 0
			END
				
			FETCH NEXT FROM db_cursor INTO @Rate, @TierStartDay, @TierEndDay
		END
			
		CLOSE db_cursor   
		DEALLOCATE db_cursor

		SELECT	CASE WHEN @StopDate IS Null THEN 0 ELSE @useddays END AS [UsedDays], 
				CASE WHEN @StopDate IS Null THEN 0 ELSE @BilledDays END AS [BilledDays], 
				@CalculatedWeekEndDays AS [Weekend Days],
				@CalculatedHoliDays AS [Holidays],
				CONVERT(Char(10), @StartBillingDate, 101) AS [LastFreeDay],
				CASE WHEN @StopDate IS Null THEN 0 ELSE @Costo END AS [Cost]
	END
	ELSE
	BEGIN
		SET @CustomerNo = Null
	END

	--*************************
	--  PRINCIPAL CALCULATION
	--*************************
	IF @CustomerNo IS Null
	BEGIN
		SELECT	@Freeweekends	= PrincipalAgreements.WeekendsFree,
				@Freeholidays	= PrincipalAgreements.HolidaysFree,
				@Rateid			= AgreementsRateTiers.RateID,
				@Freeday		= CASE WHEN @IsJ1 = 1 THEN AgreementsRateTiers.STDays ELSE AgreementsRateTiers.FreeDays END
		FROM	dbo.Principals 
				INNER JOIN dbo.PrincipalAgreements ON (Principals.PrincipalKey = PrincipalAgreements.PrincipalKey )
				INNER JOIN dbo.AgreementsRateTiers ON (PrincipalAgreements.AgrementID = AgreementsRateTiers.AgreementID) 
		WHERE	PrincipalAgreements.ExpirationDate >= ISNULL(@StopDate, @OptionalDate)
				AND Principals.PrincipalKey = @PrincipalID
				AND AgreementsRateTiers.EquipmentTypeId LIKE '%' + CONVERT(varchar(50), @equipmentType) + '%'
				AND AgreementsRateTiers.EquipmentSizeID LIKE '%' + CONVERT(varchar(50), @equipmentSize) + '%'

		SET @StartBillingDate = DATEADD(dd, @Freeday - 1, @StartDate)
		
		SELECT	@useddays				= COUNT(*),
				@CalculatedWeekEndDays	= SUM(CASE WHEN @Freeweekends = 1 AND [DATE] <= @StartBillingDate AND [weekday] IN ('0','1') THEN 1 ELSE 0 END),
				@CalculatedHoliDays		= SUM(CASE WHEN @Freeholidays = 1 AND [DATE] <= @StartBillingDate AND HDate IS NOT NULL THEN 1 ELSE 0 END)
		FROM	dbo.Dates (@startDate, ISNULL(@StopDate, @OptionalDate))
				LEFT JOIN @HolidaysDays ON [DATE] = HDate

		SET @TempDate = DATEADD(dd, 1, @StartBillingDate)
		SET @StartBillingDate = DATEADD(dd, @CalculatedWeekEndDays, @StartBillingDate)

		-- Find New Weekend Days
		WHILE @TempDate < DATEADD(dd, @CalculatedWeekEndDays, @StartBillingDate)
		BEGIN
			IF DATEPART(DW, @TempDate) = 1 OR DATEPART(DW, @TempDate) = 7
				SET @LastWeekDay = @LastWeekDay + 1
				
			SET @TempDate = DATEADD(DD, 1, @TempDate)
		END

		IF @LastWeekDay > 0
		BEGIN
			SET @StartBillingDate = DATEADD(dd, @LastWeekDay, @StartBillingDate)
			SET @CalculatedWeekEndDays = @CalculatedWeekEndDays + @LastWeekDay
		END

		IF @CalculatedHoliDays > 0
		BEGIN
			SET @StartBillingDate = DATEADD(dd, @CalculatedHoliDays, @StartBillingDate)
		END

		PRINT 'Last Free Day:' + CAST(@StartBillingDate AS Varchar)
		PRINT 'Weekend Days: ' + CAST(@CalculatedWeekEndDays AS Varchar)
		PRINT 'Holiday Days: ' + CAST(@CalculatedHoliDays AS Varchar)

		SET @chargeddays	= @useddays 
		SET @BilledDays		= CASE WHEN @useddays - @CalculatedWeekEndDays - @CalculatedHoliDays <= @Freeday THEN 0 ELSE @useddays - @CalculatedWeekEndDays - @CalculatedHoliDays - @Freeday END
		SET @PendingDays	= @BilledDays

		-- Calculate Rate
		IF @BilledDays > 0
		BEGIN
			DECLARE db_cursor CURSOR FOR 
			SELECT	Rate,
					TierStartDay,
					TierEndDay
			FROM	dbo.RateTiers
			WHERE	RateTiers.RateID = @rateid
					AND TierStartDay <= @BilledDays
			ORDER BY TierStartDay
			
			OPEN db_cursor   
			FETCH NEXT FROM db_cursor INTO @Rate, @TierStartDay, @TierEndDay  

			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				IF @BilledDays >= @TierEndDay
				BEGIN
					SET @Costo = @Costo + (@Rate * @TierEndDay)
					SET @PendingDays = @PendingDays - @TierEndDay
				END
				ELSE
				BEGIN
					SET @Costo = @Costo + (@Rate * @PendingDays)
					SET @PendingDays = 0
				END
				
				FETCH NEXT FROM db_cursor INTO @Rate, @TierStartDay, @TierEndDay
			END
			
			CLOSE db_cursor   
			DEALLOCATE db_cursor
		END

		SELECT	CASE WHEN @StopDate IS Null THEN 0 ELSE @useddays END AS [UsedDays], 
				CASE WHEN @StopDate IS Null THEN 0 ELSE @BilledDays END AS [BilledDays], 
				@CalculatedWeekEndDays AS [Weekend Days],
				@CalculatedHoliDays AS [Holidays],
				CONVERT(Char(10), @StartBillingDate, 101) AS [LastFreeDay],
				CASE WHEN @StopDate IS Null THEN 0 ELSE @Costo END AS [Cost]
	END
END