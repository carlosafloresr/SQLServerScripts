/* 
SELECT * FROM EscrowTransactions WHERE VendorId = '9585' AND VoucherNumber = 'OOTA9585080708A'
SELECT * FROM View_OOS_Transactions WHERE DeductionCode = 'OOTA' AND Company = 'IMC' AND VendorId = '9585'

SELECT	ES.PostingDate,
		OO.CreditAmount,
				ES.Amount,
				ES.EscrowTransactionId 
		FROM	EscrowTransactions ES
				INNER JOIN View_OOS_Transactions OO ON ES.CompanyId = OO.Company AND ES.VendorId = OO.VendorId AND ES.VoucherNumber = OO.Invoice
		WHERE	OO.CreditAmount <> ES.Amount
				AND OO.BatchId IN (SELECT MAX(BatchId) FROM View_OOS_Transactions WHERE Company = 'IMC')
*/

UPDATE	EscrowTransactions
SET		EscrowTransactions.Amount = OOS.CreditAmount
FROM	(SELECT	OO.CreditAmount,
				ES.Amount,
				ES.EscrowTransactionId 
		FROM	EscrowTransactions ES
				INNER JOIN View_OOS_Transactions OO ON ES.CompanyId = OO.Company AND ES.VendorId = OO.VendorId AND ES.VoucherNumber = OO.Invoice
		WHERE	OO.CreditAmount <> ES.Amount) OOS
WHERE	EscrowTransactions.EscrowTransactionId =  OOS.EscrowTransactionId