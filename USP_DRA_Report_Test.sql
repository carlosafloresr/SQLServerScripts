/*

EXECUTE USP_DRA_Report_Test 'AIS','DSDRV043009DD',NULL

select * 
from	gpcustom.dbo.PM10300 ph
		INNER JOIN GPCustom.dbo.PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr AND PH.Company = PD.Company
where	ph.bachnumb = '071808DSDRVCK' and vendorid = '8496'
*/
ALTER PROCEDURE [dbo].[USP_DRA_Report_Test] -- DRA = Driver Remittance Advice
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

SET		@IsEFT		= (CASE WHEN PATINDEX('%DD%', @BatchId) > 0 THEN 1 ELSE 0 END)
SET		@WeekEnd	= (SELECT MAX(DocDate) FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND BachNumb = @BatchId)

SET		@CpnyName	= (SELECT TOP 1 CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE Interid = @Company)
SET		@WEndDate	= (CASE	WHEN GPCustom.dbo.WeekDay(@WeekEnd) < 5 THEN @WeekEnd + (5 - GPCustom.dbo.WeekDay(@WeekEnd))
							WHEN GPCustom.dbo.WeekDay(@WeekEnd) = 5 THEN @WeekEnd
							ELSE @WeekEnd + (12 - GPCustom.dbo.WeekDay(@WeekEnd)) END)
SET		@Year		= YEAR(@WEndDate)
SET		@Week		= DATENAME(Week, @WEndDate)
SET		@CutoffDate = @WeekEnd

SELECT	RA.*,
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
				WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(PD.ApFvchNm, GPCustom.dbo.AT('_', PD.ApFvchNm, 2) + 1, 6)
				WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = PH.Company AND PATINDEX('%' + LTRIM(RTRIM(DeductionCode)) + '%', PD.DocNumbr) > 0)
		ELSE PD.DocNumbr END AS DeductionType,
		PD.Outstanding_Amount AS DeductionAmount,
		PH.ChekTotl,
		PD.ApFvchNm,
		CASE WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(PD.ApFvchNm, GPCustom.dbo.AT('_', PD.ApFvchNm, 2) + 1, 6) ELSE PD.DocNumbr END AS DocNumbr,
		PD.AmntPaid,
		PH.DocDate AS CheckDate,
		PH.PstgDate AS PostingDate,
		CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END AS EFT,
		@BatchId AS BatchId
FROM	GPCustom.dbo.PM10300 PH
		INNER JOIN GPCustom.dbo.PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr AND PH.Company = PD.Company
		LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId
WHERE	PH.Company = @Company AND
		PH.BachNumb = @BatchId AND
		PH.ChekTotl > 0
		AND CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END = @IsEFT
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
				WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6)
				WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = LEFT(TB.DocNumbr, GPCustom.dbo.AT(RTRIM(TB.VendorId), TB.DocNumbr, 1) - 1))
		ELSE TB.DocNumbr END AS DeductionType,
		(ABS(DOCAMNT) - ABS(CURRAMT)) * CASE WHEN TB.DocType = 5 THEN -1 ELSE 1 END AS DeductionAmount,
		NULL,
		TB.DocNumbr,
		CASE WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6) ELSE TB.DocNumbr END AS DocNumbr,
		NULL,
		@WeekEnd AS CheckDate,
		TB.PostedDt AS PostingDate,
		CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END AS EFT,
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
		LEFT JOIN PM30300 AP ON PH.VendorId = AP.VendorId AND PH.DocNumbr = AP.ApToDcNm
		LEFT JOIN ME27606 EF ON PH.VendorId = EF.VendorId
WHERE	POSTEDDT <= @CutoffDate
		AND CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END = @IsEFT
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
		LEFT JOIN ME27606 EF ON TB.VendorId = EF.VendorId
WHERE	CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END = @IsEFT
		AND TB.VendorId NOT IN (SELECT	VendorId FROM GPCustom.dbo.PM10300 PH
							WHERE	PH.Company = @Company AND
									PH.BachNumb = @BatchId AND
									PH.ChekTotl > 0 AND
									(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId)))) AL
WHERE	(@DriverId IS Null OR (@DriverId IS NOT Null AND AL.VendorId = @DriverId))
UNION
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
		CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END AS EFT,
		'' AS BatchId,
		CONVERT(Char(10), @WEndDate, 102) + '_2' AS SortWeek
FROM	GPCustom.dbo.EscrowTransactions ET
		INNER JOIN GPCustom.dbo.EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON ET.CompanyId = EA.CompanyId AND ET.AccountNumber = EA.AccountNumber AND EA.RemittanceAdvise = 1 AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId
		LEFT JOIN GL00100 GL ON EA.AccountIndex = GL.ActIndx
		INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
		LEFT JOIN ME27606 EF ON ET.VendorId = EF.VendorId
WHERE	ET.CompanyId = @Company AND
		PostingDate <= @CutoffDate AND
		CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END = @IsEFT AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND ET.VendorId = @DriverId))
GROUP BY
		ET.VendorId,
		VE.VendName,
		ISNULL(EA.AccountAlias, GL.ActDescr),
		CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END
HAVING	SUM(Amount) <> 0
UNION
SELECT	@CpnyName AS Company,
		@WEndDate AS WeekEndDate,
		ET.DocDate AS TransDate,
		DATENAME(Week, ET.DocDate) AS Week,
		ET.VendorId,
		VE.VendName,
		'5-0' AS DeductionCode,
		'My Truck' AS DeductionType,
		OrTrxAmt AS DeductionAmount,
		Null,
		Null,
		'My Truck',
		Null,
		@WEndDate AS CheckDate,
		@WEndDate AS PostingDate,
		CASE WHEN ISNULL(EF.EFTTransferMethod, 0) = 1 AND ISNULL(EF.ME_PreNote_Rejected, 0) = 0 THEN 1 ELSE 0 END AS EFT,
		'' AS BatchId,
		CONVERT(Char(10), @WEndDate, 102) + '_3' AS SortWeek
FROM	GPCustom.dbo.View_MyTruckRecords ET
		INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
		LEFT JOIN ME27606 EF ON ET.VendorId = EF.VendorId
WHERE	ET.DocDate = @WeekEnd - 7
		) RA
		LEFT JOIN GPCustom.dbo.VendorMaster VM ON RA.VendorId = VM.VendorId AND VM.Company = @Company
ORDER BY 5, 2, 3, 7, 8