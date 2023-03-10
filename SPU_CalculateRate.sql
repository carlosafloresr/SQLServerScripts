USE [Accounting]
GO
/****** Object:  StoredProcedure [dbo].[SPU_CalculateRate]    Script Date: 8/23/2017 8:58:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=============================================================
 PROGRAM: SPU_CalculateRate
 DESCRIPTION: This SP will calculate the Per Diem Days, Rate and Last Free Day
 USAGE: EXECUTE SPU_CalculateRate 1, '06/27/2012', '01/20/2012', 'Evergreen', '40S', Null, 'FEMO21', 0, '9801', 'ALL'
 
 Version		Date			Author              Description
 --------------------------------------------------------------------
 1.0			05/10/2012      Carlos Flores       Created procedure
 1.1			10/10/2016		Justin Hammond      Modified select from #tmpCustomerRates to include equiment 
                                                    size in where clause even if there is only a single record 
                                                    returned.
 1.2			02/16/2017		Carlos Flores		The calculation of Holidays and Weekends was changed to correctly
													calculate the last FreeDay
 
 NOTES: Multiple code changes occured prior to 1.1. Those changes were not annotated here. All future changes 
 need to be annotated in the this change log. 
===============================================================*/
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
		@AltShip			Varchar(15) = Null,
		@DoorMove			Bit = 0,
		@Notification		Date = Null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE	@RateID						Int,
			@FreeWeekends				Bit,
			@FreeHolidays				Int,
			@UsedDays					Int,
			@FreeDays					Int,
			@CalculatedWeekEndDays		Int,
			@CalculatedHoliDays			Int,
			@BilledDays					Int,
			@Rate						Numeric(10,2),
			@TierStartDay				Int,
			@TierEndDay					Int,
			@PendingDays				Int,
			@StartBillingDate			DateTime,
			@Tariff						Float,
			@CompanyId					Varchar(5),
			@PrincipalCustomer			Varchar(15),
			@CustomerBillType			Smallint,
			@DoesBillPerDiem			Bit,
			@CustomerBillTo				Varchar(15),
			@3PLBillToAll				Int,
			@FinalMessage				Varchar(150),
			@OrigBillTo					Varchar(15),
			@LastDate					DateTime,
			@ResulType					Varchar(100),
			@IsCustomerRate				Bit,
			@BusinessDays				Bit,
			@CustomerRates				Int,
			@WithErrors					Bit,
			@LogReceivedValues			Varchar(2000),
			@LogReturnValues			Varchar(2000), 
			@FlagForReport				Bit,
			@WithAfterNotificationRate	Bit

	SET @RateID					= Null
	SET	@FreeWeekends			= Null
	SET	@FreeHolidays			= Null
	SET	@UsedDays				= Null
	SET	@FreeDays				= Null
	SET	@CalculatedWeekEndDays	= 0
	SET	@CalculatedHoliDays		= 0
	SET	@BilledDays				= 0
	SET	@PendingDays			= 0
	SET	@Tariff					= 0
	SET	@3PLBillToAll			= 0
	SET	@IsCustomerRate			= 0
	SET	@BusinessDays			= 1
	SET	@CustomerRates			= 0
	SET @OrigBillTo					= @CustomerNo --pab 6/10/2013
	SET @location					= ISNULL(@location, 'All')
	SET @LastDate					= CASE WHEN @StopDate IS Null THEN DATEADD(dd, 30, @StartDate) ELSE DATEADD(dd, 5, @StartDate) END
	SET @CompanyId					= (SELECT CompanyId FROM LENSASQL001.GPCustom.dbo.Companies WHERE CompanyNumber = @CompanyNumber AND Trucking = 1)
	SET @WithErrors					= 0
	SET @FlagForReport				= 0
	SET @LogReceivedValues			= '@CompanyNumber=' + CAST(@CompanyNumber AS Varchar) + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@StartDate=' + CAST(@StartDate AS Varchar) + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@StopDate=' + ISNULL(CAST(@StopDate AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@PrincipalID=' + ISNULL(CAST(@PrincipalID AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@Equipment=' + ISNULL(CAST(@Equipment AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@Location=' + ISNULL(CAST(@Location AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@LPCode=' + ISNULL(CAST(@LPCode AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@IsJ1=' + ISNULL(CAST(@IsJ1 AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@CustomerNo=' + ISNULL(CAST(@CustomerNo AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@MoveType=' + ISNULL(CAST(@MoveType AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@Division=' + ISNULL(CAST(@Division AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@CountryRegion=' + ISNULL(CAST(@CountryRegion AS Varchar), 'Null') + ', '
	SET @LogReceivedValues			= @LogReceivedValues + '@AltShip=' + ISNULL(CAST(@AltShip AS Varchar), 'Null')
	SET @WithAfterNotificationRate	= (SELECT WithAfterNotificationRate FROM Principals WHERE PrincipalID = @PrincipalID)

	IF @DoorMove = 1 AND @Notification IS NOT Null AND @WithAfterNotificationRate = 1
	BEGIN
		PRINT 'Attempting to Get Principal Parameters for After Notification...'

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
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All'  OR EquipmentShortDesc = SUBSTRING(@Equipment, 3, 3))
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
				) RECS
		
		IF @RateID IS Null
		BEGIN
			SET @FinalMessage		= 'Door Move with Nnotification Date but not special rate found.'
			SET	@ResulType			= ''
		END
		ELSE
		BEGIN
			SET @FinalMessage		= 'Principal After Notification rate.'
			SET	@ResulType			= @FinalMessage
			SET @LogReturnValues	= @LogReturnValues + 'Principal Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null') + CHAR(13)
			SET @StartDate			= @Notification
			SET @StopDate			= DATEADD(dd, 30, @StartDate)
			
			PRINT 'Principal Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null')
		END
	END
	
	IF @RateID IS Null
	BEGIN
		-- *********************************************************
		-- *** PULL FROM CUSTOMER MASTER THE PER DIEM PARAMETERS ***
		-- *********************************************************
		SELECT	@CustomerBillType		= BillType,
				@DoesBillPerDiem		= DoesBillPerDiem,
				@CustomerBillTo			= FreightBillTo,
				@3PLBillToAll			= BillToAllLocations
		FROM	LENSASQL001.GPCustom.dbo.CustomerMaster 
		WHERE	CustNmbr				= @CustomerNo
				AND CompanyId			= @CompanyId
    END
	ELSE
	BEGIN
		SET @CustomerBillType = -1
	END

	PRINT '  3PL Bill to All: ' + CASE WHEN @3PLBillToAll = 0 THEN 'NO' ELSE 'YES' END

	-- **********************
	-- *** PRINCIPAL TYPE ***
	-- **********************
	IF @CustomerBillType = 1
	BEGIN
		IF @DoesBillPerDiem = 0
			SET @CustomerNo = Null
		ELSE
			IF @AltShip IS Null
			BEGIN
				IF (SELECT COUNT(PDBillTo) FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode) > 1
				BEGIN
					SET @FinalMessage = 'ERROR: More than one Bill To apply to the same LP Code'
					SET @FlagForReport = 1
					--This line was removed by Mitch Coolican 1/19. This allows the container owner's default LFD to be used instead of returning nothing.
					--SET @WithErrors = 1
				END
				ELSE
				BEGIN
					SET	@CustomerNo = (SELECT PDBillTo FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
				END
			END
			ELSE
			BEGIN
				IF (SELECT COUNT(PDBillTo) FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode AND PDBillTo LIKE '%' + @AltShip + '%') = 0
				BEGIN
					SET @CustomerNo = (SELECT PDBillTo FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
					SET @FinalMessage = 'ERROR: Alt ship not setup for Principal'
					SET @FlagForReport = 1
				END
				ELSE
				BEGIN
					SET	@CustomerNo = (SELECT PDBillTo FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode AND PDBillTo LIKE '%' + @AltShip + '%')
				END
			END
	END
    
	PRINT ' Customer No: ' + CAST(ISNULL(@CustomerNo, 'None') AS Varchar)
	-- ********************
	-- *** FREIGHT TYPE ***
	-- ********************
	IF @CustomerBillType IN (0,2)   
		SET @CustomerNo = @CustomerBillTo
          PRINT ' Set CustomerNo = CustomerBillTo'

	-- ********************
	-- ***   3PL TYPE   ***
	-- ********************
	IF @CustomerBillType = 3
	BEGIN
		IF @3PLBillToAll = 1
               BEGIN
			SET @CustomerNo = @CustomerBillTo
               PRINT '-- Set CustomerNo = CustomerBillTo'
               END
		ELSE
			BEGIN
				IF @AltShip IS Null
				BEGIN
					IF (SELECT COUNT(PDBillTo) FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode) > 1
					BEGIN
						SET @FinalMessage = 'ERROR: More than one Bill To apply to the same LP Code'
						SET @FlagForReport = 1
						--This line was removed by Mitch Coolican 1/19. This allows the container owner's default LFD to be used instead of returning nothing.
						--SET @WithErrors = 1
					END
					ELSE
					BEGIN
						SET	@CustomerNo = (SELECT PDBillTo FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode)
						SET @3PLBillToAll = 1
					END
				END
				ELSE
				BEGIN
					IF (SELECT COUNT(PDBillTo) FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode AND PDBillTo LIKE '%' + @AltShip + '%') = 0
					BEGIN
						SET	@CustomerNo = Null
                        SET @FinalMessage = 'ERROR: Alt ship not setup for 3PL'
                        SET @FlagForReport = 1
					END
					ELSE
					BEGIN
						SET	@CustomerNo = (SELECT PDBillTo FROM LENSASQL001.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = @CompanyId AND CustNmbr = @CustomerNo AND LPCode = @LPCode AND PDBillTo LIKE '%' + @AltShip + '%')
						SET @3PLBillToAll = 1
					END
				END
			END
	END
	
	IF @DoesBillPerDiem = 0 AND @3PLBillToAll = 0 AND @CustomerBillType IN (1,3)
    BEGIN
		SET @CustomerNo = Null
		PRINT ' Set CustomerNo = NULL'
    END

	SET @LogReturnValues = 'dbo.SPU_CalculateRate >>   Customer Bill To: ' + CAST(@OrigBillTo AS Varchar) + CHAR(13)
	PRINT '   Customer Bill To: ' + @OrigBillTo
	SET @LogReturnValues = @LogReturnValues + ' Customer Bill Type: ' + ISNULL(CAST(@CustomerBillType AS Varchar), 'Null') + CHAR(13)
	PRINT '  Customer Bill Type: ' + CASE WHEN @CustomerBillType IS Null THEN 'NONE' ELSE CAST(@CustomerBillType AS Varchar) END
	SET @LogReturnValues = @LogReturnValues + ' Does Bill Per Diem: ' + CASE WHEN @3PLBillToAll = 1 OR @DoesBillPerDiem = 1 THEN 'YES' ELSE 'NO' END + CHAR(13)
	PRINT '  Does Bill Per Diem: ' + CASE WHEN @3PLBillToAll = 1 OR @DoesBillPerDiem = 1 THEN 'YES' ELSE 'NO' END
	SET @LogReturnValues = @LogReturnValues + '    Customer Number: ' + ISNULL(@CustomerNo, 'NONE') + CHAR(13)
	PRINT '    Customer Number: ' + CASE WHEN @CustomerNo IS Null OR @CustomerNo = '' THEN 'NONE' ELSE @CustomerNo END

	-- *****************************
	-- ***  CUSTOMER PARAMETERS  ***
	-- *****************************
	IF @CustomerNo IS NOT Null AND @WithErrors = 0
	BEGIN
		SET		@ResulType		= 'Customer Rate'

		SELECT	TOP 1 Weekends, Holidays, Rate, RateID, FreeDays, BusinessDays, EquipmentShortDesc, EquipmentSize
		INTO	#tmpCustomerRates
		FROM	dbo.View_CustomerTiers 
		WHERE	RateId = -1

		IF EXISTS(SELECT TOP 1 Weekends
					FROM	dbo.View_CustomerTiers 
					WHERE	EffectiveDate <= @StartDate
							AND ExpirationDate >= @LastDate
							AND Company = @CompanyNumber
							AND CustomerNo = @CustomerNo
							AND Principalid = @PrincipalID
							AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
							AND LPCodes LIKE '%' + RTRIM(@LPCode) + '%'
				 )
		BEGIN
			INSERT INTO #tmpCustomerRates
			SELECT	DISTINCT Weekends, Holidays, Rate, RateID, FreeDays, BusinessDays, EquipmentShortDesc, EquipmentSize
			FROM	dbo.View_CustomerTiers 
			WHERE	EffectiveDate <= @StartDate
					AND ExpirationDate >= @LastDate
					AND Company = @CompanyNumber
					AND CustomerNo = @CustomerNo
					AND Principalid = @PrincipalID
					AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
					AND LPCodes LIKE '%' + RTRIM(@LPCode) + '%'
		END
		ELSE
		BEGIN
			INSERT INTO #tmpCustomerRates
			SELECT	DISTINCT Weekends, Holidays, Rate, RateID, FreeDays, BusinessDays, EquipmentShortDesc, EquipmentSize
			FROM	dbo.View_CustomerTiers 
			WHERE	EffectiveDate <= @StartDate
					AND ExpirationDate >= @LastDate
					AND Company = @CompanyNumber
					AND CustomerNo = @CustomerNo
					AND Principalid = @PrincipalID
					AND (MoveTypeCode = @MoveType OR MoveTypeCode = 'All')
		END

		SET		@CustomerRates = (SELECT COUNT(RateID) FROM (SELECT DISTINCT RateID FROM #tmpCustomerRates) DATA)
		
		SET @LogReturnValues = @LogReturnValues + '     Customer Rates: ' + ISNULL(CAST(@CustomerRates AS Varchar), 'Null') + CHAR(13)

		PRINT '     Start Date: ' + CAST(@StartDate AS VARCHAR)
		PRINT '     Last Date: ' + CAST(@LastDate AS VARCHAR)
		PRINT '     Company: ' + CAST(@CompanyNumber AS VARCHAR)
		PRINT '     Customer No: ' + CAST(@CustomerNo AS VARCHAR)
		PRINT '     Principal ID: ' + CAST(@PrincipalID AS VARCHAR)
		PRINT '     Move Type: ' + CAST(@MoveType AS VARCHAR)
		PRINT	'     Customer Rates: ' + CAST(@CustomerRates AS Varchar)
		
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
            WHERE	(EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All')
								AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
					) RECS
		END

		SET @LogReturnValues = @LogReturnValues + ' Customer Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null') + CHAR(13)
		PRINT ' Customer Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null')

		IF @RateID IS Null
			SET @CustomerNo = Null 
		ELSE
			SET @IsCustomerRate = 1
          
	END

	PRINT ' Customer No: ' + ISNULL(CAST(@CustomerNo AS Varchar), 'Null')

	-- ******************************
	-- ***  PRINCIPAL PARAMETERS  ***
	-- ******************************
	IF @CustomerNo IS Null AND @WithErrors = 0 AND @RateID IS Null
	BEGIN
		PRINT 'Attempting to Get Principal Parameters...'
		
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
						AND (EquipmentShortDesc = SUBSTRING(@Equipment, 3, 2) OR EquipmentShortDesc = 'All'  OR EquipmentShortDesc = SUBSTRING(@Equipment, 3, 3))
						AND (EquipmentSize = SUBSTRING(@Equipment, 1, 2) OR EquipmentSize = 'All')
				) RECS
		
		SET @LogReturnValues = @LogReturnValues + 'Principal Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null') + CHAR(13)
		PRINT 'Principal Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null')
		
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

					SET @FlagForReport = 1
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
			CASE	WHEN @FreeWeekends = 0 AND DAT.WeekDay IN (0,1) AND @BusinessDays = 1 THEN 0 -- DAT.WeekDay IN (0,1) Where 0 = Saturday and 1 = Sunday
					WHEN @FreeHolidays = 0 AND HOL.Date IS NOT Null AND @BusinessDays = 1 THEN 0
					ELSE 1
			END AS Value
	INTO	#tmpDates
	FROM	dbo.Dates(@StartDate, DATEADD(dd, @FreeDays, @LastDate)) DAT
			LEFT JOIN Holidays HOL ON DAT.Date = HOL.Date AND (Location LIKE @Location OR Location = 'All' OR Location = 'Federal')

	PRINT 'PARAMETERS: @FreeWeekends: ' + CAST(@FreeWeekends AS Varchar) + '/ @IsCustomerRate: ' + CAST(@IsCustomerRate AS Varchar) + '/ @BusinessDays: ' + CAST(@BusinessDays AS Varchar)

	SELECT	@StartBillingDate		= RECS.Date,
			@CalculatedHoliDays		= RECS.Holidays,
			@CalculatedWeekEndDays	= RECS.Weekends
	FROM	(
			SELECT	TMP1.Date,
					FreeDays = CASE WHEN TMP1.Value = 0 THEN 0 ELSE (SELECT SUM(TMP2.Value) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date) END,
					Holidays = (SELECT COUNT(TMP2.Type) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date AND TMP2.Type = 'H' AND TMP2.Value = 1),
					Weekends = (SELECT COUNT(TMP2.Type) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date AND TMP2.Type = 'W' AND TMP2.Value = 1)
			FROM	#tmpDates TMP1
			) RECS
	WHERE	FreeDays = @FreeDays
		  
	PRINT '           Holidays: ' + CAST(@CalculatedHoliDays AS Varchar) + ' / Include Holidays: ' + CASE WHEN @FreeHolidays > 0 THEN 'YES' ELSE 'NO' END
	PRINT '           Weekends: ' + CAST(@CalculatedWeekEndDays AS Varchar) + ' / Include Weekends: ' + CASE WHEN @FreeWeekends > 0 THEN 'YES' ELSE 'NO' END

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

	SET @LogReturnValues = @LogReturnValues + '     Used Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null') + CHAR(13)
	PRINT '     Used Free Days: ' + ISNULL(CAST(@FreeDays AS Varchar), 'Null')

	SET @LogReturnValues = @LogReturnValues + '      Last Free Day: ' + ISNULL(CAST(@StartBillingDate AS Varchar), 'Null') + CHAR(13)
	PRINT '      Last Free Day: ' + ISNULL(CAST(@StartBillingDate AS Varchar), 'Null')

	SET @LogReturnValues = @LogReturnValues + '       Weekend Days: ' + ISNULL(CAST(@CalculatedWeekEndDays AS Varchar), 'Null') + CHAR(13)
	PRINT '       Weekend Days: ' + CAST(@CalculatedWeekEndDays AS Varchar)

	SET @LogReturnValues = @LogReturnValues + '       Holiday Days: ' + ISNULL(CAST(@CalculatedHoliDays AS Varchar), 'Null') + CHAR(13)
	PRINT '       Holiday Days: ' + CAST(@CalculatedHoliDays AS Varchar)

	SET @LogReturnValues = @LogReturnValues + '        Billed Days: ' + ISNULL(CAST(@BilledDays AS Varchar), 'Null') + CHAR(13)
	PRINT '        Billed Days: ' + CAST(@BilledDays AS Varchar)

	SET @LogReturnValues = @LogReturnValues + '      Business Days: ' + CASE WHEN @BusinessDays = 0 THEN 'NO' ELSE 'YES' END + CHAR(13)
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

	IF @WithAfterNotificationRate = 1
	BEGIN
		IF @IsCustomerRate = 1
			SET @FinalMessage = ISNULL(@FinalMessage,'') + 'Using ' + @ResulType
	END

	SET @LogReturnValues = @LogReturnValues + '   Calculation Type: ' + CAST(@ResulType AS Varchar) + CHAR(13)
	SET @LogReturnValues = @LogReturnValues + '       Notification: ' + ISNULL(@FinalMessage,'') + CHAR(13)
	SET @LogReturnValues = @LogReturnValues + '        Result type: ' + @ResulType

	SELECT	CASE WHEN @StopDate IS Null THEN 0 ELSE @UsedDays END AS [UsedDays], 
			CASE WHEN @StopDate IS Null THEN 0 ELSE @BilledDays END AS [BilledDays], 
			@CalculatedWeekEndDays AS [Weekend Days],
			@CalculatedHoliDays AS [Holidays],
			CONVERT(Char(10), @StartBillingDate, 101) AS [LastFreeDay],
			CASE WHEN @StopDate IS Null THEN 0 ELSE @Tariff END AS [Tariff],
			ISNULL(@FinalMessage,'') AS [Notification],
			@ResulType AS Calculation

	IF @FlagForReport = 1 
		INSERT INTO LFDCalculationErrors (CompanyNumber, StartDate, StopDate, PrincipalID, Equipment, Location, LPCode, IsJ1, CustomerNo, MoveType, Division, CountryRegion, AltShip, ReturnType, Errors, OutputValues) VALUES(@CompanyNumber, @StartDate, @StopDate, @PrincipalID, @Equipment, @Location, @LPCode, @IsJ1, @OrigBillTo, @MoveType, @Division, @CountryRegion, @AltShip,CAST(@ResulType AS Varchar), @FinalMessage , ISNULL(@LogReturnValues, 'NULL'));

	INSERT INTO CalculationRequestLog (CompanyNumber, PrincipalId, LPCode, Customer, RequestValues, ReturnValues) VALUES (@CompanyNumber, @PrincipalID, @LPCode, @OrigBillTo, @LogReceivedValues, ISNULL(@LogReturnValues, 'NULL'))
END