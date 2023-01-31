/*
EXECUTE USP_DRA_Report 'NDS','042810DSDRVDD','N15001'

EXECUTE USP_DRA_Report 'AIS','DSDR102011CK','A0678'

EXECUTE USP_DRA_Report 'IMC','072111DSDRVDD','A0306'

EXECUTE USP_DRA_Report 'GIS','DSDR09012011DD','G9734'

EXECUTE ILS_Datawarehouse.dbo.USP_DocumentBatches 'IMC', '06/17/2010', '061710DSDRVDD', 0
*/

ALTER PROCEDURE [dbo].[USP_DRA_Report] -- DRA = Driver Remittance Advice
		@Company	Char(6),
		@BatchId	Char(17),
		@DriverId	Varchar(15) = Null
AS
DECLARE	@Year		Int,
		@Week		Int,
		@CpnyName	Varchar(40),
		@Query		Varchar(5000),
		@Driver		Varchar(10),
		@WeekEnd	Datetime,
		@WEndDate	Datetime,
		@CutoffDate Datetime,
		@IsEFT		Int,
		@UserId		Varchar(25),
		@Note		Varchar(2000)

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
SET		@UserId		= @BatchId + REPLACE(CONVERT(Char(10), GETDATE(), 102), '.', '') + RTRIM(REPLACE(CONVERT(Char(6), GETDATE(), 108), ':', ''))
SET		@Note		= (SELECT TOP 1 Note FROM ILS_Datawarehouse.dbo.DocumentBatches WHERE Company = @Company AND BatchId = @BatchId)

EXECUTE USP_Driver_PayrollType @Company, @WEndDate, @BatchId, @DriverId, 1, @UserId

SELECT	DISTINCT VendorId
		,UPPER(CASE WHEN PATINDEX('%#%', PayToName) > 0 THEN SUBSTRING(PayToName, 1, PATINDEX('%#%', PayToName) - 1) ELSE PayToName END) AS PayToName
		,SubType
		,EFT 
		,TerminationDate
		,Division
INTO	#VednorMaster
FROM	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = @UserId
		AND EFT = @IsEFT
						
PRINT @CutoffDate

DELETE	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = @UserId

SELECT	*
INTO	#tmpOOSInformation
FROM	(
		SELECT	RA.*,
				VM.HireDate,
				VM.TerminationDate,
				@Note AS BatchNote
		FROM	(
				SELECT	*,
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
						VM.PayToName,
						CASE	WHEN (LEFT(PD.ApFvchNm, 3) = 'DPY' OR LEFT(PD.ApFvchNm, 2) = 'DP') THEN '1-0'
								WHEN LEFT(PD.ApFvchNm, 3) = 'FPT' THEN '2-0'
								WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN '2-0'
								WHEN LEFT(PD.ApFvchNm, 3) = 'OOS' THEN '3-0'
						ELSE '3-1' END AS DeductionCode,
						CASE	WHEN (LEFT(PD.ApFvchNm, 3) = 'DPY' OR LEFT(PD.ApFvchNm, 2) = 'DP') THEN 'Drayage'
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
						VM.EFT,
						@BatchId AS BatchId,
						VM.Division
				FROM	GPCustom.dbo.PM10300 PH
						INNER JOIN #VednorMaster VM ON PH.VendorId = VM.VendorId
						INNER JOIN GPCustom.dbo.PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr AND PH.Company = PD.Company
				WHERE	PH.Company = @Company AND
						PH.BachNumb = @BatchId AND
						--PH.ChekTotl > 0
						VM.EFT = @IsEFT
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
						VM.PayToName,
						CASE	WHEN (LEFT(TB.VchrNmbr, 3) = 'DPY' OR LEFT(TB.VchrNmbr, 2) = 'DP') THEN '1-0'
								WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN '2-0'
								WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN '2-0'
								WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN '3-0'
						ELSE '3-1' END AS DeductionCode,
						CASE	WHEN (LEFT(TB.VchrNmbr, 3) = 'DPY' OR LEFT(TB.VchrNmbr, 2) = 'DP') THEN 'Drayage'
								WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN 'Fuel Purchases'
								WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6)
								WHEN LEFT(TB.VchrNmbr, 3) = 'OOS' THEN (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = LEFT(TB.DocNumbr, GPCustom.dbo.AT(RTRIM(TB.VendorId), TB.DocNumbr, 1) - 1))
						ELSE TB.DocNumbr END AS DeductionType,
						ABS(CurTrxAm) * CASE WHEN TB.DocType = 5 THEN -1 ELSE 1 END AS DeductionAmount,
						NULL,
						TB.DocNumbr,
						CASE WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6) ELSE TB.DocNumbr END AS DocNumbr,
						NULL,
						@WeekEnd AS CheckDate,
						TB.PostedDt AS PostingDate,
						VM.EFT,
						@BatchId AS BatchId,
						VM.Division
				FROM	(SELECT	PH.VCHRNMBR,
								PH.VENDORID,
								PH.DOCTYPE,
								PH.DOCDATE, 
								PH.POSTEDDT, 
								PH.DOCNUMBR,
								PH.DOCAMNT,
								PH.CurTrxAm,
								PH.DEX_ROW_ID AS DEX_ROW_ID1,
								Null AS DEX_ROW_ID2,
								PH.DISCAMNT, 
								PH.DUEDATE, 
								PH.PYMTRMID, 
								PH.VOIDED
						FROM	PM20000 PH
								INNER JOIN #VednorMaster VM ON PH.VendorId = VM.VendorId
								LEFT JOIN PM20100 AP ON PH.VendorId = AP.VendorId AND PH.DocNumbr = AP.ApToDcNm
						WHERE	PH.PSTGDATE <= @CutoffDate AND VM.EFT = @IsEFT) TB --> SubQuery
						INNER JOIN PM00200 VE ON TB.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
						INNER JOIN #VednorMaster VM ON TB.VendorId = VM.VendorId
				WHERE	VM.EFT = @IsEFT
						AND TB.VendorId NOT IN (SELECT VendorId FROM GPCustom.dbo.PM10300 PH
											WHERE	PH.Company = @Company AND
													PH.BACHNUMB = @BatchId AND
													PH.ChekTotl > 0 AND
													(@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId)))) AL
				WHERE	(@DriverId IS Null OR (@DriverId IS NOT Null AND AL.VendorId = @DriverId))
				UNION -- Escrow Information
				SELECT	@CpnyName AS Company,
						@WEndDate AS WeekEndDate,
						@WEndDate AS TransDate,
						DATENAME(Week, @WEndDate) AS Week,
						ET.VendorId,
						VE.VendName,
						VM.PayToName,
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
						'' AS BatchId,
						CONVERT(Char(10), @WEndDate, 102) + '_2' AS SortWeek,
						VM.Division
				FROM	GPCustom.dbo.View_EscrowTransactions ET
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
						VM.PayToName,
						ISNULL(EA.AccountAlias, GL.ActDescr),
						VM.EFT,
						VM.Division
				HAVING	SUM(Amount) <> 0
				UNION
				SELECT	@CpnyName AS Company,
						@WEndDate AS WeekEndDate,
						@WEndDate AS TransDate,
						DATENAME(Week, @WEndDate) AS Week,
						ET.VendorId,
						VE.VendName,
						VM.PayToName,
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
						'' AS BatchId,
						CONVERT(Char(10), @WEndDate, 102) + '_3' AS SortWeek,
						VM.Division
				FROM	GPCustom.dbo.View_MyTruckRecords_Summary ET
						INNER JOIN #VednorMaster VM ON ET.VendorId = VM.VendorId
						INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
				WHERE	ET.Company = @Company AND
						VM.EFT = @IsEFT AND
						(@DriverId IS Null OR (@DriverId IS NOT Null AND ET.VendorId = @DriverId))
				) RA
				LEFT JOIN GPCustom.dbo.VendorMaster VM ON RA.VendorId = VM.VendorId AND VM.Company = @Company
		) DATA

SELECT	*
FROM	(
		SELECT	OOS1.*,
				TotalPaid = (SELECT SUM(OOS2.DeductionAmount) FROM #tmpOOSInformation OOS2 WHERE OOS2.VENDORID = OOS1.VENDORID)
		FROM	#tmpOOSInformation OOS1
		WHERE	DeductionAmount <> 0
		) RECS
WHERE	TerminationDate IS Null
		OR (TerminationDate IS NOT Null 
		AND TotalPaid <> 0)
ORDER BY 
		VendorId
		,WeekEndDate
		,TransDate
		,DeductionCode
		,DeductionType
		
DROP TABLE #VednorMaster
DROP TABLE #tmpOOSInformation
GO