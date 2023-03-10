/*
USP_Driver_PayrollType 'IMC', '05/17/2018',null, null, 1, 'CFLORES'
USP_Driver_PayrollType 'OIS', '11/18/2021', 'DSDR120315CK', Null, 0, 'CFLORES'
USP_Driver_PayrollType 'AIS', '11/01/2018', 'DSDR110118DD', Null, 0, 'CFLORES'
USP_Driver_PayrollType 'NDS', '12/22/2009', null, 'A0363'
USP_Driver_PayrollType 'DNJ', '11/08/2018', null, 'A0346'

GRANT EXECUTE ON [USP_Driver_PayrollType] TO DYNGRP
*/
ALTER PROCEDURE [dbo].[USP_Driver_PayrollType]
		@Company	Varchar(6),
		@WeekDate	DateTime,
		@BatchId	Varchar(17) = Null,
		@VendorId	Varchar(12) = Null,
		@CreateTemp	Bit = 0,
		@UserId		Varchar(25) = Null
AS		
DECLARE	@IsEFT		Bit,
		@BatchCK	Varchar(15),
		@BatchDD	Varchar(15),
		@StartDate	DateTime

SET		@IsEFT		= CASE WHEN PATINDEX('%DD%', @BatchId) > 0 THEN 1 ELSE 0 END
SET		@StartDate	= GPCustom.dbo.DayFwdBack(@WeekDate, 'P', 'Monday')

IF GPCustom.dbo.WeekDay(@WeekDate) < 5
	SET	@WeekDate = GPCustom.dbo.DayFwdBack(@WeekDate, 'N', 'Thursday')

IF EXISTS(SELECT TOP 1 BachNumb FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND DocDate BETWEEN @StartDate AND @WeekDate)
BEGIN
	SET	@BatchCK = RTRIM((SELECT TOP 1 BachNumb FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND DocDate BETWEEN @StartDate AND @WeekDate AND PATINDEX('%CK%', BachNumb) > 0 AND LEFT(BachNumb, 4) = 'DSDR'))
	SET	@BatchDD = RTRIM((SELECT TOP 1 BachNumb FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND DocDate BETWEEN @StartDate AND @WeekDate AND PATINDEX('%DD%', BachNumb) > 0 AND LEFT(BachNumb, 4) = 'DSDR'))
END
PRINT @BatchCK + ' / ' + @BatchDD

DECLARE	@tblDriverBalance Table (
		VendorId		Varchar(15),
		Balance			Numeric(10,2) Null)

DECLARE	@tblPaidDrivers Table (VendorId Varchar(20), BachNumb Varchar(30))

INSERT INTO @tblPaidDrivers
SELECT	DISTINCT VendorId,
		BachNumb
FROM	GPCustom.dbo.PM10300 
WHERE	Company = @Company 
		AND	DocDate BETWEEN @StartDate AND @WeekDate
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BachNumb = @BatchId))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))

INSERT INTO @tblDriverBalance
SELECT	VendorId
		,ISNULL(SUM(Amount - ApplyTo), 0) AS Balance
FROM	(
			SELECT	PM1.VendorId
					,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
					,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM PM30300 PM2 WHERE PM2.GLPostDt <= @WeekDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
			FROM	PM20000 PM1
			WHERE	PM1.PostEddt <= @WeekDate
					AND (@VendorId IS Null 
					OR (@VendorId IS NOT Null AND PM1.VendorId = @VendorId))
		) TRN
GROUP BY VendorId

IF @CreateTemp = 1
BEGIN
	DELETE	GPCustom.dbo.OOS_PayrollDrivers 
	WHERE	Company = @Company AND UserId = @UserId 
	
	INSERT INTO GPCustom.dbo.OOS_PayrollDrivers
	SELECT	DISTINCT Company
			,VendorId
			,VendName
			,PayToName
			,HireDate
			,TerminationDate
			,SubType
			,ScheduledReleaseDate
			,Balance
			,EFT
			,BatchId
			,@WeekDate AS WeekEndDate
			,@UserId AS UserId
			,Division
	FROM	(
			SELECT	VM.Company
					,VM.VendorId
					,GPCustom.dbo.PROPER(REPLACE(UPPER(GV.VendName), 'TERM','')) AS VendName
					,GPCustom.dbo.PROPER(GV.VndChkNm) AS PayToName
					,VM.HireDate
					,VM.TerminationDate
					,VM.SubType
					,VM.ScheduledReleaseDate
					,ISNULL(BA.Balance,0) AS Balance
					,CASE WHEN PT.VendorId IS NOT NULL THEN CASE WHEN PATINDEX('%DD%', PT.BachNumb) > 0 THEN 1 ELSE 0 END
					WHEN EF.EFTTransferMethod IS Null THEN 0
					WHEN EF.EFTTerminationDate > '1/1/1900' THEN 0
					WHEN EF.Inactive = 1 THEN 0
					WHEN DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) > @WeekDate AND EF.Inactive = 0 THEN 0
					WHEN DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) <= @WeekDate AND EF.Inactive = 0 THEN 1 END AS EFT
					,CASE WHEN @BatchId IS Null AND PT.BachNumb IS NOT Null THEN BachNumb
					WHEN PT.BachNumb IS Null AND DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) > @WeekDate AND EF.Inactive = 00 THEN @BatchCK 
					WHEN PT.BachNumb IS Null AND DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) <= @WeekDate AND EF.Inactive = 0 THEN @BatchDD 
					ELSE PT.BachNumb END AS BatchId
					,VM.Division
			FROM	GPCustom.dbo.VendorMaster VM
					INNER JOIN PM00200 GV ON Vm.VendorId = GV.VendorId 
					INNER JOIN PM00200 PM ON VM.VendorId = PM.VendorId AND PM.VndClsId = 'DRV'
					LEFT JOIN @tblDriverBalance BA ON VM.VendorId = BA.VendorId
					LEFT JOIN (SELECT MIN(EFTPriorityCode) AS Me_Priority_Code, MIN(EFTPMPrenoteGracePeriod) AS GraceDays FROM CM00101 WHERE EFTPMPrenoteGracePeriod > 0) ME ON ME.Me_Priority_Code = '01'
					LEFT JOIN SY06000 EF ON VM.VendorId = EF.VendorId
					LEFT JOIN @tblPaidDrivers PT ON VM.VendorId = PT.VendorId
			WHERE	VM.Company = @Company
					AND (VM.NewOOSDate IS Null OR VM.NewOOSDate > @WeekDate)
					AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VM.VendorId = @VendorId))
			) RECS
	WHERE	(@BatchId IS Null OR (@BatchId IS NOT Null AND RECS.EFT = @IsEFT))
			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
	ORDER BY VendorId
END
ELSE
BEGIN
	SELECT	Company
			,VendorId
			,VendName
			,PayToName
			,HireDate
			,TerminationDate
			,SubType
			,ScheduledReleaseDate
			,Balance
			,EFT
			,BatchId
			,@WeekDate AS WeekEndDate
			,@UserId AS UserId
			,Division
	FROM	(
				SELECT	VM.Company
						,VM.VendorId
						,GPCustom.dbo.PROPER(REPLACE(UPPER(GV.VendName), 'TERM','')) AS VendName
						,GPCustom.dbo.PROPER(GV.VndChkNm) AS PayToName
						,VM.HireDate
						,VM.TerminationDate
						,VM.SubType
						,VM.ScheduledReleaseDate
						,ISNULL(BA.Balance,0) AS Balance
						,CASE WHEN PT.VendorId IS NOT NULL THEN CASE WHEN PATINDEX('%DD%', PT.BachNumb) > 0 THEN 1 ELSE 0 END
						WHEN EF.EFTTransferMethod IS Null THEN 0
						WHEN EF.EFTTerminationDate > '1/1/1900' THEN 0
						WHEN EF.Inactive = 1 THEN 0
						WHEN DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) > @WeekDate AND EF.Inactive = 0 THEN 0
						WHEN DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) <= @WeekDate AND EF.Inactive = 0 THEN 1 END AS EFT
						,CASE WHEN @BatchId IS Null AND PT.BachNumb IS NOT Null THEN BachNumb
						WHEN PT.BachNumb IS Null AND DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) > @WeekDate AND EF.Inactive = 00 THEN @BatchCK 
						WHEN PT.BachNumb IS Null AND DATEADD(dd, ISNULL(ME.GraceDays, 0), EF.EFTPrenoteDate) <= @WeekDate AND EF.Inactive = 0 THEN @BatchDD 
						ELSE PT.BachNumb END AS BatchId
						,VM.Division
				FROM	GPCustom.dbo.VendorMaster VM
						INNER JOIN PM00200 GV ON VM.VendorId = GV.VendorId 
						INNER JOIN PM00200 PM ON VM.VendorId = PM.VendorId AND PM.VndClsId = 'DRV'
						LEFT JOIN @tblDriverBalance BA ON VM.VendorId = BA.VendorId
						LEFT JOIN (SELECT MIN(EFTPriorityCode) AS Me_Priority_Code, MIN(EFTPMPrenoteGracePeriod) AS GraceDays FROM CM00101 WHERE EFTPMPrenoteGracePeriod > 0) ME ON ME.Me_Priority_Code = '01'
						LEFT JOIN SY06000 EF ON VM.VendorId = EF.VendorId
						LEFT JOIN @tblPaidDrivers PT ON VM.VendorId = PT.VendorId
				WHERE	VM.Company = @Company
						AND (VM.NewOOSDate IS Null OR VM.NewOOSDate > @WeekDate)
						AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VM.VendorId = @VendorId))
			) RECS
	WHERE	(@BatchId IS Null OR (@BatchId IS NOT Null AND RECS.EFT = @IsEFT))
			AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
	ORDER BY VendorId
END