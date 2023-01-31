/*
SELECT	SUM(Amount) AS Balance
FROM	GPCustom.dbo.EscrowTransactions
WHERE	CompanyId = 'GIS'
		AND DeletedBy IS Null
		AND PostingDate IS NOT Null
		AND Fk_EscrowModuleId = 1
		AND PostingDate < '12/17/2009'
		AND VendorId = 'G9360'
*/

SELECT	ISNULL(SUM(Amount - ApplyTo), 0)
FROM	(	
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.CurTrxAm
		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.ApplyToGLPostDate <= '12/17/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
		,PM1.PostEddt
FROM	GIS.dbo.PM20000 PM1
WHERE	PM1.PostEddt <= '12/17/2009'
		AND PM1.VendorId = 'G9360'
		AND PM1.DocType IN (1)
UNION
--SELECT * FROM (
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.CurTrxAm
		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.ApplyToGLPostDate <= '12/17/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
		,PM1.PostEddt
FROM	GIS.dbo.PM30200 PM1
WHERE	PM1.PostEddt <= '12/17/2009'
		AND PM1.VendorId = 'G9360'
		AND PM1.DocType = 1) RECS
WHERE	Amount <> ApplyTo
		AND Amount <> CurTrxAm
/*
SELECT	*
FROM	(
SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.CurTrxAm
		,PM1.PostEddt
		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= '12/17/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
FROM	GIS.dbo.PM30200 PM1
WHERE	PM1.PostEddt <= '12/17/2009'
		AND PM1.VendorId = 'G9210'
		AND DocType IN (1,5)) RECS
WHERE	Amount <> ApplyTo
		AND Amount <> CurTrxAm

SELECT	ISNULL(SUM(Amount - ApplyTo), 0)
FROM	(
SELECT	PM1.VendorId
		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= '12/17/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
FROM	GIS.dbo.PM20000 PM1
WHERE	PM1.PostEddt <= '12/19/2009'
		AND DocType IN (1,5)
		AND PM1.VendorId = 'G9210') recs

SELECT	ISNULL(SUM(Amount - ApplyTo), 0)
from	(		
		SELECT	PM1.VendorId
		,PM1.DocNumbr
		,PM1.CurTrxAm
		,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= '12/17/2009' AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
FROM	GIS.dbo.PM30200 PM1
WHERE	PM1.PostEddt <= '12/17/2009'
		AND PM1.VendorId = 'G9371'
		AND DocType = 1
		) RECS
WHERE	

SELECT	*
FROM	GIS.dbo.PM30200 PM1
WHERE	PM1.PostEddt <= '12/17/2009'
		AND PM1.VendorId = 'G9360'
		AND CurTrxAm <> DocAmnt
*/