/*
SELECT	* 
FROM	GPCustom.dbo.PM10300 
WHERE	Company = 'GIS' 
		AND VendorId = 'G9902'
ORDER BY DocDate

SELECT * FROM GIS.dbo.PM00200 WHERE VendorId = 'G9902'

PRINT GPCustom.dbo.DriverBalance('GIS','G9890','12/22/2009')
*/
DECLARE	@DriverId		Varchar(25),
		@CutoffDate		Datetime,
		@WEndDate		Datetime,
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@VendorId		Varchar(15)

SET		@Company	= 'IMC'
SET		@BatchId	= 'DSDRV123009DD'
SET		@DriverId	= '8457'
SET		@CutoffDate	= '12/31/2009'
SET		@WEndDate	= @CutoffDate
SET		@VendorId	= '8457'

/*
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM2.ApFrDcNm <> '' AND PM1.VendorId = PM2.VendorId), 0)
FROM	GIS.dbo.PM20000 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId

select * from PM30300 where vendorid = 'G9890' and ApFrDcNm = 'DPYG9890091212025'
select * from PM30300 where vendorid = 'G9890' and ApToDcNm = 'DPYG9890091212025'
*/
SELECT	ISNULL(SUM(Amount + ApplyTo), 0)
FROM	(
--SELECT	PM1.VendorId
--		,PM1.DocNumbr
--		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
--		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM2.ApFrDcNm <> '' AND PM1.VendorId = PM2.VendorId), 0)
--		--,*
--FROM	GIS.dbo.PM30200 PM1
--WHERE	PM1.PstgDate <= @CutoffDate
--		AND PM1.VendorId = @VendorId) recs

--SELECT * FROM (
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.VchrNmbr
		,PM1.DocAmnt AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM IMC.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0) * -1
		,PM1.DocType
FROM	IMC.dbo.PM20000 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId
		AND PM1.DocType NOT IN (5,6)
UNION
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.VchrNmbr
		,PM1.DocAmnt * -1 AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM IMC.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApFrDcNm AND PM1.VendorId = PM2.VendorId), 0)
		,PM1.DocType
FROM	IMC.dbo.PM20000 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId
		AND PM1.DocType IN (5,6)
UNION
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.VchrNmbr
		,PM1.DocAmnt AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM IMC.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0) * -1
		,PM1.DocType
FROM	IMC.dbo.PM30200 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId
		AND PM1.DocType NOT IN (5,6)
UNION
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.VchrNmbr
		,PM1.DocAmnt * -1 AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM IMC.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApFrDcNm AND PM1.VendorId = PM2.VendorId), 0)
		,PM1.DocType
FROM	IMC.dbo.PM30200 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId
		AND PM1.DocType IN (5,6)
		)recs
WHERE	DocType NOT IN (5,6)
		
/*
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.VchrNmbr
		,PM1.DocAmnt AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0) * -1
		,PM1.DocType
FROM	GIS.dbo.PM30200 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId
		AND PM1.DocType NOT IN (5,6)
UNION
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.VchrNmbr
		,PM1.DocAmnt * -1 AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @CutoffDate AND PM1.DocNumbr = PM2.ApFrDcNm AND PM1.VendorId = PM2.VendorId), 0)
		,PM1.DocType
FROM	GIS.dbo.PM30200 PM1
WHERE	PM1.PstgDate <= @CutoffDate
		AND PM1.VendorId = @VendorId
		AND PM1.DocType IN (5,6)
*/

-- SELECT * FROM PM30300 WHERE VendorId = 'G9890' AND GLPostDt <= '12/22/2009' ORDER BY ApToDcNm
/*

SELECT * FROM PM30200 WHERE VendorId = 'G9890' AND PstgDate <= '12/22/2009' and DocType IN (5,6) ORDER BY DocNumbr
SELECT * FROM PM30300 WHERE VendorId = 'G9890' AND GLPostDt <= '12/22/2009' ORDER BY ApToDcNm

EXECUTE USP_Driver_PayrollType @Company, @WEndDate, @BatchId, @DriverId, 1, 'CFLORES'

SELECT	VendorId
		,SubType
		,EFT 
		,TerminationDate
INTO	#VednorMaster
FROM	GPCustom.dbo.OOS_PayrollDrivers 
WHERE	Company = @Company 
		AND UserId = 'CFLORES'
SELECT * FROM #VednorMaster
/*
SELECT	*
FROM	GPCustom.dbo.EscrowTransactions
WHERE	CompanyId = 'GIS' 
		AND VendorId = 'G9902'
		AND DeletedOn IS Null
ORDER BY PostingDate
*/
SELECT	ET.VendorId,
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
		'' AS BatchId,
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
		VM.EFT = 1 AND
		(@DriverId IS Null OR (@DriverId IS NOT Null AND ET.VendorId = @DriverId)) AND
		ET.Fk_EscrowModuleId <> 10
GROUP BY
		ET.VendorId,
		VE.VendName,
		ISNULL(EA.AccountAlias, GL.ActDescr),
		VM.EFT
HAVING	SUM(Amount) <> 0

DROP TABLE #VednorMaster
*/