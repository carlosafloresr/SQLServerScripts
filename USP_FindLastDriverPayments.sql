USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindLastDriverPayments]    Script Date: 5/14/2021 10:40:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindLastDriverPayments 'AIS', 'A50155'
*/
ALTER PROCEDURE [dbo].[USP_FindLastDriverPayments]
	@Company	Varchar(5),
	@VendorId	Varchar(12)
AS
DECLARE	@CompanyNum		Int = 0,
		@Query			Varchar(2000),
		@DriverId		Varchar(12),
		@NewOOS			Bit = 0,
		@FileId			Int,
		@FileLocation	Varchar(500)

DECLARE	@tblNewOOS		Table 
		(DriverId		Varchar(12), 
		Weekendingdate	Date, 
		Income			Numeric(10,2), 
		Deductions		Numeric(10,2), 
		Payment			Numeric(10,2),
		FileId			Int Null,
		ImageFile		Varchar(1000) Null)

SET		@CompanyNum	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET		@NewOOS		= (SELECT IIF(NewOOSDate IS Null, 0, 1) FROM VendorMaster WHERE Company = @Company AND VendorId = @VendorId)

IF @NewOOS = 1
BEGIN
	SET @Query = N'SELECT DISTINCT HDR.driver_id, HDR.week_ending_date, HDR.payment_total, HDR.charge_total FROM OOS.driver_settlement_header HDR 
	INNER JOIN oos.driver_settlement_status STA ON HDR.week_ending_date = STA.week_ending_date
	WHERE HDR.company_id = ' + CAST(@CompanyNum AS Varchar) + ' 
		AND HDR.driver_id = ''' + RTRIM(@VendorId) + ''' AND STA.status =''Submitted To GP - APPROVED'' 
	ORDER BY HDR.week_ending_date DESC
	LIMIT 4'

	INSERT INTO @tblNewOOS (DriverId, Weekendingdate, Income, Deductions)
	EXECUTE USP_QuerySWS_ReportData @Query, Null, 'POSTGRESQL_IMC_ENTERPRISE'

	UPDATE	@tblNewOOS
	SET		FileId		= DATA.File_Id
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
	SELECT	DISTINCT FileId
	FROM	@tblNewOOS
	WHERE	FileId IS NOT Null

	OPEN curFBImages 
	FETCH FROM curFBImages INTO @FileId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXECUTE dbo.USP_FileBoundFileRequest 165, @FileId, @FileLocation OUT, 1

		UPDATE	@tblNewOOS
		SET		Payment			= (Income - Deductions),
				ImageFile		= @FileLocation,
				Weekendingdate	= DATEADD(dd, 5, Weekendingdate)
		WHERE	FileId			= @FileId

		FETCH FROM curFBImages INTO @FileId
	END

	CLOSE curFBImages
	DEALLOCATE curFBImages
END

SELECT	TOP 4 *
FROM	(
		SELECT	OOS.Weekendingdate AS WeekEndingDate
				,OOS.ImageFile AS DocumentName
				,OOS.[Payment] AS Amount
		FROM	@tblNewOOS OOS
		UNION
		SELECT	DISTINCT DD.WeekEndingDate
				,DD.DocumentName
				,ISNULL(PM.ChekTotl, 0.0) AS Amount
		FROM	View_DriverDocuments DD
				LEFT JOIN PM10300 PM ON DD.VendorId = PM.VendorId AND PM.DocDate BETWEEN dbo.DayFwdBack(DD.WeekEndingDate, 'P', 'Monday') AND DD.WeekEndingDate
		WHERE	DD.Fk_DocumentTypeId = 1 
				AND DD.Company = RTRIM(@Company)
				AND DD.VendorId = RTRIM(@VendorId)
				AND DD.WeekEndingDate > DATEADD(dd, -40, GETDATE())
		) RECS
WHERE	Amount IS NOT Null
ORDER BY WeekEndingDate DESC