USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DriverPayrollInformation]    Script Date: 5/14/2021 9:48:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DriverPayrollInformation 'AIS', 'A50155'
EXECUTE USP_DriverPayrollInformation 'GIS', 'G0124'
EXECUTE USP_DriverPayrollInformation 'IMC', '12896'
EXECUTE USP_DriverPayrollInformation 'IMC', '13135'
EXECUTE USP_DriverPayrollInformation 'NDS', 'N22209'
EXECUTE USP_DriverPayrollInformation 'HMIS', '61793'
EXECUTE USP_DriverPayrollInformation 'H&M', '60312'
*/
ALTER PROCEDURE [dbo].[USP_DriverPayrollInformation]
		@Company		Varchar(5),
		@VendorId		Varchar(12)
AS
SET NOCOUNT ON

DECLARE	@PayDate		Date,
		@WeekEnd		Date,
		@WeekEnd2		Date,
		@OnlyMain		Bit = 0,
		@CompanyId		Varchar(5),
		@CompanyNum		Int = 0,
		@Query			Varchar(2000),
		@DriverId		Varchar(12),
		@NewOOS			Bit = 0,
		@FileId			Int,
		@FileLocation	Varchar(500)

DECLARE	@tblData		Table
		(PayDate		Date Null,
		Description		Varchar(50) Null,
		Amount			Numeric(10,2) Null,
		Document		Varchar(150) Null,
		Sort			Smallint Null)

DECLARE	@tblNewOOS		Table 
		(DriverId		Varchar(12), 
		Weekendingdate	Date, 
		Income			Numeric(10,2), 
		Deductions		Numeric(10,2), 
		Payment			Numeric(10,2),
		FileId			Int Null,
		ImageFile		Varchar(1000) Null)

SET		@CompanyId	= (SELECT TOP 1 CompanyId FROM View_CompanyAgents WHERE CompanyId = @Company OR CompanyAlias = @Company)
SET		@CompanyNum	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET		@PayDate	= (SELECT MAX(DocDate) FROM GPCustom.dbo.PM10300 WHERE Company = @CompanyId AND VendorId = @VendorId) --CONVERT(Char(10), CASE WHEN DATENAME(weekday, GETDATE()) = 'Thursday' THEN GETDATE() ELSE dbo.DayFwdBack(GETDATE(), 'P', 'Thursday') END, 101)
SET		@WeekEnd	= dbo.DayFwdBack(@PayDate, 'P', 'Saturday')
SET		@NewOOS		= (SELECT IIF(NewOOSDate IS Null, 0, 1) FROM VendorMaster WHERE Company = @Company AND VendorId = @VendorId)

PRINT @CompanyNum

IF @NewOOS = 1
BEGIN
	SET @Query = N'SELECT DISTINCT HDR.driver_id, HDR.week_ending_date, HDR.payment_total, HDR.charge_total FROM OOS.driver_settlement_header HDR 
	INNER JOIN OOS.driver_settlement_status STA ON HDR.week_ending_date = STA.week_ending_date
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
				Weekendingdate	= dbo.DayFwdBack(Weekendingdate,'N','Thursday')
		WHERE	FileId			= @FileId

		FETCH FROM curFBImages INTO @FileId
	END

	CLOSE curFBImages
	DEALLOCATE curFBImages

	-- SELECT * FROM @tblNewOOS
END

INSERT INTO @tblData
	SELECT	DISTINCT @PayDate AS PayDate
			,'A/P Balance If Negative' AS 'Description'
			,ISNULL(dbo.DriverBalance(@Company, @VendorId, @PayDate), 0) AS Amount
			,Null AS Document
			,0 AS Sort
	FROM	VendorMaster
	WHERE	Company = @CompanyId
			AND VendorId = @VendorId
	UNION
	SELECT	@PayDate AS PayDate
			,AccountAlias AS 'Description'
			,ISNULL(Balance, 0) AS Amount
			,Null AS Document
			,1 AS Sort
	FROM	View_EscrowAdvanceBalances
	WHERE	CompanyId = @CompanyId
			AND VendorId = @VendorId
			AND MobileAppVisible = 1
			AND (((@OnlyMain = 1 AND Fk_EscrowModuleId <> 3) OR @OnlyMain = 0)
			OR RemittanceAdvise = 1)
	UNION
	SELECT	*
	FROM	(
			SELECT	TOP 4 DATEADD(dd, 5, WeekEndDate) AS PayDate,
					'Drayage for ' + CONVERT(Varchar, DATEADD(dd, 5, WeekEndDate), 101) AS 'Description'
					,ISNULL(Amount, 0) AS Balance
					,Null AS Document
					,2 AS Sort
			FROM	(
					SELECT	HE.Company,
							HE.BatchId,
							HE.WeekEndDate,
							SUM(DE.Drayage + DE.DriverFuelRebate) AS Amount
					FROM	Integration_APDetails DE
							INNER JOIN Integration_APHeader HE ON DE.BatchId = HE.BatchId
					WHERE	HE.Company = @CompanyId
							AND DE.VendorId = @VendorId
					GROUP BY HE.Company,
							HE.BatchId,
							HE.WeekEndDate
					) DATA
			ORDER BY WeekEndDate DESC
			) DATA

INSERT INTO @tblData
	SELECT	TOP 4 *
			,4 AS Sort
	FROM	(
			SELECT	OOS.Weekendingdate AS WeekEndingDate
					,'Remittance Advise ' + CONVERT(Varchar, OOS.WeekEndingDate, 101) AS 'Description'
					,OOS.[Payment] AS Amount
					,OOS.ImageFile AS Document
			FROM	@tblNewOOS OOS
			UNION
			SELECT	DISTINCT CAST(DD.WeekEndingDate AS Date) AS WeekEndingDate
					,'Remittance Advise ' + CONVERT(Varchar, DD.WeekEndingDate, 101) AS 'Description'
					,ISNULL(PM.ChekTotl, 0.0) AS Amount
					,DD.DocumentName AS Document
			FROM	View_DriverDocuments DD
					LEFT JOIN PM10300 PM ON DD.VendorId = PM.VendorId AND PM.DocDate BETWEEN dbo.DayFwdBack(DD.WeekEndingDate, 'P', 'Monday') AND DD.WeekEndingDate
			WHERE	DD.Fk_DocumentTypeId = 1 
					AND DD.Company = @CompanyId
					AND DD.VendorId = @VendorId
					AND DD.WeekEndingDate > DATEADD(dd, -40, GETDATE())
			) RECS
	WHERE	Amount IS NOT Null
	ORDER BY 5, 1 DESC

UPDATE	@tblData
SET		[@tblData].Amount = DATA.Amount
FROM	(
		SELECT	*
		FROM	@tblData
		WHERE	Description LIKE '%Drayage for%'
		) DATA
WHERE	[@tblData].Description LIKE '%Remittance Advise%'
		AND REPLACE([@tblData].Description, 'Remittance Advise ', '') = REPLACE(DATA.Description, 'Drayage for ', '')
		AND [@tblData].Document NOT LIKE '%/TempFiles%'

SELECT	*
FROM	@tblData
ORDER BY 5, 1 DESC