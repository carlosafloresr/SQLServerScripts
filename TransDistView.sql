SELECT	PM10100.VchrNmbr,
	PM10000.DocNumbr,
	PM10000.DocAmnt,
	PM10000.DocDate,
	PM10000.
	PM10100.CrdtAmnt,
	PM10100.DebitAmt,
	PM10100.DistType,
	PM10100.VendorId,
	PMV1.VendName AS Vendor,
	PM10100.InterID AS CompanyID,
	PM10100.DistRef,
	RTRIM(GL00100.ActNumbr_1) + '-' + RTRIM(GL00100.ActNumbr_2) + '-' + GL00100.ActNumbr_3 AS Account,
	GL00100.ActDescr AS AcctDescription,
	ISNULL(TDEI.ReferenceId, '') AS ReferenceId,
	ISNULL(TDEI.ProNumber, '') AS ProNumber, 
	ISNULL(TDEI.DriverId, 0) AS DriverId,
	PMV2.VendName AS Driver,
	ISNULL(TDEI.Description, '') AS Description
FROM	PM10100
	INNER JOIN PM10000 ON PM10100.VchrNmbr = PM10000.VchrNmbr
	INNER JOIN GL00100 ON PM10100.DstIndx = GL00100.ActIndx
	INNER JOIN PM00200 PMV1 ON PM10100.VendorId = PMV1.VendorId
	LEFT JOIN GPCustom.dbo.TDExtendedInfo TDEI ON PM10100.VchrNmbr = TDEI.VoucherNo AND PM10100.DistType = TDEI.AccountType AND RTRIM(GL00100.ActNumbr_1) + RTRIM(GL00100.ActNumbr_2) + RTRIM(GL00100.ActNumbr_3) = TDEI.AccountNumber AND TDEI.Temporal = 0
	LEFT JOIN PM00200 PMV2 ON CAST(TDEI.DriverId AS Char(15)) = PMV2.VendorId

--SELECT * FROM PM10000