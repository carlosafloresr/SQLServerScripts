UPDATE	GPCustom.dbo.EscrowTransactions
SET		ItemNumber = DAT.SEQNUMBR
FROM	(
		SELECT	SOP.SOPNUMBE
				,SOP.SEQNUMBR
				,SOP.CRDTAMNT
				,ESC.Amount
				,ESC.AccountNumber
				,ESC.EscrowTransactionId
				,ESC.ItemNumber
		FROM	SOP10102 SOP
				INNER JOIN GPCustom.dbo.EscrowTransactions ESC ON SOP.SOPNUMBE = ESC.VoucherNumber
				INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESC.Fk_EscrowModuleId = ESA.Fk_EscrowModuleId AND SOP.ACTINDX = ESA.AccountIndex AND ESC.CompanyId = ESC.CompanyId
		WHERE	ESC.Source IN ('AR','SO')
				AND ESC.ItemNumber IS Null
				AND ESC.CompanyId = DB_NAME()
		) DAT
WHERE	EscrowTransactions.EscrowTransactionId = DAT.EscrowTransactionId

DELETE	GPCustom.dbo.EscrowTransactions
WHERE	Source IN ('AR','SO')
		AND ItemNumber IS Null
		AND DeletedBy IS Null
		AND CompanyId = DB_NAME()
		AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM SOP10102)
		--AND EscrowTransactionId = 788919

/*
SELECT	*
FROM	GPCustom.dbo.EscrowTransactions
WHERE	Source IN ('AR','SO')
		AND ItemNumber IS Null
		AND DeletedBy IS Null

SELECT * FROM SOP10102 WHERE SOPNUMBE = '96-11090'

SELECT	*
FROM	GPCustom.dbo.EscrowTransactions
WHERE	Source IN ('AR','SO')
		AND ItemNumber IS Null
		AND DeletedBy IS Null
		AND CompanyId = DB_NAME()
		AND VoucherNumber NOT IN (SELECT SOPNUMBE FROM SOP10102)

UPDATE	GPCustom.dbo.EscrowTransactions
SET		AccountNumber = '0-00-1106',
		ItemNumber = 32768,
		Amount = -110
WHERE	EscrowTransactionId = 788918

DELETE	GPCustom.dbo.EscrowTransactions
WHERE	EscrowTransactionId = 777309
*/