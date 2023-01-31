-- HISTORIC AP
SELECT 	PD.DocType,
	PD.VchrNmbr,
	DocDate,
	DocNumbr,
	DstSqNum,
	CrdtAmnt,
	DebitAmt,
	DstIndx,
	AccountNumber,
	DistType,
	PD.VendorId,
	DistRef
FROM 	AIS.DBO.PM30600 PD
	INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
WHERE 	RTRIM(PD.VchrNmbr) + '_' + RTRIM(CAST(DstSqNum AS Char(10))) NOT IN (SELECT RTRIM(VoucherNumber) + '_' + RTRIM(CAST(ItemNumber AS Char(10))) FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = 'AIS')
UNION
-- WORK AP
SELECT 	DocType,
	PD.VchrNmbr,
	DocDate,
	DocNumbr,
	DstSqNum,
	CrdtAmnt,
	DebitAmt,
	DstIndx,
	AccountNumber,
	DistType,
	PD.VendorId,
	DistRef
FROM 	AIS.DBO.PM10100 PD
	INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchNumWk
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
WHERE 	RTRIM(PD.VchrNmbr) + '_' + RTRIM(CAST(DstSqNum AS Char(10))) NOT IN (SELECT RTRIM(VoucherNumber) + '_' + RTRIM(CAST(ItemNumber AS Char(10))) FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = 'AIS')
UNION
-- OPEN AP
SELECT 	PD.DocType,
	PD.VchrNmbr,
	DocDate,
	DocNumbr,
	DstSqNum,
	CrdtAmnt,
	DebitAmt,
	DstIndx,
	AccountNumber,
	DistType,
	VendorId,
	'' AS DistRef
FROM 	AIS.DBO.PM20200 PD
	INNER JOIN PM20000 PH ON PD.VchrNmbr = PH.VchrNmbr
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
WHERE 	RTRIM(PD.VchrNmbr) + '_' + RTRIM(CAST(DstSqNum AS Char(10))) NOT IN (SELECT RTRIM(VoucherNumber) + '_' + RTRIM(CAST(ItemNumber AS Char(10))) FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = 'AIS')


/*
SELECT 	DocType,
	PD.VchrNmbr,
	DocDate,
	DocNumbr,
	DstSqNum,
	CrdtAmnt,
	DebitAmt,
	DstIndx,
	AccountNumber,
	DistType,
	PD.VendorId,
	DistRef,
	RTRIM(PD.VchrNmbr) + '_' + RTRIM(CAST(DstSqNum AS Char(10))) AS KeyRecord
FROM 	AIS.DBO.PM10100 PD
	INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchNumWk
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'

SELECT RTRIM(VoucherNumber) + '_' + RTRIM(CAST(ItemNumber AS Char(10))) FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = 'AIS' order by 1
*/