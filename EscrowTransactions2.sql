DECLARE	@CompanyId	Char(6),
	@EscrowType	Int

SET @CompanyId = 'AIS'
SET @EscrowType = 1

UPDATE	GPCustom.dbo.EscrowTransactions2
SET	ItemNumber	= GP.DstSqNum,
	AccountType	= GP.DistType,
	EnteredBy	= 'CFLORES',
	EnteredOn	= GETDATE(),
	ChangedBy	= 'CFLORES',
	ChangedOn	= GETDATE()
FROM	(SELECT 	DISTINCT PD.DocType,
			PD.VchrNmbr,
			DocDate,
			DocNumbr,
			DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			PD.VendorId,
			VendName,
			DistRef,
			'HISTORIC' AS DataTable
		FROM 	PM30600 PD
			INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.DocType = PH.DocType
			LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
		WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10) AND
			PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId) AND 
			PD.VchrNmbr NOT IN (SELECT VchrNmbr FROM PM10100)
		UNION
		-- WORK AP
		SELECT 	DISTINCT DocType,
			PD.VchrNmbr,
			DocDate,
			DocNumbr,
			DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			PD.VendorId,
			VendName,
			DistRef,
			'WORK' AS DataTable
		FROM 	PM10100 PD
			INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchNumWk
			LEFT JOIN PM00200 VE ON PD.VendorId = VE.VendorId
		WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10) AND
			PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10) AND
			PD.VchrNmbr NOT IN (SELECT VchrNmbr FROM PM20000)
		UNION
		-- OPEN AP
		SELECT 	DISTINCT PH.DocType,
			PD.VchrNmbr,
			DocDate,
			DocNumbr,
			DstSqNum,
			CrdtAmnt,
			DebitAmt,
			DstIndx,
			DistType,
			CASE WHEN CrdtAmnt <> 0 THEN 'Credit' ELSE 'Debit' END AS TranType,
			(CrdtAmnt + DebitAmt) * (CASE WHEN CrdtAmnt <> 0 THEN 1 ELSE -1 END) AS Amount,
			PH.VendorId,
			VendName,
			'' AS DistRef,
			'OPEN' AS DataTable
		FROM 	PM10100 PD
			INNER JOIN PM20000 PH ON PD.VchrNmbr = PH.VchrNmbr
			LEFT JOIN PM00200 VE ON PH.VendorId = VE.VendorId
		WHERE 	DstIndx IN (SELECT AccountIndex FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10) AND
			PD.VchrNmbr NOT IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND Fk_EscrowModuleId <> 10)
		) GP 
WHERE GPCustom.dbo.EscrowTransactions2.VoucherNumber = GP.VchrNmbr

/*

SELECT * FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = 'AIS' AND Fk_EscrowModuleId <> 10 ORDER BY ACCOUNTNUMBER
DELETE GPCustom.dbo.EscrowTransactions2 WHERE fk_escrowmoduleid=0
SELECT * FROM GPCustom.dbo.EscrowTransactions2 WHERE ItemNumber = 0 and source= 'ap'
select * from PM20000 where VchrNmbr IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions2 WHERE ItemNumber = 0)
select * from PM30200 where VchrNmbr IN (SELECT VoucherNumber FROM GPCustom.dbo.EscrowTransactions2 WHERE ItemNumber = 0)

SELECT * FROM PM10100 PD INNER JOIN PM20000 PH ON PD.VchrNmbr = PH.VchrNmbr
SELECT * FROM PM10100 PD INNER JOIN PM10000 PH ON PD.VchrNmbr = PH.VchrNmbr WHERE PH.VchrNmbr NOT IN (SELECT VchrNmbr FROM PM20000)


select * from GL00100 where ActIndx in (1776, 1777)
insert into gpcustom.dbo.EscrowTransactions
SELECT * FROM GPCustom.dbo.EscrowTransactions2
*/