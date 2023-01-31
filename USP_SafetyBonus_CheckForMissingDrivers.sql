/*
EXECUTE USP_SafetyBonus_CheckForMissingDrivers 'AIS', '10/06/2022', 1
*/
ALTER PROCEDURE USP_SafetyBonus_CheckForMissingDrivers
		@Company			Varchar(5),
		@WeekEndingDate		Date,
		@CalculateAll		Bit = 0
AS
SET NOCOUNT ON

DECLARE @SWSQuery			Varchar(MAX),
		@PayTypes			Varchar(50),
		@CompanyNumber		Int,
		@DPY_WeekEndDate	Date,
		@DriverId			Varchar(15),
		@Drayage			Numeric(10,2),
		@Miles				Int

DECLARE	@tblDrayage			Table (
		CompanyNumber		Smallint,
		DriverId			Varchar(12),
		Drayage				Numeric(10,2),
		Miles				Int)

SET @DPY_WeekEndDate = DATEADD(dd, -5, @WeekEndingDate)

SELECT	@CompanyNumber = CompanyNumber
FROM	Companies
WHERE	CompanyId = @Company

SELECT	@PayTypes = PayTypes
FROM	SafetyBonusParameters
WHERE	Company = @Company

IF @CalculateAll = 1
BEGIN
	DELETE SafetyBonus WHERE Company = @Company AND PayDate = @WeekEndingDate
END

SET @SWSQuery = 'SELECT * FROM (SELECT cmpy_no AS CompanyNumber, dr_code AS DriverId, SUM(payamt)::numeric(12,2) AS Drayage, SUM(paymiles)::numeric(9,0) AS Miles FROM Trk.DrPay WHERE cmpy_no = ' + CAST(@CompanyNumber AS Char(1)) + ' AND paytype IN (''' + REPLACE(@PayTypes, ',', ''',''') + ''') AND wkpdate = ''' + CONVERT(char(10), @DPY_WeekEndDate, 101) + ''' GROUP BY cmpy_no, dr_code) DATA WHERE Drayage <> 0'

INSERT INTO @tblDrayage
EXECUTE USP_QuerySWS_ReportData @SWSQuery

DECLARE curSWSDrayage CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT * FROM @tblDrayage

OPEN curSWSDrayage 
FETCH FROM curSWSDrayage INTO @CompanyNumber, @DriverId, @Drayage, @Miles

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 PayDate FROM GPCustom.dbo.SafetyBonus WHERE Company = @Company AND VendorId = @DriverId AND PayDate = @WeekEndingDate AND SortColumn = 1)
	BEGIN
		EXECUTE USP_CalculateSafetyBonusTable @Company, @WeekEndingDate, @DriverId, 0
	END

	FETCH FROM curSWSDrayage INTO @CompanyNumber, @DriverId, @Drayage, @Miles
END

CLOSE curSWSDrayage
DEALLOCATE curSWSDrayage

DECLARE curSWSDrayage CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT DriverId FROM @tblDrayage

OPEN curSWSDrayage 
FETCH FROM curSWSDrayage INTO @DriverId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_RecalculateSafetyBonusByDriver @Company, @DriverId

	FETCH FROM curSWSDrayage INTO @DriverId
END

CLOSE curSWSDrayage
DEALLOCATE curSWSDrayage