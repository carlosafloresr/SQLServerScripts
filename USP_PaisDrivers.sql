ALTER PROCEDURE USP_PaisDrivers
		@Company	Varchar(6),
		@WeekDate	Datetime,
		@BatchId	Varchar(17) = Null,
		@VendorId	Varchar(12) = Null
AS
IF GPCustom.dbo.WeekDay(@WeekDate) < 5
	SET	@WeekDate = GPCustom.dbo.DayFwdBack(@WeekDate,'N','Thursday')

SELECT	DISTINCT VendorId
		,VendName
		,BatchId 
FROM	DrvReps_RemittanceAdvise 
WHERE	CompanyId = @Company
		AND WeekEndDate = @WeekDate
		AND BatchId <> ''
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BatchId = @BatchId))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
ORDER BY BatchId, VendorId