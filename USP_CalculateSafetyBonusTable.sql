USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CalculateSafetyBonusTable]    Script Date: 9/20/2022 3:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CalculateSafetyBonusTable 'AIS', '09/15/2022', Null, 1
EXECUTE USP_CalculateSafetyBonusTable 'AIS', '09/22/2022', 'A52378', 1
EXECUTE USP_CalculateSafetyBonusTable 'HMIS', '12/20/2021', 'H50170', 1

SELECT * FROM SafetyBonus WHERE Company = 'GIS' AND PAYDATE = '08/07/2014'
*/
ALTER PROCEDURE [dbo].[USP_CalculateSafetyBonusTable] 
		@Company	Varchar(5), 
		@RunDate	Date = Null, 
		@DriverId	Varchar(12) = Null,
		@ShowData	Bit = 0
AS
SET NOCOUNT ON

IF ISNUMERIC(@Company) = 1
BEGIN
	SET @Company = (SELECT CompanyId FROM Companies WHERE CompanyNumber = @Company AND IsTest = 0)
END

IF EXISTS(SELECT Company FROM SafetyBonusParameters WHERE Company = @Company)
BEGIN
	DECLARE	@BenStartDate		Datetime,
			@BenPeriods			Int,
			@BenPayRate			Numeric(10,2),
			@VendorId			varchar(10),
			@OldDriverId		varchar(10),
			@VendorName			varchar(50),
			@HireDate			datetime,
			@Period				char(6),
			@PayDate			datetime,
			@BonusPayDate		datetime,
			@Miles				int,
			@ToPay				numeric(38,2),
			@PeriodMiles		int,
			@PeriodPay			numeric(38,2),
			@PeriodToPay		numeric(38,2),
			@SortColumn			int,
			@WeeksCounter		int,
			@PayDriverBonus		Bit,
			@GrandfatherDate	Date,
			@WeekEndingDate		Date,
			@Percentage			Decimal(10,2),
			@DrayageBonus		Decimal(10,2),
			@Drayage			Decimal(12,2),
			@DPY_WeekEndDate	Datetime,
			@SWSQuery			Varchar(MAX),
			@CompanyNumber		Smallint,
			@PayTypes			Varchar(50)

		BEGIN TRY
			--PRINT 'Step 1 - ' + CONVERT(Varchar, GETDATE(), 101)
			EXECUTE USP_FixSafetyBonus @Company, @DriverId

			--PRINT 'Step 2 - ' + CONVERT(Varchar, GETDATE(), 101)
			SELECT	@CompanyNumber = CompanyNumber
			FROM	Companies
			WHERE	CompanyId = @Company

			SELECT	@BenStartDate		= StartDate,
					@BenPeriods			= PayPeriods,
					@BenPayRate			= Rate,
					@GrandfatherDate	= GrandfatherDate,
					@PayTypes			= PayTypes
			FROM	SafetyBonusParameters
			WHERE	Company = @Company

			UPDATE	SafetyBonus
			SET		Paid = 1
			WHERE	BonusPayDate < DATEADD(dd, -32, GETDATE())
					AND Paid = 0
		
			IF @RunDate IS Null
			BEGIN
				SET	@RunDate = dbo.TTOD(dbo.DayFwdBack(GETDATE(),'N','Thursday'))
			END
			ELSE
			BEGIN
				IF DATENAME(weekday, @RunDate) <> 'Thursday'
					SET	@RunDate = dbo.TTOD(dbo.DayFwdBack(@RunDate,'N','Thursday'))
			END

			DECLARE	@tblDrayage		Table (
					CompanyNumber	Smallint,
					DriverId		Varchar(12),
					Drayage			Numeric(10,2),
					Miles			Int)

			SET @DPY_WeekEndDate	= dbo.TTOD(dbo.DayFwdBack(@RunDate,'P','Saturday'))
			SET @SWSQuery			= 'SELECT cmpy_no AS CompanyNumber, dr_code AS DriverId, SUM(payamt)::numeric(12,2) AS Drayage, SUM(paymiles)::numeric(9,0) AS Miles FROM Trk.DrPay WHERE cmpy_no = ' + CAST(@CompanyNumber AS Char(1)) + ' AND paytype IN (''' + REPLACE(@PayTypes, ',', ''',''') + ''') AND wkpdate = ''' + CONVERT(char(10), @DPY_WeekEndDate, 101) + ''' GROUP BY cmpy_no, dr_code'

			--PRINT 'Step 3 - ' + CONVERT(Varchar, GETDATE(), 101) + ' ---> GETTING SWS DRAYAGE AND MILES INFORMATION'
			--PRINT @SWSQuery
			INSERT INTO @tblDrayage
			EXECUTE USP_QuerySWS_ReportData @SWSQuery

			SET @PayDate		= @RunDate
			SET @WeekEndingDate	= DATEADD(dd, -5, @PayDate)

			--PRINT 'Step 4 - ' + CONVERT(Varchar, GETDATE(), 101) + '---> GETTING COMPANY SAFETY BONUS PARAMETERS'

			DECLARE	@tblVendors				Table (
					VendorId				Varchar(12),
					Company					Varchar(5),
					HireDate				Datetime,
					TerminationDate			Datetime,
					SubType					Smallint,
					Division				Varchar(2),
					OldDriverId				Varchar(12),
					BonusExpirationDate		Date,
					BonusReactivationDate	Date)

				IF @PayDate > @BenStartDate
				BEGIN
					--PRINT 'Step 5 - ' + CONVERT(Varchar, GETDATE(), 101) + '---> GETTING DRIVER INFORMATION'

					INSERT INTO @tblVendors
					SELECT	VM.VendorId
							,UPPER(VM.Company) AS Company
							,ISNULL(VO.HireDate,VM.HireDate) AS HireDate
							,VM.TerminationDate
							,VM.SubType
							,VM.Division
							,VM.OldDriverId
							,SD.BonusExpirationDate
							,SD.BonusReactivationDate
					FROM	VendorMaster VM
							LEFT JOIN VendorMaster VO ON VM.Company = VO.Company AND VM.OldDriverId = VO.VendorId
							LEFT JOIN SafetyBonusParametersByDivision SD ON VM.Company = SD.Company AND VM.Division = SD.Division
					WHERE	VM.Company = @Company
							AND (@DriverId IS Null OR (@DriverId IS NOT Null AND VM.VendorId = @DriverId))

					IF @ShowData = 1
						SELECT	VM.VendorId
								,UPPER(VM.Company) AS Company
								,ISNULL(VO.HireDate,VM.HireDate) AS HireDate
								,VM.TerminationDate
								,VM.SubType
								,VM.Division
								,VM.OldDriverId
								,SD.BonusExpirationDate
								,SD.BonusReactivationDate
						FROM	VendorMaster VM
								LEFT JOIN VendorMaster VO ON VM.Company = VO.Company AND VM.OldDriverId = VO.VendorId
								LEFT JOIN SafetyBonusParametersByDivision SD ON VM.Company = SD.Company AND VM.Division = SD.Division
						WHERE	VM.Company = @Company
								AND (@DriverId IS Null OR (@DriverId IS NOT Null AND VM.VendorId = @DriverId))

					DELETE	@tblVendors
					WHERE	VendorId IN (SELECT OldDriverId FROM @tblVendors WHERE OldDriverId IS NOT Null)
							AND (@DriverId IS Null OR (@DriverId IS NOT Null AND VendorId <> @DriverId))
							OR (@DPY_WeekEndDate >= BonusExpirationDate AND BonusReactivationDate IS Null)
							OR (@DPY_WeekEndDate >= BonusExpirationDate AND @DPY_WeekEndDate <= BonusReactivationDate)

					--PRINT 'Step 6 - ' + CONVERT(Varchar, GETDATE(), 101) + '---> GETTING PAY PERIOD DRAYAGE AND MILES'
	
					SELECT	DISTINCT UPPER(CO.CompanyId) AS Company
							,VM.VendorId
							,VM.OldDriverId
							,VM.HireDate
							,dbo.GetVendorName(@Company, VM.VendorId) AS VendorName
							,@PayDate AS PayDate
							,dbo.FindBonusPeriod(CO.CompanyId, VM.HireDate, @BenPeriods, @PayDate) AS Period
							,dbo.FindBonusPeriodDates(CO.CompanyId, VM.HireDate, @BenPeriods, @PayDate) AS BonusPayDate
							,@DPY_WeekEndDate AS WeekEndDate
							,VS.Miles
							,VS.Drayage
							,Percentage = dbo.SafetyBonusPercentage(@Company, VM.VendorId, @BenStartDate, @GrandfatherDate, VM.HireDate, @PayDate, @BenPayRate)
					INTO	#tmpRecords
					FROM	@tblDrayage VS
							INNER JOIN Companies CO ON VS.CompanyNumber = CO.CompanyNumber
							INNER JOIN @tblVendors VM ON VM.Company = CO.CompanyId AND (VM.VendorId = VS.DriverId OR VM.OldDriverId = VS.DriverId)
							LEFT JOIN SafetyBonus SF ON CO.CompanyId = SF.Company AND VM.VendorId = SF.VendorId AND SF.Period = dbo.FindBonusPeriod(CO.CompanyId, VM.HireDate, @BenPeriods, @DPY_WeekEndDate + 5)
					WHERE	VM.Company = @Company
							--AND VM.TerminationDate IS Null
							AND (VS.Miles + VS.Drayage) <> 0

					IF @ShowData = 1
						SELECT	DISTINCT UPPER(CO.CompanyId) AS Company
								,VM.VendorId
								,VM.OldDriverId
								,VM.HireDate
								,dbo.GetVendorName(@Company, VM.VendorId) AS VendorName
								,@PayDate AS PayDate
								,dbo.FindBonusPeriod(CO.CompanyId, VM.HireDate, @BenPeriods, @PayDate) AS Period
								,dbo.FindBonusPeriodDates(CO.CompanyId, VM.HireDate, @BenPeriods, @PayDate) AS BonusPayDate
								,@DPY_WeekEndDate AS WeekEndDate
								,VS.Miles
								,VS.Drayage
								,Percentage = dbo.SafetyBonusPercentage(@Company, VM.VendorId, @BenStartDate, @GrandfatherDate, VM.HireDate, @PayDate, @BenPayRate)
						FROM	@tblDrayage VS
								INNER JOIN Companies CO ON VS.CompanyNumber = CO.CompanyNumber
								INNER JOIN @tblVendors VM ON VM.Company = CO.CompanyId AND (VM.VendorId = VS.DriverId OR VM.OldDriverId = VS.DriverId)
								LEFT JOIN SafetyBonus SF ON CO.CompanyId = SF.Company AND VM.VendorId = SF.VendorId AND SF.Period = dbo.FindBonusPeriod(CO.CompanyId, VM.HireDate, @BenPeriods, @DPY_WeekEndDate + 5)
						WHERE	VM.Company = @Company
								--AND VM.TerminationDate IS Null
								AND (VS.Miles + VS.Drayage) <> 0

					--PRINT '---> CALCULATING THE SAFETY BONUS INFORMATION'
		
					SELECT	Company
							,VendorId
							,OldDriverId
							,VendorName
							,HireDate
							,Period
							,PayDate
							,BonusPayDate
							,Miles
							,Drayage
							,ToPay
							,PeriodMiles
							,PeriodMiles * Percentage AS PeriodPay
							,0 AS PeriodToPay
							,DrayageBonus
							,SortColumn
							,WeeksCounter
							,Percentage
					INTO	#TempBonus
					FROM	(
							SELECT	Company
									,VendorId
									,OldDriverId
									,VendorName
									,HireDate
									,Period
									,PayDate
									,BonusPayDate
									,Miles
									,Miles * Percentage AS ToPay
									,Drayage
									,PeriodMiles = Miles
									,PeriodToPay = Miles * Percentage
									,DrayageBonus = Drayage * Percentage
									,1 AS SortColumn
									,0 AS WeeksCounter
									,Percentage
							FROM	#tmpRecords RECS
							) DATA
					ORDER BY
							BonusPayDate 
							,VendorId
							,Period
							,SortColumn
							,PayDate DESC

					IF @ShowData = 1
						SELECT	Company
								,VendorId
								,OldDriverId
								,VendorName
								,HireDate
								,Period
								,PayDate
								,BonusPayDate
								,Miles
								,Drayage
								,ToPay
								,PeriodMiles
								,PeriodMiles * Percentage AS PeriodPay
								,0 AS PeriodToPay
								,DrayageBonus
								,SortColumn
								,WeeksCounter
								,Percentage
						FROM	(
								SELECT	Company
										,VendorId
										,OldDriverId
										,VendorName
										,HireDate
										,Period
										,PayDate
										,BonusPayDate
										,Miles
										,Miles * Percentage AS ToPay
										,Drayage
										,PeriodMiles = Miles
										,PeriodToPay = Miles * Percentage
										,DrayageBonus = Drayage * Percentage
										,1 AS SortColumn
										,0 AS WeeksCounter
										,Percentage
								FROM	#tmpRecords RECS
								) DATA
						ORDER BY
								BonusPayDate 
								,VendorId
								,Period
								,SortColumn
								,PayDate DESC

					--PRINT '---> SAVING THE INFORMATION'

					IF @ShowData = 1
						SELECT	VendorId
								,OldDriverId
								,VendorName
								,HireDate
								,Period
								,PayDate
								,BonusPayDate
								,Miles
								,Drayage
								,ToPay
								,PeriodMiles
								,PeriodPay
								,PeriodToPay
								,DrayageBonus
								,SortColumn
								,WeeksCounter
								,Percentage
						FROM	#TempBonus
						WHERE	@DriverId IS Null 
								OR (@DriverId IS NOT Null AND (VendorId = @DriverId OR OldDriverId = @DriverId))
		
					DECLARE Records CURSOR LOCAL KEYSET OPTIMISTIC FOR
					SELECT	DISTINCT VendorId
							,OldDriverId
							,VendorName
							,HireDate
							,Period
							,PayDate
							,BonusPayDate
							,Miles
							,Drayage
							,ToPay
							,PeriodMiles
							,PeriodPay
							,PeriodToPay
							,DrayageBonus
							,SortColumn
							,WeeksCounter
							,Percentage
					FROM	#TempBonus
					WHERE	@DriverId IS Null 
							OR (@DriverId IS NOT Null AND (VendorId = @DriverId OR OldDriverId = @DriverId))

					OPEN Records 
					FETCH FROM Records INTO @VendorId, @OldDriverId, @VendorName, @HireDate, @Period, @PayDate, @BonusPayDate,
											   @Miles, @Drayage, @ToPay, @PeriodMiles, @PeriodPay, @PeriodToPay, @DrayageBonus, @SortColumn, @WeeksCounter, @Percentage

					--BEGIN TRANSACTION

					WHILE @@FETCH_STATUS = 0 
					BEGIN
						DELETE SafetyBonus WHERE Company = @Company AND PayDate = @PayDate AND VendorId = @VendorId

						EXECUTE USP_SafetyBonus_Saving @Company, @VendorId, @OldDriverId, @VendorName, @HireDate, @Period, @PayDate, @BonusPayDate,
												@Miles, @ToPay, @PeriodMiles, @PeriodPay, @PeriodToPay, @SortColumn, @WeeksCounter, @RunDate, @Percentage, @Drayage, @DrayageBonus

						EXECUTE USP_RecalculateSafetyBonusByDriver @Company, @VendorId
							    
						FETCH FROM Records INTO @VendorId, @OldDriverId, @VendorName, @HireDate, @Period, @PayDate, @BonusPayDate,
											   @Miles, @Drayage, @ToPay, @PeriodMiles, @PeriodPay, @PeriodToPay, @DrayageBonus, @SortColumn, @WeeksCounter, @Percentage
					END

					CLOSE Records
					DEALLOCATE Records

					--IF @@ERROR = 0
					--BEGIN
					--	COMMIT TRANSACTION
					--END
					--ELSE
					--BEGIN
					--	ROLLBACK TRANSACTION
					--END
			
				DROP TABLE #TempBonus
				DROP TABLE #tmpRecords
		END
	END TRY
	BEGIN CATCH  
		PRINT ERROR_MESSAGE()
	END CATCH
END

IF @DriverId IS Null
BEGIN
	EXECUTE USP_SafetyBonus_CheckForMissingDrivers @Company, @WeekEndingDate
END
/*
SELECT	*
FROM	SafetyBonus
WHERE	Company = 'GIS'
		AND Paid = 0
ORDER BY VendorId, Period DESC, SortColumn, PayDate DESC

UPDATE	SafetyBonus
SET		Percentage	= dbo.SafetyBonusPercentage (Company, '02/27/2011', '12/01/2012', HireDate, PayDate, 0.03),
		ToPay		= PeriodMiles * dbo.SafetyBonusPercentage(Company, '02/27/2011', '12/01/2012', HireDate, PayDate, 0.03),
		Miles		= PeriodMiles,
		PeriodPay	= PeriodMiles * dbo.SafetyBonusPercentage(Company, '02/27/2011', '12/01/2012', HireDate, PayDate, 0.03)
WHERE	Company = 'GIS'
		AND Paid = 0
		AND SortColumn > 0

DELETE	SafetyBonus
WHERE	Company = 'GIS'
		AND PAYDATE = '02/14/2013'
*/