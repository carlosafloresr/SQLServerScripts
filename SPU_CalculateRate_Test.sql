USE [Accounting]
GO
/****** Object:  StoredProcedure [dbo].[SPU_CalculateRate_Test]    Script Date: 05/15/2012 2:55:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SPU_CalculateRate_Test]
		@RecordId			int,
		@CompanyNumber		int,
		@StartDate			date,
		@StopDate			date = Null,
		@PrincipalID		varchar(25),
		@Equipment			varchar(25),
		@Location			varchar(25) = 'All',
		@LPCode				varchar(10),
		@IsJ1				bit = 0,
		@CustomerNo			varchar(15) = Null,
		@MoveType			varchar(3) = 'ALL',
		@Division			varchar(3) = Null,
		@CountryRegion		varchar(25) = Null
AS
BEGIN
	SET NOCOUNT ON;
	SET @location = ISNULL(@location, 'All')

	DECLARE @RateID					Int = null,
			@Freeweekends			Bit = null,
			@Freeholidays			Int = null,
			@UsedDays				Int = null,
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
			@Tariff					Float = 0,
			@OptionalDate			Date,
			@CompanyId				Varchar(5),
			@PrincipalCustomer		Varchar(15),
			@SCACCode				Varchar(25),
			@CustomerBillType		Smallint,
			@DoesBillPerDiem		Bit,
			@CustomerBillTo			Varchar(15),
			@3PLBillToAll			Bit,
			@FinalMessage			Varchar(50),
			@OrigBillTo				Varchar(15),
			@LastDate				Date,
			@ResulType				Varchar(50),
			@IsCustomerRate			Bit

	IF @CustomerNo IS NOT Null
		SET @OrigBillTo = @CustomerNo

	SET @LastDate		= DATEADD(dd, 50, @StartDate)
	SET	@SCACCode		= (SELECT SCACCode FROM Principals WHERE PrincipalID = @PrincipalID)
	SET @CompanyId		= (SELECT CompanyId FROM ILSGP01.GPCustom.dbo.Companies WHERE CompanyNumber = @CompanyNumber)
	SET @IsCustomerRate = 0
	SET	@RateID			= Null

	-- *********************************************************
	-- *** PULL FROM CUSTOMER MASTER THE PER DIEM PARAMETERS ***
	-- *********************************************************
	SELECT	@CustomerBillType		= BillType,
			@DoesBillPerDiem		= DoesBillPerDiem,
			@CustomerBillTo			= FreightBillTo,
			@3PLBillToAll			= BillToAllLocations
	FROM	ILSGP01.GPCustom.dbo.CustomerMaster 
	WHERE	CustNmbr				= @CustomerNo
			AND CompanyId			= @CompanyId

	-- **********************
	-- *** PRINCIPAL TYPE ***
	-- **********************
	IF @CustomerBillType = 1
	BEGIN
		IF @DoesBillPerDiem = 0
			SET @CustomerNo = Null
		ELSE
			SET @CustomerNo = (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
	END

	-- ********************
	-- *** FREIGHT TYPE ***
	-- ********************
	IF @CustomerBillType = 2
	BEGIN
		SET @CustomerNo = @CustomerBillTo
	END

	-- ********************
	-- ***   3PL TYPE   ***
	-- ********************
	IF @CustomerBillType = 3
	BEGIN
		IF @3PLBillToAll = 1
			SET @CustomerNo = @CustomerBillTo
		ELSE
			SET @CustomerNo = (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
	END

	PRINT '  CustomerBillTo: ' + @CustomerNo
	PRINT 'CustomerBillType: ' + CAST(@CustomerBillType AS Varchar(5))
	PRINT ' DoesBillPerDiem: ' + CAST(@DoesBillPerDiem AS Varchar(5))
	PRINT ' Customer Number: ' + @CustomerNo

	IF @StopDate IS Null
		SET @OptionalDate = DATEADD(dd, 30, @StartDate)

	-- ****************************************
	-- ***          Holidays Search         ***
	-- ****************************************
	DECLARE @HolidaysDays table ([hdate] date)
	
	DECLARE db_cursor CURSOR FOR  
	SELECT	[DATE], [EndDate]
	FROM	dbo.Holidays
	WHERE	(Holidays.Location LIKE @location OR Holidays.Location = 'All')
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

	-- ******************************
	-- ***  CUSTOMER CALCULATION  ***
	-- ******************************
	IF @CustomerNo IS NOT NULL
	BEGIN
		SET		@ResulType		= 'Customer Result'

		SELECT	@Freeweekends	= Weekends,
				@Freeholidays	= Holidays,
				@RateID			= RateID,
				@Freeday		= FreeDays
		FROM	(
				SELECT	TOP 1 *
				FROM	dbo.View_CustomerTiers 
				WHERE	EffectiveDate <= @StartDate
						AND ExpirationDate >= ISNULL(@StopDate, @OptionalDate)
						AND CustomerNo = @CustomerNo
						AND Principalid = @PrincipalID
						AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 1) OR EquipmentShortDesc = 'All')
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
				) RECS

		IF @RateID IS Null
			SET @CustomerNo = Null
		ELSE
			SET @IsCustomerRate = 1
	END

	-- *******************************
	-- ***  PRINCIPAL CALCULATION  ***
	-- *******************************
	IF @CustomerNo IS Null
	BEGIN
		SET		@ResulType		= 'Principal Result'

		SELECT	@Freeweekends	= WeekendsFree,
				@Freeholidays	= HolidaysFree,
				@RateID			= RateID,
				@Freeday		= FreeDays
		FROM	(
				SELECT	TOP 1 *
				FROM	dbo.View_PrincipalTiers 
				WHERE	Rate_EffectiveDate <= ISNULL(@StopDate, @OptionalDate)
						AND Rate_ExpirationDate >= ISNULL(@StopDate, @OptionalDate)
						AND Principalid = @PrincipalID
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 1) OR EquipmentShortDesc = 'All')
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
				) RECS

		IF @RateID IS Null OR RTRIM(@Equipment) = '' OR RTRIM(SUBSTRING(@Equipment, 1, 2)) = '' OR RTRIM(SUBSTRING(@Equipment, 3, 1)) = ''
		BEGIN
			SET	@ResulType = ''

			IF RTRIM(@Equipment) = ''
				SET @FinalMessage = 'No Equipment Type and Size was Provided'
			ELSE
			BEGIN
				IF RTRIM(SUBSTRING(@Equipment, 1, 2)) = ''
					SET @FinalMessage = 'No Equipment Size was Provided'
				ELSE
				BEGIN
					IF RTRIM(SUBSTRING(@Equipment, 3, 1)) = ''
						SET @FinalMessage = 'No Equipment Type was Provided'
					ELSE
						SET @FinalMessage = 'No Principal Rate can be found'
				END
			END
		END
	END

	BEGIN		
		-- =========================== DAYS AND DATE CALCULATIONS =================================
		SELECT	@useddays = COUNT(*)
		FROM	dbo.Dates (@startDate, @StopDate)
				LEFT JOIN @HolidaysDays ON [DATE] = HDate

		SELECT	DAT.Date,
				CASE WHEN DAT.WeekDay IN (0,1) THEN 'W' 
						WHEN HOL.Date IS NOT Null THEN 'H' 
						ELSE 'R' 
				END AS Type,
				CASE WHEN @Freeweekends = 0 AND DAT.WeekDay IN (0,1) THEN 0 
						WHEN @Freeholidays = 0 AND HOL.Date IS NOT Null THEN 0
						ELSE 1
				END AS Value
		INTO	#tmpDates			
		FROM	dbo.Dates (@StartDate, DATEADD(dd, @Freeday, @LastDate)) DAT
				LEFT JOIN Holidays HOL ON DAT.Date = HOL.Date

		SELECT	@StartBillingDate		= RECS.Date,
				@CalculatedHoliDays		= RECS.Holidays,
				@CalculatedWeekEndDays	= RECS.Weekends
		FROM	(
				SELECT	TMP1.Date,
						FreeDays = CASE WHEN TMP1.Value = 0 THEN 0 ELSE (SELECT SUM(TMP2.Value) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date) END,
						Holidays = (SELECT COUNT(TMP2.Type) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date AND TMP2.Type = 'H'),
						Weekends = (SELECT COUNT(TMP2.Type) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date AND TMP2.Type = 'W')
				FROM	#tmpDates TMP1
				) RECS
		WHERE	FreeDays = @Freeday

		DROP TABLE #tmpDates

		IF @StopDate IS Null
			SET @BilledDays = 0
		ELSE
		BEGIN
			IF @StopDate > @StartBillingDate
				SET @BilledDays = CASE WHEN @StartBillingDate = @StopDate THEN 1 ELSE DATEDIFF(dd, @StartBillingDate, @StopDate) END
			ELSE
				SET @BilledDays = 0
		END

		SET @PendingDays = @BilledDays

		PRINT '   Last Free Day: ' + CAST(@StartBillingDate AS Varchar)
		PRINT '    Weekend Days: ' + CAST(@CalculatedWeekEndDays AS Varchar)
		PRINT '    Holiday Days: ' + CAST(@CalculatedHoliDays AS Varchar)
		PRINT '     Billed Days: ' + CAST(@BilledDays AS Varchar)

		-- ===========================================================================================

		-- *****************************
		-- ***     Calculate Rate    ***
		-- *****************************
		IF @BilledDays > 0
		BEGIN
			IF @IsCustomerRate = 1
			BEGIN
				-- CUSTOMER RATES
				DECLARE db_cursor CURSOR FOR 
				SELECT	DISTINCT Rate,
						TierStartDay,
						TierEndDay
				FROM	dbo.View_CustomerTiers
				WHERE	CustomerNo = @CustomerNo
						AND ExpirationDate >= ISNULL(@StopDate, @OptionalDate)
						AND CustomerNo = @CustomerNo
						AND CustNmbr = @OrigBillTo
						AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 1) OR EquipmentShortDesc = 'All')
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
				ORDER BY TierStartDay
			END
			ELSE
			BEGIN
				-- PRINCIPAL RATES
				DECLARE db_cursor CURSOR FOR 
				SELECT	Rate,
						TierStartDay,
						TierEndDay
				FROM	dbo.RateTiers
				WHERE	RateTiers.RateID = @RateID
						AND TierStartDay <= @BilledDays
				ORDER BY TierStartDay
			END

			OPEN db_cursor   
			FETCH NEXT FROM db_cursor INTO @Rate, @TierStartDay, @TierEndDay  

			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				IF @BilledDays >= @TierEndDay
				BEGIN
					SET @Tariff = @Tariff + (@Rate * @TierEndDay)
					SET @PendingDays = @PendingDays - @TierEndDay
				END
				ELSE
				BEGIN
					SET @Tariff = @Tariff + (@Rate * @PendingDays)
					SET @PendingDays = 0
				END
				
				FETCH NEXT FROM db_cursor INTO @Rate, @TierStartDay, @TierEndDay
			END
			
			CLOSE db_cursor   
			DEALLOCATE db_cursor
		END
	END

	PRINT @ResulType

	-- *******************************************
	-- ***        FINAL RESULT CURSOR          ***
	-- *******************************************
	UPDATE	PerDiemTestRecords
	SET		PerDiemTestRecords.[FreeDays]		= RECS.[FreeDays],
			PerDiemTestRecords.[UsedDays]		= RECS.[UsedDays],
			PerDiemTestRecords.[BilledDays]		= RECS.[BilledDays],
			PerDiemTestRecords.[Weekend Days]	= RECS.[Weekend Days],
			PerDiemTestRecords.[Holidays]		= RECS.[Holidays],
			PerDiemTestRecords.[LastFreeDay]	= RECS.[LastFreeDay],
			PerDiemTestRecords.[Tariff]			= RECS.[Tariff],
			PerDiemTestRecords.[Notification]	= RECS.[Notification],
			PerDiemTestRecords.[RateUsed]		= RECS.[RateUsed]
	FROM	(
			SELECT	CASE WHEN @StopDate IS Null THEN 0 ELSE @UsedDays END AS [UsedDays], 
					CASE WHEN @StopDate IS Null THEN 0 ELSE @BilledDays END AS [BilledDays], 
					@CalculatedWeekEndDays AS [Weekend Days],
					@CalculatedHoliDays AS [Holidays],
					CONVERT(Char(10), @StartBillingDate, 101) AS [LastFreeDay],
					CASE WHEN @StopDate IS Null THEN 0 ELSE @Tariff END AS [Tariff],
					@FinalMessage AS [Notification],
					@RecordId AS RecordId,
					@Freeday AS [FreeDays],
					@ResulType AS RateUsed
			) RECS
	WHERE	PerDiemTestRecords.RecordId = RECS.RecordId
END