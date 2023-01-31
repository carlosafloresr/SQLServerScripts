--ALTER PROCEDURE USP_FixOOSDifferences
--AS
--UPDATE	EscrowTransactions
--SET		EscrowTransactions.Amount = OOS.CreditAmount
--FROM	(SELECT	OO.CreditAmount,
--				ES.Amount,
--				ES.EscrowTransactionId 
--		FROM	EscrowTransactions ES
--				INNER JOIN View_OOS_Transactions OO ON ES.CompanyId = OO.Company AND ES.VendorId = OO.VendorId AND ES.VoucherNumber = OO.Invoice
--		WHERE	OO.CreditAmount <> ES.Amount) OOS
--WHERE	EscrowTransactions.EscrowTransactionId =  OOS.EscrowTransactionId

SELECT * FROM 
--UPDATE 
View_EscrowTransactions 
--SET PostingDate = '10/21/2010' 
WHERE --EnteredBy = 'ILSLISTENER'
--AND 
PostingDate IS NULL -- = '10/21/2010' 
--AND 
and ACCOUNTNUMBER = '0-01-2794'
 and coMPANYID = 'AIS'
AND VENDORID = 'A0413'
--AND DELETEDBY IS NOT NULL
ORDER BY vouchernumber

--UPDATE EscrowTransactions SET DeletedOn = GETDATE(), DeletedBy = 'cflores' WHERE EscrowTransactionId IN (420974, 420975)