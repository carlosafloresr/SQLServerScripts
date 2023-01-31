SELECT EscrowTransactionId, VoucherNumber FROM EscrowTransactions WHERE VoucherNumber in (
SELECT DISTINCT VoucherNumber FROM EscrowTransactions WHERE LEFT(VoucherNumber, 3) = 'ED_')


SELECT VoucherNumber, MIN(EscrowTransactionId) AS EscrowTransactionId FROM EscrowTransactions WHERE VoucherNumber in (
SELECT VoucherNumber FROM EscrowTransactions WHERE LEFT(VoucherNumber, 3) = 'ED_' GROUP BY VoucherNumber HAVING COUNT(VoucherNumber) > 1)
group by VoucherNumber