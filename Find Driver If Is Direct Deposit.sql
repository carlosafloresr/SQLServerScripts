/*
USP_Driver_PayrollType 'AIS', '12/17/2009', 'DSDRV121709CK'
*/
ALTER PROCEDURE USP_Driver_PayrollType
		@Company	Varchar(6),
		@PayDate	DateTime,
		@BatchId	Varchar(17),
		@VendorId	Varchar(12)
AS		
DECLARE	@IsEFS		Bit
SET		@IsEFS		= CASE WHEN PATINDEX('%DD%', @BatchId) > 0 THEN 1 ELSE 0 END

IF GPCustom.dbo.WeekDay(@PayDate) < 5
	SET	@PayDate = GPCustom.dbo.DayFwdBack(@PayDate, 'N', 'Thursday')

SELECT	*
FROM	(
		SELECT	VM.VendorId
				,VM.Company
				,VM.HireDate
				,VM.TerminationDate
				,VM.SubType
				,VM.ScheduledReleaseDate
				,CASE WHEN PT.VendorId IS NOT NULL THEN CASE WHEN PATINDEX('%DD%', PT.BachNumb) > 0 THEN 1 ELSE 0 END
				WHEN EF.EFTTransferMethod IS Null THEN 0
				WHEN EF.ME_PreNote_Rejected = 1 THEN 0
				WHEN EF.ME_PreNote_Rejected = 0 AND DATEADD(dd, ME.GraceDays, EF.ME_Date_Prenote_Done) > @PayDate THEN 0
				WHEN EF.ME_PreNote_Rejected = 0 AND DATEADD(dd, ME.GraceDays, EF.ME_Date_Prenote_Done) <= @PayDate THEN 1 END AS EFS
		FROM	VendorMaster VM
				INNER JOIN AIS.dbo.PM00200 GV ON Vm.VendorId = GV.VendorId 
				INNER JOIN (SELECT MIN(Me_Priority_Code) AS Me_Priority_Code, MIN(Me_Prenote_Days) AS GraceDays FROM AIS.dbo.ME27605 WHERE Me_Prenote_Days > 0) ME ON ME.Me_Priority_Code = '01'
				INNER JOIN AIS.dbo.PM00200 PM ON VM.VendorId = PM.VendorId AND PM.VndClsId = 'DRV'
				LEFT JOIN AIS.dbo.ME27606 EF ON VM.VendorId = EF.VendorId
				LEFT JOIN ( SELECT	DISTINCT VendorId,
									BachNumb
							FROM	GPCustom.dbo.PM10300 
							WHERE	Company = @Company 
									AND	DocDate = @PayDate) PT ON VM.VendorId = PT.VendorId
		WHERE	VM.Company = @Company) RECS
	WHERE	RECS.EFS = @IsEFS

-- EXECUTE AIS.dbo.USP_DRA_Report_PayDrivers 'AIS', '12/17/2009', 'DSDRV121709DD'

/*
SELECT * FROM AIS.dbo.ME27606
SELECT * FROM AIS.dbo.ME27605
*/