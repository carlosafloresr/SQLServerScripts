ALTER PROCEDURE [dbo].[USP_DRA_Report] -- DRA = Driver Remittance Advice
		@Company	Char(6),
		@BatchId	Char(17),
		@DriverId	Varchar(10) = Null
AS
DECLARE	@Year		Int,
		@Week		Int,
		@CpnyName	Varchar(40),
		@Query		Varchar(5000),
		@Driver		Varchar(10),
		@WeekEnd	Datetime,
		@WEndDate	Datetime,
		@CutoffDate Datetime,
		@IsEFT		Int

SET	@IsEFT		= (	SELECT	TOP 1 ISNULL(EF.EFTTransferMethod, 0) 
					FROM	GPCustom.dbo.PM10300 PH
							LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId 
					WHERE	PH.Company = @Company AND
							BachNumb = @BatchId AND
							(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId)))

SET	@WeekEnd	= (	SELECT	TOP 1 DocDate 
					FROM	GPCustom.dbo.PM10300 PH
							LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId 
					WHERE	PH.Company = @Company AND
							BachNumb = @BatchId AND
							(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId)))

SET		@CpnyName	= (SELECT TOP 1 CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE Interid = @Company)
SET		@WEndDate	= (CASE	WHEN DATENAME(Weekday, @WeekEnd) = 'Sunday' THEN @WeekEnd - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEnd), @WeekEnd) END)
SET		@Year		= YEAR(@WEndDate)
SET		@Week		= DATENAME(Week, @WEndDate)
SET		@CutoffDate = @WeekEnd

SELECT	@CpnyName AS Company,
		CASE	WHEN GPCustom.dbo.WeekDay(PD.DocDate) < 5 THEN PD.DocDate + (5 - GPCustom.dbo.WeekDay(PD.DocDate))
				WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PD.DocDate
				ELSE PD.DocDate + (12 - GPCustom.dbo.WeekDay(PD.DocDate)) END AS WeekEndDate,
		PD.DocDate AS TransDate,
		@Week AS Week,
		PH.VendorId,
		PH.VendName,
		CASE	WHEN LEFT(PD.ApFvchNm, 3) = 'DPY' THEN '1-0'
				WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN '2-0'
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN '3-0'
		ELSE '3-1' END AS DeductionCode,
		CASE	WHEN LEFT(PD.ApFvchNm, 3) = 'DPY' THEN 'Drayage'
				WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN 'Fuel Purchases'
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = PH.Company AND DeductionCode = LEFT(PD.DocNumbr, GPCustom.dbo.AT(RTRIM(PH.VendorId), PD.DocNumbr, 1) - 1))
		ELSE PD.DocNumbr END AS DeductionType,
		PD.Outstanding_Amount AS DeductionAmount,
		PH.ChekTotl,
		PD.ApFvchNm,
		PD.DocNumbr,
		PD.AmntPaid,
		PH.DocDate AS CheckDate,
		PH.PstgDate AS PostingDate,
		ISNULL(EF.EFTTransferMethod, 0) AS EFT,
		@BatchId AS BatchId
FROM	GPCustom.dbo.PM10300 PH
		INNER JOIN GPCustom.dbo.PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr
		LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId
WHERE	PH.Company = @Company AND
		PH.BachNumb = @BatchId AND
		PH.ChekTotl > 0 AND
		PH.CurTrxAm > 0 AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId))
UNION
SELECT	@CpnyName AS Company,
		CASE	WHEN GPCustom.dbo.WeekDay(TB.DocDate) < 5 THEN TB.DocDate + (5 - GPCustom.dbo.WeekDay(TB.DocDate))
				WHEN GPCustom.dbo.WeekDay(TB.DocDate) = 5 THEN TB.DocDate
				ELSE TB.DocDate + (12 - GPCustom.dbo.WeekDay(TB.DocDate)) END AS WeekEndDate,
		TB.DocDate AS TransDate,
		@Week AS Week,
		TB.VendorId,
		VE.VendName,
		CASE	WHEN LEFT(TB.VchrNmbr, 3) = 'DPY' THEN '1-0'
				WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN '2-0'
				WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN '3-0'
		ELSE '3-1' END AS DeductionCode,
		CASE	WHEN LEFT(TB.VchrNmbr, 3) = 'DPY' THEN 'Drayage'
				WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN 'Fuel Purchases'
				WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = LEFT(TB.DocNumbr, GPCustom.dbo.AT(RTRIM(TB.VendorId), TB.DocNumbr, 1) - 1))
		ELSE TB.DocNumbr END AS DeductionType,
		ABS(CURRAMT) * CASE WHEN TB.DocType = 5 THEN -1 ELSE 1 END AS DeductionAmount,
		NULL,
		TB.DocNumbr,
		TB.DocNumbr,
		NULL,
		@WeekEnd AS CheckDate,
		TB.PostedDt AS PostingDate,
		ISNULL(EF.EFTTransferMethod, 0) AS EFT,
		@BatchId AS BatchId
FROM	(
SELECT * FROM (
SELECT	a.VCHRNMBR,
		a.VENDORID,
		a.DOCTYPE,
		a.DOCDATE, 
		a.POSTEDDT, 
		a.DOCNUMBR,
		a.DOCAMNT,
		CASE WHEN b.APTVCHNM IS Null THEN a.DOCAMNT ELSE a.DOCAMNT - b.APPLDAMT END AS CURRAMT,
		a.DEX_ROW_ID AS DEX_ROW_ID1,
		b.DEX_ROW_ID AS DEX_ROW_ID2,
		a.DISCAMNT, 
		a.DUEDATE, 
		a.PYMTRMID, 
		a.VOIDED
FROM --PM30200
		(SELECT	VCHRNMBR,
				VENDORID,
				DOCTYPE,
				DOCDATE, 
				POSTEDDT, 
				DOCNUMBR,
				DOCAMNT,
				DEX_ROW_ID,
				DISCAMNT, 
				DUEDATE, 
				PYMTRMID, 
				VOIDED
		FROM	PM30200
		UNION
		SELECT	VCHRNMBR,
				VENDORID,
				DOCTYPE,
				DOCDATE, 
				POSTEDDT, 
				DOCNUMBR,
				DOCAMNT,
				DEX_ROW_ID,
				DISCAMNT, 
				DUEDATE, 
				PYMTRMID, 
				VOIDED
		FROM	PM20000) a
	--PM30300
	LEFT JOIN	(
				SELECT	APTODCTY, 
						APTVCHNM, 
						SUM(APPLDAMT) AS APPLDAMT, 
						MAX(ApplyToGLPostDate) AS ApplyToGLPostDate, 
						MAX(DEX_ROW_ID) AS DEX_ROW_ID 
				FROM	PM30300 
				GROUP BY APTODCTY, APTVCHNM
				UNION
				SELECT	APTODCTY, 
						APTVCHNM, 
						SUM(APPLDAMT) AS APPLDAMT, 
						MAX(ApplyToGLPostDate) AS ApplyToGLPostDate, 
						MAX(DEX_ROW_ID) AS DEX_ROW_ID 
				FROM	PM20100 
				GROUP BY APTODCTY, APTVCHNM) b on a.VCHRNMBR = b.APTVCHNM AND a.DOCTYPE = b.APTODCTY AND a.DOCTYPE <= 4 AND a.VOIDED = 0
WHERE	a.DOCDATE <= @CutoffDate AND
		b.ApplyToGLPostDate <= @CutoffDate
UNION
SELECT	a.VCHRNMBR,
		a.VENDORID,
		a.DOCTYPE,
		a.DOCDATE, 
		a.POSTEDDT, 
		a.DOCNUMBR,
		-a.DOCAMNT,
		CASE WHEN b.VCHRNMBR IS Null THEN a.DOCAMNT ELSE a.DOCAMNT-b.APPLDAMT END AS CURRAMT,
		a.DEX_ROW_ID AS DEX_ROW_ID1,
		b.DEX_ROW_ID AS DEX_ROW_ID2,
		a.DISCAMNT, 
		a.DUEDATE, 
		a.PYMTRMID, 
		a.VOIDED
FROM	--PM30200 
	   (SELECT	VCHRNMBR,
				VENDORID,
				DOCTYPE,
				DOCDATE, 
				POSTEDDT, 
				DOCNUMBR,
				DOCAMNT,
				DEX_ROW_ID,
				DISCAMNT, 
				DUEDATE, 
				PYMTRMID, 
				VOIDED
		FROM	PM30200
		UNION
		SELECT	VCHRNMBR,
				VENDORID,
				DOCTYPE,
				DOCDATE, 
				POSTEDDT, 
				DOCNUMBR,
				DOCAMNT,
				DEX_ROW_ID,
				DISCAMNT, 
				DUEDATE, 
				PYMTRMID, 
				VOIDED
		FROM	PM20000) a
		--PM30300
		LEFT JOIN ( 
		SELECT	DOCTYPE, 
				VCHRNMBR, 
				SUM(APPLDAMT) AS APPLDAMT, 
				MAX(ApplyToGLPostDate) AS ApplyToGLPostDate, 
				MAX(DEX_ROW_ID) AS DEX_ROW_ID 
		FROM	PM30300 
		GROUP BY DOCTYPE, VCHRNMBR
		UNION
		SELECT	DOCTYPE, 
				VCHRNMBR, 
				SUM(APPLDAMT) AS APPLDAMT, 
				MAX(ApplyToGLPostDate) AS ApplyToGLPostDate, 
				MAX(DEX_ROW_ID) AS DEX_ROW_ID 
		FROM	PM20100 
		GROUP BY DOCTYPE, VCHRNMBR) b ON a.VCHRNMBR = b.VCHRNMBR AND a.DOCTYPE = b.DOCTYPE AND a.DOCTYPE > 4 AND a.VOIDED = 0
WHERE	a.DOCDATE <= @CutoffDate AND
		b.ApplyToGLPostDate <= @CutoffDate
UNION
SELECT	VCHRNMBR,
		VENDORID,
		DOCTYPE,
		DOCDATE, 
		POSTEDDT, 
		DOCNUMBR,
		-CurTrxAm,
		DOCAMNT,
		DEX_ROW_ID AS DEX_ROW_ID1,
		Null AS DEX_ROW_ID2,
		DISCAMNT, 
		DUEDATE, 
		PYMTRMID, 
		VOIDED
FROM	PM20000 
WHERE	POSTEDDT <= @CutoffDate) AP
		--AND VCHRNMBR NOT IN (SELECT VCHRNMBR FROM PM30300)) AP
WHERE	CURRAMT <> 0) TB
		INNER JOIN PM00200 VE ON TB.VendorId = VE.VendorId
		LEFT JOIN ME27606 EF ON TB.VendorId = EF.VendorId
WHERE	VE.VndClsId = 'DRV' AND
		ISNULL(EF.EFTTransferMethod, 0) = @IsEft AND
		TB.VendorId NOT IN (SELECT	VendorId FROM GPCustom.dbo.PM10300 PH
							WHERE	PH.Company = @Company AND
									PH.BachNumb = @BatchId AND
									PH.ChekTotl > 0 AND
									PH.CurTrxAm > 0 AND
									(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId))) AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND TB.VendorId = @DriverId))
ORDER BY PH.VendorId, 3, 7, 8

/*
EXECUTE USP_DRA_Report 'AIS', '052208DSDRVCK', 'A0011'
EXECUTE GPCustom.dbo.USP_DRA_Report 'AIS', '052908DSDRVCK', 'A0002'

SELECT * FROM PM10201 -- PM_Payment_Apply_WORK
SELECT * FROM PM10300 WHERE VendorId = 'A0027' -- PM_Payment_WORK
SELECT * FROM PM10201 WHERE PmntNmbr IN (SELECT PmntNmbr FROM PM10300 WHERE VendorId = 'A0027')

DECLARE @WeekEnd Datetime
SET @WeekEnd = '5/22/2008'
print GPCustom.dbo.WeekDay(@WeekEnd)
PRINT CASE	WHEN GPCustom.dbo.WeekDay(@WeekEnd) < 5 THEN @WeekEnd + (5 - GPCustom.dbo.WeekDay(@WeekEnd))
			WHEN GPCustom.dbo.WeekDay(@WeekEnd) = 5 THEN @WeekEnd
			ELSE @WeekEnd + (12 - GPCustom.dbo.WeekDay(@WeekEnd)) END

select * from PM20000 where vendorid = 'A0164'
select * from gpcustom.dbo.PM10300 where vendorid = 'A0164' AND CurTrxAm<>0
*/
