DECLARE @Query			Varchar(2000),
		@DriverId		Varchar(12) = 'A50155',
		@FileId			Int,
		@FileLocation	Varchar(500)

DECLARE	@tblNewOOS		Table 
		(DriverId		Varchar(12), 
		Weekendingdate	Date, 
		Payment			Numeric(10,2), 
		Deductions		Numeric(10,2), 
		FileId			Int Null,
		ImageFile		Varchar(1000) Null)

-- SELECT * FROM OPENQUERY(POSTGRESQL_IMC_ENTERPRISE, 'SELECT * FROM oos.driver_settlement_header') AS derivedtbl_1

SET @Query = N'SELECT HDR.driver_id, HDR.week_ending_date, HDR.payment_total, HDR.charge_total FROM oos.driver_settlement_header HDR 
INNER JOIN oos.driver_settlement_status STA ON HDR.week_ending_date = STA.week_ending_date
WHERE HDR.driver_id = ''' + RTRIM(@DriverId) + ''' AND STA.status =''Submitted To GP - APPROVED'' 
ORDER BY HDR.week_ending_date DESC
LIMIT 4'

INSERT INTO @tblNewOOS (DriverId, Weekendingdate, Payment, Deductions)
EXECUTE USP_QuerySWS_ReportData @Query, Null, 'POSTGRESQL_IMC_ENTERPRISE'

UPDATE	@tblNewOOS
SET		FileId = DATA.File_Id
FROM	(
		SELECT	OOS.DriverId AS Driver_Id,
				OOS.Weekendingdate AS WE_Date,
				FBN.FileId AS File_Id
		FROM	@tblNewOOS OOS
				INNER JOIN (SELECT	FileId, Field2, Field4
							FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEXVIEW
							WHERE	DEXVIEW.ProjectId = 165
									AND	DEXVIEW.Field5 = 'REMITTANCE'
							) FBN ON OOS.DriverId = FBN.Field2 AND OOS.Weekendingdate = FBN.Field4
		) DATA
WHERE	Driver_Id = DATA.Driver_Id
		AND Weekendingdate = DATA.WE_Date

DECLARE curFBImages CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	FileId
FROM	@tblNewOOS
WHERE	FileId IS NOT Null

OPEN curFBImages 
FETCH FROM curFBImages INTO @FileId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_FileBoundFileRequest 165, @FileId, @FileLocation OUT, 1

	UPDATE	@tblNewOOS
	SET		ImageFile = @FileLocation
	WHERE	FileId = @FileId

	FETCH FROM curFBImages INTO @FileId
END

CLOSE curFBImages
DEALLOCATE curFBImages

SELECT	OOS.*,
		DATEADD(dd, 5, OOS.Weekendingdate) AS PayDate
FROM	@tblNewOOS OOS

-- SELECT * FROM VendorMaster WHERE NewOOSDate IS NOT Null