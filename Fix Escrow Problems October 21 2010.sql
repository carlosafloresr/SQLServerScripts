/*
SELECT COUNT(*) FROM EscrowTransactionsHistory
SELECT COUNT(*) FROM GPCustom_08032010..EscrowTransactionsHistory

DELETE	EscrowTransactionsHistory
WHERE	CompanyId = 'NDS'
		AND AccountNumber = '00-01-2794'
		AND FK_EscrowModuleId = 3
		
SELECT	SUM(ISNULL(Amount,0))
FROM	GPCustom_08032010..EscrowTransactionsHistory
WHERE	CompanyId = 'AIS'
		AND AccountNumber = '0-00-2795'
		--AND FK_EscrowModuleId = 3
--		--AND PostingDate = '10/18/2010'
		AND VoucherNumber = '13951'
		
UPDATE	EscrowTransactions
SET		TransactionDate = '10/18/2010', PostingDate = '10/18/2010'
WHERE	CompanyId = 'NDS'
		AND AccountNumber = '00-01-2794'
		AND FK_EscrowModuleId = 3
		AND PostingDate < '1/3/2010'
*/
--SELECT	VendorId,
--		SUM(Amount)
SELECT	*
FROM	View_EscrowTransactions
WHERE	CompanyId = 'AIS'
		--AND AccountNumber = '0-00-2795'
		AND RIGHT(RTRIM(VoucherNumber), 5) IN ('20677', '20736')
--GROUP BY VendorId
--HAVING SUM(Amount) <> 0

--PRINT (1302.74 - 1133.18) - 139