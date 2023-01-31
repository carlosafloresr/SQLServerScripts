/*
SELECT VendorId, VendName, CASE WHEN VendStts = 1 THEN 'Active' WHEN VendStts = 2 THEN 'Inactive' ELSE 'Temporary' END AS Status, CASE WHEN Hold = 0 THEN 'No' ELSE 'Yes' END AS Hold FROM AIS.dbo.PM00200 WHERE VndClsId = 'DRV' ORDER BY VendName
-- select * from ais..pm00200 

SELECT * FROM EscrowTransactions WHERE VendorId = '7911'
SELECT * FROM imc..PM30200 WHERE VendorId = '7911'
SELECT * FROM View_OOS_Transactions WHERE VendorId = '7911'

SELECT * 
FROM	View_OOS_Transactions TR
		LEFT JOIN imc..PM30200 PM ON TR.Invoice = PM.DocNumbr AND TR.VendorId = PM.VendorId
		LEFT JOIN imc..PM30600 PD ON PM.VchrNmbr = PD.VchrNmbr AND PM.TrxSorce = PD.TrxSorce AND TR.CrdAcctIndex = PD.DstIndx AND TR.DeductionDate = PD.PstgDate AND TR.DeductionAmount = PD.CrdtAmnt
WHERE	TR.VendorId = '7911' AND
		TR.EscrowTransactionId = 0 AND
		PD.VchrNmbr IS NOT Null
*/
SELECT	TR.DeductionId,
		TR.Company,
		TR.VendorId,
		TR.Invoice,
		TR.Description,
		TR.DeductionDate,
		TR.DeductionAmount,
		TR.EscrowModuleId,
		TR.CreditAccount,
		TR.CrdAcctIndex,
		PM.VchrNmbr,
		PD.DstSqNum,
		PD.DSTINDX,
		TR.CreditAccount,
		PD.DISTTYPE,
		PM.DOCDATE,
		PM.PSTGDATE,
		TR.Trans_CreatedOn
FROM	View_OOS_Transactions TR
		LEFT JOIN DNJ..PM30200 PM ON TR.Invoice = PM.DocNumbr AND TR.VendorId = PM.VendorId
		LEFT JOIN DNJ..PM30600 PD ON PM.VchrNmbr = PD.VchrNmbr AND PM.TrxSorce = PD.TrxSorce AND TR.CrdAcctIndex = PD.DstIndx AND TR.DeductionAmount = PD.CrdtAmnt
WHERE	TR.VendorId = 'D10507'
		AND PM.VchrNmbr IS NOT Null
		AND TR.EscrowModuleId = 2
				
/*
SELECT	*
FROM	View_OOS_Transactions
WHERE	Vendorid = 'D10507'
		AND DeductionCode = 'STD'
		AND EscrowModuleId = 2
*/