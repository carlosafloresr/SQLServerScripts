/*
************************************************************************
***             CREATE BY Carlos A. Flores ON 05/10/2012             ***
************************************************************************
*** This SP will calculate the Per Diem Days, Rate and Last Free Day ***
************************************************************************

EXECUTE SPU_CalculateRate @CompanyNumber=1, @StartDate='06/14/2013', @StopDate=null, @PrincipalID='ATCO', @Equipment='45H', @Location='All', @LPCode='WEYE37', @CustomerNo='4386', @MoveType='E',  @IsJ1=0, @Division=null, @CountryRegion='E'

EXECUTE SPU_CalculateRate 2, '03/20/2013', null, 'CMA', '40OT', Null, 'GUIN10', 0, '2945B', 'E'

EXECUTE SPU_CalculateRate 1, '06/27/2012', '01/20/2012', 'Evergreen', '40S', Null, 'FEMO21', 0, '9801', 'ALL'
EXECUTE SPU_CalculateRate 1, '06/27/2012', null, 'EVRGRN', '40S', Null, 'FEMO21', 0, '1643C', 'I'

SELECT * FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE CustNmbr = '2945B'
select * from ilsgp01.imc.dbo.rm00101 where CustNmbr = '4744'
SELECT * FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CustNmbr = '2945B' AND CompanyId = 'GIS'

SELECT * FROM View_CustomerTiers WHERE CustNmbr = '2945B' AND PrincipalID = 'cma'
SELECT * FROM View_CustomerTiers WHERE CustomerNo = 'PD3847A' and CustNmbr = '552H' AND PrincipalID = 'HAPAG'
*/
ALTER PROCEDURE [dbo].[SPU_CalculateRate]
		@CompanyNumber		Int,
		@StartDate			DateTime,
		@StopDate			DateTime = Null,
		@PrincipalID		Varchar(12),
		@Equipment			Varchar(6),
		@Location			Varchar(25) = 'All',
		@LPCode				Varchar(10),
		@IsJ1				Bit = 0,
		@CustomerNo			Varchar(15) = Null,
		@MoveType			Varchar(3) = 'ALL',
		@Division			Varchar(3) = Null,
		@CountryRegion		Varchar(25) = Null,
		@AltShip			Varchar(15) = Null
AS
BEGIN
	SET NOCOUNT ON;
	/*
	DECLARE @RateID					Int = Null,
			@FreeWeekends			Bit = Null,
			@FreeHolidays			Int = Null,
			@UsedDays				Int = Null,
			@FreeDays				Int = Null,
			@CalculatedWeekEndDays	Int = 0,
			@CalculatedHoliDays		Int = 0,
			@BilledDays				Int = 0,
			@Rate					Numeric(10,2),
			@TierStartDay			Int,
			@TierEndDay				Int,
			@PendingDays			Int = 0,
			@StartBillingDate		DateTime,
			@Tariff					Float = 0,
			@CompanyId				Varchar(5),
			@PrincipalCustomer		Varchar(15),
			@CustomerBillType		Smallint,
			@DoesBillPerDiem		Bit,
			@CustomerBillTo			Varchar(15),
			@3PLBillToAll			Int = 0,
			@FinalMessage			Varchar(50),
			@OrigBillTo				Varchar(15),
			@LastDate				DateTime,
			@ResulType				Varchar(100),
			@IsCustomerRate			Bit = 0,
			@BusinessDays			Bit = 1,
			@CustomerRates			Int = 0
*/
DECLARE		@RateID					Int,
			@FreeWeekends			Bit,
			@FreeHolidays			Int,
			@UsedDays				Int,
			@FreeDays				Int,
			@CalculatedWeekEndDays	Int,
			@CalculatedHoliDays		Int,
			@BilledDays				Int,
			@Rate					Numeric(10,2),
			@TierStartDay			Int,
			@TierEndDay				Int,
			@PendingDays			Int,
			@StartBillingDate		DateTime,
			@Tariff					Float,
			@CompanyId				Varchar(5),
			@PrincipalCustomer		Varchar(15),
			@CustomerBillType		Smallint,
			@DoesBillPerDiem		Bit,
			@CustomerBillTo			Varchar(15),
			@3PLBillToAll			Int,
			@FinalMessage			Varchar(50),
			@OrigBillTo				Varchar(15),
			@LastDate				DateTime,
			@ResulType				Varchar(100),
			@IsCustomerRate			Bit,
			@BusinessDays			Bit,
			@CustomerRates			Int,
			@WithErrors				Bit

	SET @RateID = Null
	SET	@FreeWeekends	= Null
	SET	@FreeHolidays	= Null
	SET	@UsedDays		= Null
	SET	@FreeDays		= Null
	SET	@CalculatedWeekEndDays = 0
	SET	@CalculatedHoliDays = 0
	SET	@BilledDays		= 0
	SET	@PendingDays	= 0
	SET	@Tariff			= 0
	SET	@3PLBillToAll	= 0
	SET	@IsCustomerRate = 0
	SET	@BusinessDays	= 1
	SET	@CustomerRates	= 0
	SET @OrigBillTo		= @CustomerNo --pab 6/10/2013
	SET @location		= ISNull(@location, 'All')
	SET @LastDate		= DATEADD(dd, 50, @StartDate)
	SET @CompanyId		= (SELECT CompanyId FROM ILSGP01.GPCustom.dbo.Companies WHERE CompanyNumber = @CompanyNumber)
	SET @WithErrors		= 0
	
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
			IF (SELECT COUNT(PDBillTo) FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode) > 1
			BEGIN
				SET @FinalMessage = 'ERROR: More than one Bill To apply to the same LP Code'
				SET @WithErrors = 1
			END
			ELSE
				SET @CustomerNo = (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
	END

	-- ********************
	-- *** FREIGHT TYPE ***
	-- ********************
	IF @CustomerBillType IN (0,2)
		SET @CustomerNo = @CustomerBillTo

	-- ********************
	-- ***   3PL TYPE   ***
	-- ********************
	IF @CustomerBillType = 3
	BEGIN
		IF @3PLBillToAll = 1
			SET @CustomerNo = @CustomerBillTo
		ELSE
			BEGIN
				IF @AltShip IS Null
				BEGIN
					IF (SELECT COUNT(PDBillTo) FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode) > 1
					BEGIN
						SET @FinalMessage = 'ERROR: More than one Bill To apply to the same LP Code'
						SET @WithErrors = 1
					END
					ELSE
					BEGIN
						SET	@CustomerNo = (SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
						SET @3PLBillToAll = 1
					END
				END
				ELSE
				BEGIN
					IF (SELECT COUNT(PDBillTo) FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode AND PDBillTo LIKE '%' + @AltShip + '%') = 0
					BEGIN
						SET @FinalMessage = 'ERROR: The Alt Ship does not relate to the Customer and LP Code'
						SET @WithErrors = 1
					END
					ELSE
					BEGIN
						SET	@CustomerNo = (SELECT REPLACE(PDBillTo, 'PD', '') FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode AND PDBillTo LIKE '%' + @AltShip + '%')
						SET @3PLBillToAll = 1
					END
				END
			END
	END
	
	IF @DoesBillPerDiem = 0 AND @3PLBillToAll = 0 AND @CustomerBillType IN (1,3)
		SET @CustomerNo = Null

	PRINT '   Customer Bill To: ' + @OrigBillTo
	PRINT '   CustomerBillType: ' + CASE WHEN @CustomerBillType IS Null THEN 'NONE' ELSE CAST(@CustomerBillType AS Varchar) END
	PRINT '    DoesBillPerDiem: ' + CASE WHEN @3PLBillToAll = 1 OR @DoesBillPerDiem = 1 THEN 'YES' ELSE 'NO' END
	PRINT '    Customer Number: ' + ISNULL(@CustomerNo, 'NONE')

	-- *****************************
	-- ***  CUSTOMER PARAMETERS  ***
	-- *****************************
	IF @CustomerNo IS NOT Null AND @WithErrors = 0
	BEGIN
		SET		@ResulType		= 'Customer Rate'

		SELECT	DISTINCT Weekends, Holidays, Rate, RateID, FreeDays, BusinessDays, EquipmentShortDesc, EquipmentSize
		INTO	#tmpCustomerRates
		FROM	dbo.View_CustomerTiers 
		WHERE	EffectiveDate <= @StartDate
				AND ExpirationDate >= @LastDate
				AND Company = @CompanyNumber
				AND CustomerNo = @CustomerNo
				--AND CustNmbr = CASE WHEN RTRIM(@OrigBillTo)='' THEN @CustomerNo ELSE @OrigBillTo END
				AND Principalid = @PrincipalID
				AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')

		SET		@CustomerRates = (SELECT COUNT(RateID) FROM (SELECT DISTINCT RateID FROM #tmpCustomerRates) DATA)
		
		PRINT	'Customer Rates: ' + CAST(@CustomerRates AS Varchar)

		IF @CustomerRates > 1
		BEGIN
			SELECT	@FreeWeekends	= Weekends,
					@FreeHolidays	= Holidays,
					@RateID			= CASE WHEN Rate IS NULL THEN NULL ELSE RateID END,
					@FreeDays		= FreeDays,
					@BusinessDays	= BusinessDays
			FROM	(
						SELECT	TOP 1 *
						FROM	#tmpCustomerRates 
						WHERE	(EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All')
								AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
					) RECS
		END
		ELSE
		BEGIN
			SELECT	@FreeWeekends	= Weekends,
					@FreeHolidays	= Holidays,
					@RateID			= CASE WHEN Rate IS NULL THEN NULL ELSE RateID END,
					@FreeDays		= FreeDays,
					@BusinessDays	= BusinessDays
			FROM	(
						SELECT	TOP 1 *
						FROM	#tmpCustomerRates 
					) RECS
		END

		PRINT ' Customer Free Days: ' + CAST(@FreeDays AS Varchar)

		IF @RateID IS Null
			SET @CustomerNo = Null 
		ELSE
			SET @IsCustomerRate = 1
	END
	
	-- ******************************
	-- ***  PRINCIPAL PARAMETERS  ***
	-- ******************************
	IF @CustomerNo IS Null AND @WithErrors = 0
	BEGIN
		IF @FreeDays IS NOT Null
			SET @ResulType		= 'Customer Extended Free Days / Principal Rate / ' + CASE WHEN @BusinessDays = 0 THEN 'Calendar Days' ELSE 'Business Days' END
		ELSE
			SET	@ResulType		= 'Principal Rate'

		SELECT	@FreeWeekends	= WeekendsFree,
				@FreeHolidays	= HolidaysFree,
				@FreeDays		= CASE WHEN @RateID IS Null AND @FreeDays IS NOT Null THEN @FreeDays ELSE FreeDays END,
				@RateID			= RateID
		FROM	(
				SELECT	TOP 1 *
				FROM	dbo.View_PrincipalTiers 
				WHERE	Rate_EffectiveDate <= @LastDate
						AND Rate_ExpirationDate >= @LastDate
						AND Principalid = @PrincipalID
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All')
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
				) RECS

		PRINT 'Principal Free Days: ' + CAST(@FreeDays AS Varchar)
		
		-- ***************** NOT REQUIRED PARAMETERS FOUND TO CALCULATE DATA ************************
		--IF @RateID IS Null OR RTRIM(@Equipment) = '' OR RTRIM(SUBSTRING(@Equipment, 1, 2)) = '' OR RTRIM(SUBSTRING(@Equipment, 3, 1)) = ''
		IF @RateID IS Null OR ISNULL(RTRIM(@Equipment),'') = '' OR ISNULL(RTRIM(SUBSTRING(@Equipment, 1, 2)), '') = '' OR ISNULL(RTRIM(SUBSTRING(@Equipment, 3, 2)),'') = ''
		BEGIN
			SET	@ResulType = ''

			--IF RTRIM(@Equipment) = ''
			IF ISNULL(RTRIM(@Equipment),'') = ''
				SET @FinalMessage = 'No Equipment Type and Size was Provided'
			ELSE
			BEGIN
				--IF RTRIM(SUBSTRING(@Equipment, 1, 2)) = ''
				IF ISNULL(RTRIM(SUBSTRING(@Equipment, 1, 2)), '') = ''
					SET @FinalMessage = 'No Equipment Size was Provided'
				ELSE
				BEGIN
					--IF RTRIM(SUBSTRING(@Equipment, 3, 1)) = ''
					IF ISNULL(RTRIM(SUBSTRING(@Equipment, 3, 2)),'') = ''
						SET @FinalMessage = 'No Equipment Type was Provided'
					ELSE
						SET @FinalMessage = 'No Principal or Customer Rate can be found'
				END
			END
		END
	END

	-- =========================== DAYS AND DATE CALCULATIONS =================================
	SET	@UsedDays = DATEDIFF(dd, @startDate, @StopDate) + 1

	SELECT	DISTINCT DAT.Date,
			CASE WHEN DAT.WeekDay IN (0,1) AND @BusinessDays = 1 THEN 'W' 
					WHEN HOL.Date IS NOT Null AND @BusinessDays = 1 THEN 'H' 
					ELSE 'R' 
			END AS Type,
			CASE	WHEN @FreeWeekends = 0 AND @IsCustomerRate = 0 AND DAT.WeekDay IN (0,1) AND @BusinessDays = 1 THEN 0 
					WHEN @FreeHolidays = 0 AND @IsCustomerRate = 0 AND HOL.Date IS NOT Null AND @BusinessDays = 1 THEN 0
					ELSE 1
			END AS Value
	INTO	#tmpDates
	FROM	dbo.Dates (@StartDate, DATEADD(dd, @FreeDays, @LastDate)) DAT
			LEFT JOIN Holidays HOL ON DAT.Date = HOL.Date AND (Location LIKE @Location OR Location = 'All')

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
	WHERE	FreeDays = @FreeDays

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

	PRINT '     Used Free Days: ' + CAST(@FreeDays AS Varchar)
	PRINT '      Last Free Day: ' + CAST(@StartBillingDate AS Varchar)
	PRINT '       Weekend Days: ' + CAST(@CalculatedWeekEndDays AS Varchar)
	PRINT '       Holiday Days: ' + CAST(@CalculatedHoliDays AS Varchar)
	PRINT '        Billed Days: ' + CAST(@BilledDays AS Varchar)
	PRINT '      Business Days: ' + CASE WHEN @BusinessDays = 0 THEN 'NO' ELSE 'YES' END

	-- ******************************
	-- ***     Calculate Rate     ***
	-- ******************************
	IF @BilledDays > 0
	BEGIN
		SET @PendingDays = @BilledDays

		IF @IsCustomerRate = 1
		BEGIN
			-- CUSTOMER RATES
			IF EXISTS(SELECT TOP 1 Rate,
								TierStartDay,
								TierEndDay
						FROM	dbo.View_CustomerTiers
						WHERE	@LastDate BETWEEN EffectiveDate AND ExpirationDate
								AND CustomerNo = @CustomerNo
								AND CustNmbr = @OrigBillTo
								AND Principalid = @PrincipalID
								AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
								AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All')
								AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
								AND Rate IS NOT Null
						ORDER BY TierStartDay)
			BEGIN
				DECLARE db_cursor CURSOR FOR 
				SELECT	DISTINCT Rate,
						TierStartDay,
						TierEndDay
				FROM	dbo.View_CustomerTiers
				WHERE	@LastDate BETWEEN EffectiveDate AND ExpirationDate
						AND CustomerNo = @CustomerNo
						AND CustNmbr = @OrigBillTo
						AND Principalid = @PrincipalID
						AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All')
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
						AND Rate IS NOT Null
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

				SELECT	*
				FROM	dbo.RateTiers
				WHERE	RateTiers.RateID = @RateID
						AND TierStartDay <= @BilledDays
				ORDER BY TierStartDay
			END
		END
		ELSE
		BEGIN  -- PRINCIPAL RATES
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

	PRINT '   Calculation Type: ' + @ResulType

	SELECT	CASE WHEN @StopDate IS Null THEN 0 ELSE @UsedDays END AS [UsedDays], 
			CASE WHEN @StopDate IS Null THEN 0 ELSE @BilledDays END AS [BilledDays], 
			@CalculatedWeekEndDays AS [Weekend Days],
			@CalculatedHoliDays AS [Holidays],
			CONVERT(Char(10), @StartBillingDate, 101) AS [LastFreeDay],
			CASE WHEN @StopDate IS Null THEN 0 ELSE @Tariff END AS [Tariff],
			ISNULL(@FinalMessage,'') AS [Notification],
			@ResulType AS Calculation
END

