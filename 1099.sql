ALTER VIEW View_AIS_1099
AS
SELECT 	HH.VchrNmbr,
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
	HH.DocType
FROM 	AIS.dbo.PM30200 HH
	INNER JOIN AIS.dbo.PM00200 VE ON HH.VendorId = VE.VendorId
	LEFT JOIN Purchasing_Vouchers PV ON HH.VchrNmbr = PV.VoucherNumber AND PV.CompanyId = 'AIS'
WHERE 	HH.PostEddt BETWEEN '01/01/2007' AND '12/31/2007' AND
	HH.Voided = 0 AND
	HH.DocType < 6
ORDER BY
	HH.VendorId,
	HH.DocDate,
	HH.VchrNmbr

/*
select	*
from	AIS.dbo.PM30200 
order by VchrNmbr

SELECT 	HH.VchrNmbr,
	HH.VendorId,
	VE.VendName,
	VE.Ten99Type,
	HH.DocDate,
	HH.DocNumbr,
	HH.DocAmnt,
	HH.BachNumb,
	HD.DstSqNum,
	HD.CrdtAmnt,
	HD.DebitAmt,
	HD.DstIndx,
	RTRIM(GL.ActNumbr_1) + '-' + RTRIM(GL.ActNumbr_2) + '-' + GL.ActNumbr_3 AS Account,
	HH.PostEddt,
	HH.Ten99Amnt
FROM 	PM30200 HH
	INNER JOIN PM30600 HD ON HH.VchrNmbr = HD.VchrNmbr AND HH.TrxSorce = HD.TrxSorce
	INNER JOIN PM00200 VE ON HH.VendorId = VE.VendorId
	LEFT JOIN GL00100 GL ON HD.DstIndx = GL.ActIndx
WHERE 	HH.PostEddt BETWEEN '01/01/2007' AND '12/31/2007'
*/