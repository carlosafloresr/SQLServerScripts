ALTER VIEW View_AIS_1099
AS
SELECT 	DISTINCT HH.VchrNmbr,
	HH.VendorId,
	VE.VendName,
	VE.Ten99Type,
	HH.DocDate,
	HH.DocNumbr,
	HH.DocAmnt,
	HH.BachNumb,
	HH.PostEddt,
	HH.Ten99Amnt,
	HH.TrxDscrn,
	HH.POrdNmbr,
	PV.ProNumber,
	PV.TrailerNumber,
	HH.DocType,
	AP.ApfrmAplyAmt AS ApplyAmount,
	AP.Aptodcnm AS ApplyDocument,
	AP.VchrNmbr AS Aptvchnm,
	H2.DocDate AS ApplyDocDate,
	H2.DocNumbr AS CheckNumber,
	HH.Dex_Row_Id,
	RTRIM(FI.PerName) + ' ' + CAST(FI.Year1 AS Char(4)) AS PeriodName,
	FI.PSeries_3 AS PeriodClosed,
	FI.Year1,
	FI.PeriodId,
	'PM30200' AS Source
FROM 	AIS.dbo.PM30200 HH
	INNER JOIN AIS.dbo.PM00200 VE ON HH.VendorId = VE.VendorId
	LEFT JOIN AIS.dbo.SY40100 FI ON HH.DocDate BETWEEN FI.PeriodDT AND FI.PerDenDT AND FI.Series = 0 AND YEAR(HH.DocDate) = FI.Year1
	LEFT JOIN AIS.dbo.PM30300 AP ON HH.VchrNmbr = AP.Aptvchnm AND HH.DocType = AP.AptoDcTy AND AP.DocType = 6
	LEFT JOIN AIS.dbo.PM30200 H2 ON AP.VchrNmbr = H2.VchrNmbr AND AP.DocType = H2.DocType AND H2.DocType = 6
	LEFT JOIN Purchasing_Vouchers PV ON HH.VchrNmbr = PV.VoucherNumber AND PV.CompanyId = 'AIS'
WHERE 	HH.Voided = 0 AND
	HH.DocType < 6 AND
	VE.Ten99Type = 4
UNION
SELECT 	DISTINCT HH.VchrNmbr,
	HH.VendorId,
	VE.VendName,
	VE.Ten99Type,
	HH.DocDate,
	HH.DocNumbr,
	HH.DocAmnt,
	HH.BachNumb,
	HH.PostEddt,
	HH.Ten99Amnt,
	HH.TrxDscrn,
	HH.POrdNmbr,
	PV.ProNumber,
	PV.TrailerNumber,
	HH.DocType,
	AP.ApfrmAplyAmt AS ApplyAmount,
	AP.Aptodcnm AS ApplyDocument,
	AP.VchrNmbr AS Aptvchnm,
	H2.DocDate AS ApplyDocDate,
	H2.DocNumbr AS CheckNumber,
	HH.Dex_Row_Id,
	RTRIM(FI.PerName) + ' ' + CAST(FI.Year1 AS Char(4)) AS PeriodName,
	FI.PSeries_3 AS PeriodClosed,
	FI.Year1,
	FI.PeriodId,
	'PM20000' AS Source
FROM 	AIS.dbo.PM20000 HH
	INNER JOIN AIS.dbo.PM00200 VE ON HH.VendorId = VE.VendorId
	LEFT JOIN AIS.dbo.SY40100 FI ON HH.DocDate BETWEEN FI.PeriodDT AND FI.PerDenDT AND FI.Series = 0 AND YEAR(HH.DocDate) = FI.Year1
	LEFT JOIN AIS.dbo.PM30300 AP ON HH.VchrNmbr = AP.Aptvchnm AND HH.DocType = AP.AptoDcTy AND AP.DocType = 6
	LEFT JOIN AIS.dbo.PM30200 H2 ON AP.VchrNmbr = H2.VchrNmbr AND AP.DocType = H2.DocType AND H2.DocType = 6
	LEFT JOIN Purchasing_Vouchers PV ON HH.VchrNmbr = PV.VoucherNumber AND PV.CompanyId = 'AIS'
WHERE 	HH.Voided = 0 AND
	HH.DocType < 6 AND
	VE.Ten99Type = 4
/*

SELECT	VchrNmbr,
	DocAmnt,
	Ten99Amnt
FROM	AIS.dbo.PM30200 HH
	INNER JOIN AIS.dbo.PM00200 VE ON HH.VendorId = VE.VendorId
WHERE	Voided = 0 AND
	Ten99Type = 4 AND
	HH.DocType = 5 AND
	HH.VendorId = 'A0086'

UPDATE	AIS.dbo.PM30200
SET	Ten99Amnt = 0
FROM	(SELECT	VchrNmbr,
	DocAmnt,
	Ten99Amnt,
	HH.Dex_Row_Id
FROM	AIS.dbo.PM30200 HH
	INNER JOIN AIS.dbo.PM00200 VE ON HH.VendorId = VE.VendorId
WHERE	Voided = 0 AND
	Ten99Type = 4 AND
	HH.DocType = 5) OT
WHERE	AIS.dbo.PM30200.Dex_Row_Id = OT.Dex_Row_Id AND
	AIS.dbo.PM30200.VchrNmbr = OT.VchrNmbr

UPDATE	AIS.dbo.PM30200
SET	Ten99Amnt = OT.DocAmnt
FROM	(SELECT	VchrNmbr,
		DocAmnt,
		HH.Dex_Row_Id
	FROM	AIS.dbo.PM30200 HH
		INNER JOIN AIS.dbo.PM00200 VE ON HH.VendorId = VE.VendorId
	WHERE	LEFT(VchrNmbr, 3) = 'DPY' AND
		Voided = 0 AND
		Ten99Type = 4 AND
		Ten99Amnt = 0) OT
WHERE	AIS.dbo.PM30200.Dex_Row_Id = OT.Dex_Row_Id AND
	AIS.dbo.PM30200.VchrNmbr = OT.VchrNmbr

SELECT * FROM AIS.dbo.PM10000

SELECT VendorId, VendName, CASE WHEN Ten99Type = 1 OR Ten99Type IS NULL THEN 'NOT 1099' WHEN Ten99Type = 2 THEN 'DIVIDENS' WHEN Ten99Type = 2 THEN 'INTEREST' WHEN Ten99Type = 4 THEN 'MISCELLANEOUS' ELSE 'NOT 1099' END AS Type1099 FROM AIS.dbo.PM00200 ORDER BY 1
SELECT	* 
FROM	AIS.dbo.PM30200 CH
	LEFT JOIN AIS.dbo.PM30300 AP ON CH.VchrNmbr = AP.VchrNmbr AND CH.DocType = AP.DocType
WHERE	CH.DocType = 6 AND
	CH.DocDate BETWEEN '01/01/2007' AND '12/31/2007'

SELECT * FROM AIS.dbo.PM30300 where Aptvchnm = 'DPYA0086071020'
*/