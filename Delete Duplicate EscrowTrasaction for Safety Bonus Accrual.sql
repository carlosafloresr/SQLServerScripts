SELECT	CompanyId,
		VendorId,
		Amount,
		Comments,
		EnteredOn,
		COUNT(*) AS Counter,
		MIN(EscrowTransactionId) AS EscrowTransactionId
INTO	#tmpData
FROM	ESCROWTRANSACTIONS
WHERE	COMPANYID = 'DNJ'
		AND ACCOUNTNUMBER = '0-04-2200'
		AND Comments LIKE 'Safety Bonus Accrual Drv%'
GROUP BY
		CompanyId,
		VendorId,
		Amount,
		Comments,
		EnteredOn
HAVING COUNT(*) > 1
ORDER BY Comments


DELETE	EscrowTransactions
FROM	(
		SELECT	ESW.EscrowTransactionId
		FROM	EscrowTransactions ESW
				INNER JOIN #tmpData TMP ON ESW.CompanyId = TMP.CompanyId AND ESW.VendorId = TMP.VendorId AND ESW.Comments = TMP.Comments AND ESW.Amount = TMP.Amount AND ESW.EscrowTransactionId > TMP.EscrowTransactionId
		) DATA
WHERE	EscrowTransactions.EscrowTransactionId = DATA.EscrowTransactionId

DROP TABLE #tmpData