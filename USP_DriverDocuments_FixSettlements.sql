/*
EXECUTE USP_DriverDocuments_FixSettlements 'DNJ', '10/31/2019', 'DSDR103119DD'
*/
ALTER PROCEDURE USP_DriverDocuments_FixSettlements
		@Company		Varchar(5),
		@WeekEndingdate	Date,
		@BatchId		Varchar(25)
AS
DECLARE @tblData		Table (
		VendorId		Varchar(10),
		VendName		Varchar(50),
		Division		Char(2),
		Agent			Char(2) Null,
		PaidByPayCard	Bit)

SET NOCOUNT ON

INSERT INTO @tblData
EXECUTE ILS_Datawarehouse.dbo.USP_PaidDrivers @Company, @WeekEndingdate, @BatchId, Null, 0, NULL, 'FIXPROCESS'

UPDATE	DriverDocuments
SET		BatchId = @BatchId
FROM	(
		SELECT	*
		FROM	@tblData
		) DATA
WHERE	DriverDocuments.Company = @Company
		AND DriverDocuments.WeekEndingDate = @WeekEndingdate
		AND DriverDocuments.VendorId = DATA.VendorId

/*
SELECT	*
FROM	[GPCustom].[dbo].[DriverDocuments]
WHERE	Company = 'DNJ'
		AND WeekEndingDate = '10/31/2019'
		AND VendorId = 'A51188'
*/