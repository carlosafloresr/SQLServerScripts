USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DRA_Report]    Script Date: 12/9/2015 1:11:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DRA_Report 'DNJ','DSDR082318DD', Null, 1
EXECUTE USP_DRA_Report 'DNJ','DSDR082318DD', 'D0397'
EXECUTE USP_DRA_Report 'AIS','DSDR082318DD', Null, 1
*/
ALTER PROCEDURE [dbo].[USP_DRA_Report] -- DRA = Driver Remittance Advice
		@Company		Varchar(6),
		@BatchId		Varchar(17),
		@DriverId		Varchar(15) = Null,
		@CreateRecords	Bit = 0
AS
DECLARE	@Query	Varchar(Max)

IF @CreateRecords = 0
BEGIN
	IF EXISTS(SELECT TOP 1 BatchId FROM OOS_RemittanceAdvice WHERE CompanyId = @Company AND BatchId = @BatchId AND (@DriverId IS Null OR VendorId = @DriverId))
		SELECT	*
		FROM	OOS_RemittanceAdvice 
		WHERE	CompanyId = @Company 
				AND BatchId = @BatchId
				AND (@DriverId IS Null OR VendorId = @DriverId)
		ORDER BY 
				VendorId
				,WeekEndDate
				,TransDate
				,DeductionCode
				,DeductionType
	ELSE
	BEGIN
		SET	@Query = RTRIM(@Company) + '.dbo.USP_DRA_Report ''' + RTRIM(@Company) + ''', ''' + @BatchId + ''''

		IF @DriverId IS NOT NULL AND @DriverId <> ''
			SET @Query = @Query + ',''' + RTRIM(@DriverId) + ''''

		EXECUTE(@Query)
	END
END
ELSE
BEGIN
	SET	@Query = RTRIM(@Company) + '.dbo.USP_DRA_Report_CreateData ''' + RTRIM(@Company) + ''', ''' + @BatchId + ''''

	IF @DriverId IS NOT NULL AND @DriverId <> ''
		SET @Query = @Query + ',''' + RTRIM(@DriverId) + ''''

	EXECUTE(@Query)
END