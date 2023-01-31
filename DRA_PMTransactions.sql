-- SELECT * FROM AIS.dbo.PM20000 WHERE VendorId = 'A0187' AND VchrNmbr = '00000000000001058'
-- SELECT * FROM AIS.dbo.PM10100 WHERE VendorId = 'A0124' AND VchrNmbr = '00000000000001058'
-- SELECT * FROM AIS.dbo.PM30200 WHERE VendorId = 'A0187'
-- SELECT * FROM AIS.dbo.PM30600 WHERE VendorId = 'A0011' AND VchrNmbr = 'FPTA0011_080504C'
/*
SELECT	PstgDate,
		DocDate
		VendorId,
		DistRef,
		DocAmount
FROM	AIS.DBO.PM30600 PD
		INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.TrxSorce = PH.TrxSorce
WHERE	DstSqNum = 16384 AND 
		VendorId = 'A0011'
SELECT * FROM PM00200
*/

SELECT	PH.PstgDate,
		PH.DocDate,
		DATENAME(Week, PH.PstgDate) AS Week,
		PH.VendorId,
		VE.VendName AS Vendor,
		'OTHREIM' AS DeductionCode,
		PH.TrxDscrn,
		PH.DocAmnt
FROM	PM20000 PH
		LEFT JOIN PM10100 PD ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce AND PD.DistType = 2
		LEFT JOIN PM00200 VE ON PH.VendorId = VE.VendorId
WHERE	PH.VendorId = 'A0124' AND
		PH.BchSourc = 'PM_Trxent' AND
		VE.VndClsId = 'DRV' AND
		PD.DstIndx NOT IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = 'AIS') AND
		DATENAME(Week, PH.PstgDate) = 19
ORDER BY 
		PH.TrxDscrn

EXECUTE GPCustom.dbo.USP_DRA_Report 'AIS', '05/05/2008', 'A0124'
/*


SELECT	*
FROM	PM30200 PH
		LEFT JOIN PM30600 PD ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce AND PD.DistType = 2
WHERE	PH.VendorId = 'A0011' AND
		PH.BchSourc = 'PM_Trxent' AND
		PD.DstIndx NOT IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = 'AIS') AND
		DATENAME(Week, PH.PstgDate) = 19
*/