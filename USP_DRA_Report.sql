USE [AIS]
GO
/****** Object:  StoredProcedure [dbo].[USP_DRA_Report]    Script Date: 7/18/2017 10:35:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DRA_Report 'AIS','DSDR080218DD', '10778'

EXECUTE USP_DRA_Report 'GIS','DSDR062917DD','G0017'

EXECUTE USP_DRA_Report 'DNJ','DSDR022515DD', 'D0009'

SELECT TOP 100 * FROM GPCustom.dbo.PM10300 WHERE BACHNUMB = 'DSDR032113DD'
 
select * from pm20000 where vchrnmbr = '3229'

EXECUTE USP_DRA_Report 'IMC','021816DSDRVDD','12918'

EXECUTE USP_DRA_Report 'GIS','DSDRV032615DD','G0722'
EXECUTE USP_DRA_Report 'NDS','DSDRV060514DD','N38018'
EXECUTE USP_DRA_Report 'NDS','DSDRV032416DD','N44002'
EXECUTE ILS_Datawarehouse.dbo.USP_DocumentBatches 'IMC', '06/17/2010', '061710DSDRVDD', 0

 DSDR011115ESC DSDR011416CK  
*/

CREATE PROCEDURE [dbo].[USP_DRA_Report] -- DRA = Driver Remittance Advice
		@Company	Varchar(6),
		@BatchId	Varchar(17),
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
SET		@CutoffDate = @WEndDate
SET		@BatchId	= RTRIM(@BatchId)
SET		@UserId		= @BatchId + REPLACE(CONVERT(Char(10), GETDATE(), 102), '.', '') + RTRIM(REPLACE(CONVERT(Char(6), GETDATE(), 108), ':', ''))
SET		@Note		= (SELECT TOP 1 Note FROM ILS_Datawarehouse.dbo.DocumentBatches WHERE Company = @Company AND BatchId = @BatchId)

PRINT 'Started At ' + CONVERT(Varchar, GETDATE(), 109)

EXECUTE USP_Driver_PayrollType @Company, @WEndDate, @BatchId, @DriverId, 1, @UserId
PRINT '1: USP_Driver_PayrollType ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	DISTINCT RTRIM(VendorId) AS VendorId
		,UPPER(CASE WHEN PATINDEX('%#%', PayToName) > 0 THEN SUBSTRING(PayToName, 1, PATINDEX('%#%', PayToName) - 1) ELSE PayToName END) AS PayToName
		,SubType
		,EFT
		,HireDate
		,TerminationDate
		,Division
INTO	#VednorMaster
FROM	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = @UserId
		AND EFT = @IsEFT
		--AND (@DriverId IS Null OR (@DriverId IS NOT Null AND VendorId = @DriverId))
PRINT '2: Payroll Drivers selection ' + CONVERT(Varchar, GETDATE(), 109)

DELETE	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = @UserId
PRINT '3: Deleted temporal driver records ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	DISTINCT *
INTO	#tmpOOSInformation
FROM	(
		SELECT	RA.*,
				VM.HireDate,
				VM.TerminationDate,
				@Note AS BatchNote
		FROM	(
				SELECT	*,
						REPLACE(CONVERT(Char(10), WeekEndDate, 102), '.','') + '_1' AS SortWeek
				FROM	(
						SELECT	DISTINCT @CpnyName AS Company,
								CASE	WHEN GPCustom.dbo.WeekDay(PD.DocDate) < 5 THEN PD.DocDate + (5 - GPCustom.dbo.WeekDay(PD.DocDate))
										WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PD.DocDate
										WHEN LEFT(PD.VchrNmbr, 3) = 'FPT' THEN PD.DocDate + (12 - GPCustom.dbo.WeekDay(PD.DocDate))
										ELSE PD.DocDate + (12 - GPCustom.dbo.WeekDay(PD.DocDate)) END AS WeekEndDate,
								PD.DocDate AS TransDate,
								DATENAME(Week, PD.DocDate) AS Week,
								RTRIM(PH.VendorId) AS VendorId,
								PH.VendName,
								VM.PayToName,
								CASE	WHEN (LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'DPY' OR LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 2) = 'DP') THEN '1-0'
										WHEN LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'FPT' THEN '2-0'
										WHEN LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'EIN' OR LEFT(PD.ApFvchNm, 3) = 'EIN' THEN '2-0'
										WHEN LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'OOS' THEN '3-0'
								ELSE '3-1' END AS DeductionCode,
								CASE	WHEN (LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'DPY' OR LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 2) = 'DP') THEN 'Drayage'
										WHEN LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'FPT' THEN 'Fuel Purchases'
										WHEN LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(A2.BACHNUMB, GPCustom.dbo.AT('_', A2.BACHNUMB, 2) + 1, 6)
										WHEN LEFT(PD.ApFvchNm, 3) = 'EIN' THEN 'Interest Paid '
										WHEN LEFT(ISNULL(A2.BACHNUMB, AP.BACHNUMB), 3) = 'OOS' THEN CASE WHEN OT.SpecialDeduction = 1 THEN REPLACE(OT.Description, RTRIM(PH.VENDORID) + ' ', '') ELSE (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = PH.Company AND DeductionCode = SUBSTRING(PD.DocNumbr, 1, PATINDEX('%' + LTRIM(RTRIM(PH.VendorId)) + '%', PD.DocNumbr) - 1)) END
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
								VM.Division,
								ISNULL(A2.BACHNUMB, AP.BACHNUMB) AS BACHNUMB
						FROM	GPCustom.dbo.PM10300 PH
								INNER JOIN #VednorMaster VM ON PH.VendorId = VM.VendorId
								INNER JOIN GPCustom.dbo.PM10201 PD ON PH.PmntNmbr = PD.PmntNmbr AND PH.Company = PD.Company
								LEFT JOIN PM20000 AP ON PD.DOCNUMBR = AP.DOCNUMBR AND PH.VENDORID = AP.VENDORID AND AP.VOIDED = 0 AND AP.HOLD = 0
								LEFT JOIN PM30200 A2 ON PD.DOCNUMBR = A2.DOCNUMBR AND PH.VENDORID = A2.VENDORID AND A2.VOIDED = 0 AND A2.HOLD = 0
								LEFT JOIN GPCustom.dbo.View_OOS_Transactions OT ON PH.VENDORID = OT.Vendorid AND PH.Company = OT.Company AND PD.VCHRNMBR = OT.Voucher
						WHERE	PH.Company = @Company
								AND PH.BachNumb = @BatchId
								AND VM.EFT = @IsEFT
								--AND (@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId))
						UNION
						-- NO WEEK PAY RECORDS
						SELECT	@CpnyName AS Company,
								CASE	WHEN GPCustom.dbo.WeekDay(TB.DocDate) < 5 THEN TB.DocDate + (5 - GPCustom.dbo.WeekDay(TB.DocDate))
										WHEN GPCustom.dbo.WeekDay(TB.DocDate) = 5 THEN TB.DocDate
										WHEN LEFT(TB.VchrNmbr, 3) = 'FPT' THEN TB.DocDate + (12 - GPCustom.dbo.WeekDay(TB.DocDate))
										ELSE TB.DocDate + (12 - GPCustom.dbo.WeekDay(TB.DocDate)) END AS WeekEndDate,
								TB.DocDate AS TransDate,
								@Week AS Week,
								RTRIM(TB.VendorId) AS VendorId,
								VE.VendName,
								VM.PayToName,
								CASE	WHEN (LEFT(TB.BACHNUMB, 3) = 'DPY' OR LEFT(TB.BACHNUMB, 2) = 'DP') THEN '1-0'
										WHEN LEFT(TB.BACHNUMB, 3) = 'FPT' THEN '2-0'
										WHEN LEFT(TB.BACHNUMB, 3) = 'EIN' OR LEFT(TB.BACHNUMB, 2) = 'EI' THEN '2-0'
										WHEN LEFT(TB.BACHNUMB, 3) = 'OOS' THEN '3-0'
								ELSE '3-1' END AS DeductionCode,
								CASE	WHEN (LEFT(TB.BACHNUMB, 3) = 'DPY' OR LEFT(TB.BACHNUMB, 2) = 'DP') THEN 'Drayage'
										WHEN LEFT(TB.BACHNUMB, 3) = 'FPT' THEN 'Fuel Purchases'
										WHEN LEFT(TB.BACHNUMB, 3) = 'EIN' OR LEFT(TB.BACHNUMB, 2) = 'EI' THEN 'Interest Paid ' + SUBSTRING(TB.BACHNUMB, GPCustom.dbo.AT('_', TB.BACHNUMB, 2) + 1, 6)
										WHEN LEFT(TB.BACHNUMB, 3) = 'OOS' THEN CASE WHEN OT.SpecialDeduction = 1 THEN REPLACE(OT.Description, RTRIM(TB.VENDORID) + ' ', '') ELSE (SELECT TOP 1 Description FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = LEFT(TB.DocNumbr, GPCustom.dbo.AT(RTRIM(TB.VendorId), TB.DocNumbr, 1) - 1)) END
								ELSE TB.DocNumbr END AS DeductionType,
								ABS(TB.CurTrxAm) * CASE WHEN TB.DocType = 5 THEN -1 ELSE 1 END AS DeductionAmount,
								NULL,
								TB.DocNumbr,
								CASE WHEN LEFT(TB.VchrNmbr, 3) = 'EIN' THEN 'Interest Paid ' + SUBSTRING(TB.VchrNmbr, GPCustom.dbo.AT('_', TB.VchrNmbr, 2) + 1, 6) ELSE TB.DocNumbr END AS DocNumbr,
								NULL,
								@WeekEnd AS CheckDate,
								TB.PostedDt AS PostingDate,
								VM.EFT,
								@BatchId AS BatchId,
								VM.Division,
								BACHNUMB
						FROM	(SELECT	PH.VCHRNMBR,
										RTRIM(PH.VENDORID) AS VendorId,
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
										PH.VOIDED,
										PH.BACHNUMB
								FROM	PM20000 PH
										INNER JOIN #VednorMaster VM ON PH.VendorId = VM.VendorId
										LEFT JOIN PM20100 AP ON PH.VendorId = AP.VendorId AND PH.DocNumbr = AP.ApToDcNm
								WHERE	PH.PSTGDATE <= @CutoffDate 
										AND VM.EFT = @IsEFT
										AND PH.VOIDED = 0
										AND PH.HOLD = 0
								) TB --> SubQuery
								INNER JOIN PM00200 VE ON TB.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
								INNER JOIN #VednorMaster VM ON TB.VendorId = VM.VendorId
								LEFT JOIN GPCustom.dbo.View_OOS_Transactions OT ON TB.VENDORID = OT.Vendorid AND OT.Company = @Company AND TB.VCHRNMBR = OT.Voucher
						WHERE	VM.EFT = @IsEFT
								AND TB.VendorId NOT IN (SELECT	VendorId 
														FROM	GPCustom.dbo.PM10300 PH
														WHERE	PH.Company = @Company
																AND PH.BACHNUMB = @BatchId
																AND PH.ChekTotl > 0
																AND (@DriverId IS Null OR (@DriverId IS NOT Null AND PH.VendorId = @DriverId))
														)
						) AL
				UNION
				-- Escrow Information
				SELECT	@CpnyName AS Company,
						@WEndDate AS WeekEndDate,
						@WEndDate AS TransDate,
						DATENAME(Week, @WEndDate) AS Week,
						RTRIM(ET.VendorId) AS VendorId,
						VE.VendName,
						VM.PayToName,
						'4-0' AS DeductionCode,
						ISNULL(EA.AccountAlias, GL.ActDescr) AS DeductionType,
						SUM(Amount) AS DeductionAmount,
						Null,
						Null,
						CASE WHEN RTRIM(EA.AccountAlias) = '' THEN GL.ActDescr ELSE ISNULL(EA.AccountAlias, GL.ActDescr) END,
						Null,
						@WEndDate AS CheckDate,
						@WEndDate AS PostingDate,
						VM.EFT,
						@BatchId AS BatchId, -- changed from empty string
						VM.Division,
						NULL AS BACHNUMB,
						REPLACE(CONVERT(Char(10), DATEADD(dd, 1, @WEndDate), 102), '.','') + '_2' AS SortWeek
				FROM	GPCustom.dbo.View_EscrowTransactions ET
						INNER JOIN #VednorMaster VM ON ET.VendorId = VM.VendorId
						INNER JOIN GPCustom.dbo.EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId AND EM.RemittanceAdvise = 1
						INNER JOIN GPCustom.dbo.EscrowAccounts EA ON ET.CompanyId = EA.CompanyId AND ET.AccountNumber = EA.AccountNumber AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId AND EA.RemittanceAdvise = 1
						INNER JOIN GL00100 GL ON EA.AccountIndex = GL.ActIndx
						INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' --AND VE.VENDSTTS = 1
				WHERE	ET.CompanyId = @Company
						AND PostingDate <= @CutoffDate
						AND ET.DeletedOn IS Null
						AND VM.EFT = @IsEFT
				GROUP BY
						ET.VendorId,
						VE.VendName,
						VM.PayToName,
						ISNULL(EA.AccountAlias, GL.ActDescr),
						VM.EFT,
						VM.Division,
						EA.AccountAlias,
						GL.ActDescr
				HAVING	SUM(Amount) <> 0
				UNION
				SELECT	@CpnyName AS Company,
						@WEndDate AS WeekEndDate,
						@WEndDate AS TransDate,
						DATENAME(Week, @WEndDate) AS Week,
						RTRIM(ET.VendorId) AS VendorId,
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
						@BatchId AS BatchId, -- changed from empty string
						VM.Division,
						NULL AS BACHNUMB,
						REPLACE(CONVERT(Char(10), @WEndDate, 102), '.','') + '_3' AS SortWeek
				FROM	GPCustom.dbo.View_MyTruckRecords_Summary ET
						INNER JOIN #VednorMaster VM ON ET.VendorId = VM.VendorId AND VM.SubType = 2
						INNER JOIN PM00200 VE ON ET.VendorId = VE.VendorId AND VE.VndClsId = 'DRV' AND VE.VENDSTTS = 1
				WHERE	ET.Company = @Company
						AND VM.EFT = @IsEFT
			) RA
			LEFT JOIN #VednorMaster VM ON RA.VendorId = VM.VendorId
		) DATA
PRINT '4: Main query selection ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	DISTINCT RECS.*,
		CAST(SUBSTRING(DeductionCode, 1, 1) AS Smallint) AS Category,
		CASE WHEN SUBSTRING(DeductionCode, 1, 1) IN ('1','2') THEN ''
			 WHEN SUBSTRING(DeductionCode, 1, 1) = '3' THEN 'Other Deductions / ATP’s'
			 WHEN SUBSTRING(DeductionCode, 1, 1) = '4' THEN 'Escrow Balances'
			 ELSE 'Other Transactions' END AS CategoryTitle,
		CAST(CASE WHEN SFB.PayDate IS Null THEN 0 ELSE 1 END AS Bit) AS WithSafetyBonus,
		CASE WHEN PATINDEX('%DD%', @BatchId) > 0 THEN 'Direct Deposit' ELSE 'Check' END AS BatchType
FROM	(
		SELECT	OOS1.*,
				TotalPaid = (SELECT SUM(OOS2.DeductionAmount) FROM #tmpOOSInformation OOS2 WHERE OOS2.VENDORID = OOS1.VENDORID),
				CASE WHEN SBP.StartDate IS Null THEN '01/01/1980'
					 WHEN SBD.BonusExpirationDate IS NOT Null AND SBD.BonusReactivationDate IS Null THEN SBD.BonusExpirationDate
					 WHEN SBD.BonusExpirationDate IS NOT Null AND SBD.BonusReactivationDate IS NOT Null AND @WEndDate < SBD.BonusReactivationDate THEN SBD.BonusExpirationDate
					 ELSE '12/31/2099'
				END AS BonusExpirationDate
		FROM	#tmpOOSInformation OOS1
				LEFT JOIN GPCustom.dbo.SafetyBonusParameters SBP ON SBP.Company = @Company
				LEFT JOIN GPCustom.dbo.SafetyBonusParametersByDivision SBD ON SBD.Company = @Company AND OOS1.Division = SBD.Division
		WHERE	DeductionAmount <> 0
		) RECS
		LEFT JOIN GPCustom.dbo.SafetyBonus SFB ON SFB.Company = @Company AND RECS.VendorId = SFB.VendorId AND RECS.CheckDate <= SFB.BonusPayDate AND SFB.SortColumn = 0
WHERE	TerminationDate IS Null
		OR (TerminationDate IS NOT Null AND TotalPaid <> 0)
ORDER BY 
		RECS.VendorId
		,WeekEndDate
		,TransDate
		,DeductionCode
		,DeductionType

PRINT '5: Final presentation query ' + CONVERT(Varchar, GETDATE(), 109)
		
DROP TABLE #VednorMaster
DROP TABLE #tmpOOSInformation