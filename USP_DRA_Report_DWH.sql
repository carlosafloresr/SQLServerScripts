/*
EXECUTE USP_DRA_Report_DWH 'OIS','DSDR111821CK', 1
EXECUTE USP_DRA_Report_DWH 'IMC','DSDR061121DD',1
EXECUTE USP_DRA_Report_DWH 'PTS','DSDR103117DD',1
EXECUTE USP_DRA_Report_DWH 'AIS','DSDR112521CK', 1
*/
ALTER PROCEDURE [dbo].[USP_DRA_Report_DWH]
		@Company	Varchar(6),
		@BatchId	Varchar(17),
		@Rebuild	Bit = 0
AS
SET NOCOUNT ON
SET DEADLOCK_PRIORITY HIGH

UPDATE	GPCustom.dbo.VendorMaster 
SET		NewOOSDate = NULL
WHERE	Company = @Company
		AND TerminationDate IS NOT NULL 
		AND NewOOSDate IS NOT NULL

DECLARE	@Year		Int,
		@Week		Int,
		@CpnyName	Varchar(40),
		@Query		Varchar(5000),
		@Driver		Varchar(10),
		@WeekEnd	Datetime,
		@WEndDate	Datetime,
		@CutoffDate Datetime,
		@IsEFT		Int,
		@DriverId	Varchar(10),
		@UserId		Varchar(25)

PRINT '1: Definig Variables ' + CONVERT(Varchar, GETDATE(), 109)

SET		@IsEFT		= (CASE WHEN PATINDEX('%DD%', @BatchId) > 0 THEN 1 ELSE 0 END)
SET		@WeekEnd	= (SELECT MAX(DocDate) FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND BachNumb = @BatchId)

SET		@CpnyName	= (SELECT TOP 1 CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE Interid = @Company)
SET		@WEndDate	= (CASE	WHEN GPCustom.dbo.WeekDay(@WeekEnd) < 5 THEN @WeekEnd + (5 - GPCustom.dbo.WeekDay(@WeekEnd))
							WHEN GPCustom.dbo.WeekDay(@WeekEnd) = 5 THEN @WeekEnd
							ELSE @WeekEnd + (12 - GPCustom.dbo.WeekDay(@WeekEnd)) END)
SET		@Year		= YEAR(@WEndDate)
SET		@Week		= DATENAME(Week, @WEndDate)
SET		@CutoffDate = @WeekEnd
SET		@BatchId	= RTRIM(@BatchId)
SET		@UserId		= @BatchId + '_' + REPLACE(CONVERT(Char(10), GETDATE(), 102), '.', '') + RTRIM(REPLACE(CONVERT(Char(6), GETDATE(), 108), ':', ''))

IF @Rebuild = 1
BEGIN
	DELETE	ILS_Datawarehouse.dbo.DrvReps_RemittanceAdvise 
	WHERE	CompanyId = @Company 
			AND BatchId = @BatchId
END

PRINT '2: Selecting Batch Drivers ' + CONVERT(Varchar, GETDATE(), 109)

DECLARE	@tblPaidDrivers Table (VendorId Varchar(20))

INSERT INTO @tblPaidDrivers
SELECT	VendorId 
FROM	GPCustom.dbo.PM10300 PH
WHERE	PH.Company = @Company AND
		PH.BACHNUMB = @BatchId AND
		PH.ChekTotl > 0 AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId))

PRINT '3: Identyfing Driver Payroll Type ' + CONVERT(Varchar, GETDATE(), 109)

EXECUTE USP_Driver_PayrollType @Company, @WEndDate, @BatchId, @DriverId, 1, @UserId

SELECT	VendorId
		,SubType
		,EFT 
		,TerminationDate
INTO	#VednorMaster
FROM	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = @UserId
		
DELETE	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = @UserId

PRINT '4: Selecting Data ' + CONVERT(Varchar, GETDATE(), 109)

INSERT INTO ILS_Datawarehouse.dbo.DrvReps_RemittanceAdvise
		(CompanyId
		,Company
		,WeekEndDate
		,TransDate
		,[Week]
		,VendorId
		,VendName
		,DeductionCode
		,DeductionType
		,DeductionAmount
		,ChekTotl
		,ApFvchNm
		,DocNumbr
		,AmntPaid
		,CheckDate
		,PostingDate
		,EFT
		,BatchId
		,SortWeek
		,HireDate
		,TerminationDate)
SELECT	@Company AS CompanyId,
		RA.*,
		VM.HireDate,
		VM.TerminationDate
FROM	(
SELECT	* ,
		CONVERT(Char(10), WeekEndDate, 102) + '_1' AS SortWeek
FROM	(
SELECT	@CpnyName AS Company,
		CASE	WHEN GPCustom.dbo.WeekDay(PD.DocDate) < 5 THEN PD.DocDate + (5 - GPCustom.dbo.WeekDay(PD.DocDate))
				WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PD.DocDate
				WHEN LEFT(PD.VchrNmbr, 3) = 'FPT' THEN PD.DocDate + (12 - GPCustom.dbo.WeekDay(PD.DocDate))
				ELSE PD.DocDate + (12 - GPCustom.dbo.WeekDay(PD.DocDate)) END AS WeekEndDate,
		PD.DocDate AS TransDate,
		DATENAME(Week, PD.DocDate) AS Week,
		PH.VendorId,
		PH.VendName,
		CASE	WHEN LEFT(PD.ApFvchNm, 3) = 'DPY' THEN '1-0'
				WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN '2-0'
				WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN '2-0'
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN '3-0'
		ELSE '3-1' END AS DeductionCode,
		CASE	WHEN LEFT(PD.ApFvchNm, 3) = 'DPY' THEN 'Drayage'
				WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN 'Fuel Purchases'
				WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN 'Interest Paid ' + IIF(GPCustom.dbo.AT('_', PD.ApFvchNm, 2) > 0, SUBSTRING(PD.ApFvchNm, GPCustom.dbo.AT('_', PD.ApFvchNm, 2) + 1, 6), PD.ApFvchNm)
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = PH.Company AND PATINDEX('%' + LTRIM(RTRIM(DeductionCode)) + '%', PD.DocNumbr) > 0)
		ELSE PD.DocNumbr END AS DeductionType,
		PD.Outstanding_Amount AS DeductionAmount,
		PH.ChekTotl,
		PD.ApFvchNm,
		CASE WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN 'Interest Paid ' + IIF(GPCustom.dbo.AT('_', PD.ApFvchNm, 2) > 0, SUBSTRING(PD.ApFvchNm, GPCustom.dbo.AT('_', PD.ApFvchNm, 2) + 1, 6), PD.ApFvchNm) ELSE PD.DocNumbr END AS DocNumbr,
		PD.AmntPaid,
		PH.DocDate AS CheckDate,
		PH.PstgDate AS PostingDate,
		VM.EFT,
		@BatchId AS BatchId
FROM	GPCustom.dbo.PM10300 PH 
		INNER JOIN #VednorMaster VM ON PH.VendorId = VM.VendorId
		INNER JOIN GPCustom.dbo.PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr AND PH.Company = PD.Company
WHERE	PH.Company = @Company AND
		PH.BachNumb = @BatchId AND
		PH.ChekTotl > 0
		AND VM.EFT = @IsEFT
UNION
SELECT	@CpnyName AS Company,
		CASE	WHEN GPCustom.dbo.WeekDay(TB.DocDate) < 5 THEN TB.DocDate + (5 - GPCustom.dbo.WeekDay(TB.DocDate))
				WHEN GPCustom.dbo.WeekDay(TB.DocDate) = 5 THEN TB.DocDate
				WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN TB.DocDate + (12 - GPCustom.dbo.WeekDay(TB.DocDate))
				ELSE TB.DocDate + (12 - GPCustom.dbo.WeekDay(TB.DocDate)) END AS WeekEndDate,
		TB.DocDate AS TransDate,
		@Week AS Week,
		TB.VendorId,
		VE.VendName,
		CASE	WHEN LEFT(TB.VchrNmbr, 3) = 'DPY' THEN '1-0'
				WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN '2-0'
				WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN '2-0'
				WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN '3-0'
		ELSE '3-1' END AS DeductionCode,
		CASE	WHEN LEFT(TB.VchrNmbr, 3) = 'DPY' THEN 'Drayage'
				WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN 'Fuel Purchases'
				WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + IIF(GPCustom.dbo.AT('_', TB.VchrNmbr, 2) > 0, SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6), TB.VchrNmbr)
				WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = IIF(GPCustom.dbo.AT(RTRIM(TB.VendorId), TB.DocNumbr, 1) > 0, LEFT(TB.DocNumbr, GPCustom.dbo.AT(RTRIM(TB.VendorId), TB.DocNumbr, 1) - 1), TB.DocNumbr))
		ELSE TB.DocNumbr END AS DeductionType,
		(ABS(DOCAMNT) - ABS(CURRAMT)) * CASE WHEN TB.DocType = 5 THEN -1 ELSE 1 END AS DeductionAmount,
		NULL,
		TB.DocNumbr,
		CASE WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + IIF(GPCustom.dbo.AT('_', TB.VchrNmbr, 2) > 0, SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6), TB.VchrNmbr) ELSE TB.DocNumbr END AS DocNumbr,
		NULL,
		@WeekEnd AS CheckDate,
		TB.PostedDt AS PostingDate,
		VM.EFT,
		@BatchId AS BatchId
FROM	(SELECT	PH.VCHRNMBR,
		PH.VENDORID,
		PH.DOCTYPE,
		PH.DOCDATE, 
		PH.POSTEDDT, 
		PH.DOCNUMBR,
		PH.DOCAMNT,
		SUM(ISNULL(ApFrmAplyAmt, 0)) AS CurrAmt, -- (DocAmnt - CurTrxAm)
		PH.DEX_ROW_ID AS DEX_ROW_ID1,
		Null AS DEX_ROW_ID2,
		PH.DISCAMNT, 
		PH.DUEDATE, 
		PH.PYMTRMID, 
		PH.VOIDED
FROM	PM20000 PH 
		INNER JOIN #VednorMaster VM ON PH.VendorId = VM.VendorId
		LEFT JOIN PM30300 AP ON PH.VendorId = AP.VendorId AND PH.DocNumbr = AP.ApToDcNm
WHERE	POSTEDDT <= @CutoffDate
		AND VM.EFT = @IsEFT
GROUP BY
		PH.VCHRNMBR,
		PH.VENDORID,
		PH.DOCTYPE,
		PH.DOCDATE, 
		PH.POSTEDDT, 
		PH.DOCNUMBR,
		PH.DOCAMNT,
		PH.DOCAMNT,
		PH.DEX_ROW_ID,
		PH.DISCAMNT, 
		PH.DUEDATE, 
		PH.PYMTRMID, 
		PH.VOIDED) TB --> SubQuery
		INNER JOIN PM00200 VE ON TB.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
		INNER JOIN #VednorMaster VM ON TB.VendorId = VM.VendorId
WHERE	VM.EFT = @IsEFT
		AND TB.VendorId NOT IN (SELECT VendorId FROM @tblPaidDrivers)) AL
WHERE	(@DriverId IS Null OR (@DriverId IS NOT Null AND AL.VendorId = @DriverId))
UNION -- Escrow Information
SELECT	@CpnyName AS Company,
		@WEndDate AS WeekEndDate,
		@WEndDate AS TransDate,
		DATENAME(Week, @WEndDate) AS Week,
		ET.VendorId,
		VE.VendName,
		'4-0' AS DeductionCode,
		ISNULL(EA.AccountAlias, GL.ActDescr) AS DeductionType,
		SUM(Amount) AS DeductionAmount,
		Null,
		Null,
		ISNULL(EA.AccountAlias, GL.ActDescr),
		Null,
		@WEndDate AS CheckDate,
		@WEndDate AS PostingDate,
		VM.EFT,
		@BatchId AS BatchId,
		CONVERT(Char(10), @WEndDate, 102) + '_2' AS SortWeek
FROM	GPCustom.dbo.EscrowTransactions ET 
		INNER JOIN #VednorMaster VM ON ET.VendorId = VM.VendorId
		INNER JOIN GPCustom.dbo.EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON ET.CompanyId = EA.CompanyId AND ET.AccountNumber = EA.AccountNumber AND EA.RemittanceAdvise = 1 AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId
		LEFT JOIN GL00100 GL ON EA.AccountIndex = GL.ActIndx
		INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
WHERE	ET.CompanyId = @Company AND
		PostingDate <= @CutoffDate AND
		ET.DeletedOn IS Null AND
		VM.EFT = @IsEFT AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND ET.VendorId = @DriverId)) AND
		ET.Fk_EscrowModuleId <> 10
GROUP BY
		ET.VendorId,
		VE.VendName,
		ISNULL(EA.AccountAlias, GL.ActDescr),
		VM.EFT
HAVING	SUM(Amount) <> 0
UNION
SELECT	@CpnyName AS Company,
		@WEndDate AS WeekEndDate,
		@WEndDate AS TransDate,
		DATENAME(Week, @WEndDate) AS Week,
		ET.VendorId,
		VE.VendName,
		'5-0' AS DeductionCode,
		'My Truck Balance' AS DeductionType,
		CurTrxAm AS DeductionAmount,
		Null,
		Null,
		Null,
		Null,
		@WEndDate AS CheckDate,
		@WEndDate AS PostingDate,
		VM.EFT,
		@BatchId AS BatchId,
		CONVERT(Char(10), @WEndDate, 102) + '_3' AS SortWeek
FROM	GPCustom.dbo.View_MyTruckRecords_Summary ET
		INNER JOIN #VednorMaster VM ON ET.VendorId = VM.VendorId
		INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
WHERE	ET.Company = @Company AND
		VM.EFT = @IsEFT AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND ET.VendorId = @DriverId))
		) RA
		LEFT JOIN GPCustom.dbo.VendorMaster VM ON RA.VendorId = VM.VendorId AND VM.Company = @Company
ORDER BY 6

PRINT 'Records: ' + CAST(@@ROWCOUNT AS Varchar)

DROP TABLE #VednorMaster

PRINT 'Completed ' + CONVERT(Varchar, GETDATE(), 109)