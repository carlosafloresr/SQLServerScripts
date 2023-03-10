/*
SELECT * FROM gpcUSTOM.DBO.EscrowTransactions WHERE VoucherNumber = '00000000000003372'
SELECT	* 
FROM	IMC.dbo.PM10100 WHERE VchrNmbr = 'CARLOS1'

EXECUTE USP_AP_FixEscrow 'AIS', '0018976'
*/
alter PROCEDURE [dbo].[USP_AP_FixEscrow]
		@CompanyId	Char(6),
		@Voucher	Varchar(25)
AS
UPDATE	GPCustom.dbo.EscrowTransactions
SET		Amount		= FX.AP_AccountNumber,
		AccountType	= FX.DistType
FROM	(
		SELECT	PM.VchrNmbr,
				PM.DstSqNum,
				PM.CrdtAmnt,
				PM.DebitAmt,
				PM.DstIndx,
				PM.VendorId,
				PM.DistType,
				EA.AccountNumber AS AP_AccountNumber,
				ET.AccountNumber AS ES_AccountNumber,
				CASE WHEN PM.CrdtAmnt > 0 THEN PM.CrdtAmnt * CASE WHEN EA.Increase = 'C' THEN 1 ELSE -1 END
				ELSE PM.DebitAmt * CASE WHEN EA.Increase = 'D' THEN 1 ELSE -1 END END AS AP_Amount,
				ET.Amount,
				ET.EscrowTransactionId
		FROM	PM10100 PM 
				INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PM.DstIndx = EA.AccountIndex AND EA.CompanyId = @CompanyId
				LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON PM.VchrNmbr = ET.VoucherNumber AND PM.DstSqNum = ET.ItemNumber AND ET.CompanyId = @CompanyId
		WHERE	PM.VchrNmbr = @Voucher AND
				EA.AccountNumber <> ET.AccountNumber
		) FX
WHERE	EscrowTransactions.EscrowTransactionId = FX.EscrowTransactionId

--DELETE	GPCustom.dbo.EscrowTransactions
--WHERE	EscrowTransactionId IN (
--SELECT	EscrowTransactionId
--FROM	GPCustom.dbo.EscrowTransactions ET
--		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND EA.CompanyId = @CompanyId
--		LEFT JOIN PM10100 PM ON ET.ItemNumber = PM.DstSqNum AND PM.VchrNmbr = ET.VoucherNumber
--WHERE	ET.CompanyId = @CompanyId AND
--		ET.VoucherNumber = @Voucher AND
--		EA.AccountIndex <> PM.DstIndx)