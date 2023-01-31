INSERT INTO EscrowTransactions
			(Source
			,VoucherNumber
			,ItemNumber
			,CompanyId
			,Fk_EscrowModuleId
			,AccountNumber
			,AccountType
			,VendorId
			,DriverId
			,Division
			,Amount
			,ClaimNumber
			,DriverClass
			,AccidentType
			,Status
			,DMSubmitted
			,DeductionPlan
			,Comments
			,ProNumber
			,TransactionDate
			,PostingDate
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,BatchId)
	SELECT	Source
			,'EFSMC_00' + RTRIM(DocNumber)  AS VoucherNumber
			,16384 AS ItemNumber
			,CompanyId
			,Fk_EscrowModuleId
			,AccountNumber
			,AccountType
			,VendorId
			,DriverId
			,Division
			,Amount
			,ClaimNumber
			,DriverClass
			,AccidentType
			,Status
			,DMSubmitted
			,DeductionPlan
			,Comments
			,ProNumber
			,TransactionDate
			,'08/27/2019' AS PSTGDATE
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,BatchId
	FROM	GPCustom.dbo.DEX_ET_PopUps DEX
			--INNER JOIN (
			--			SELECT	PopUpId,
			--					JrnEntry,
			--			FROM	ILSINT02.Integrations.dbo.Integrations_GL 
			--			WHERE	JrnEntry = 488562
			--			) APP ON DEX.DEX_ET_PopUpsId = APP.PopUpId
	WHERE	DEX.BatchId = 'EFSMC_08262019'


/*
UPDATE	EscrowTransactions
SET		VoucherNumber = DATA.Voucher
FROM	(
SELECT	EscrowTransactionId,
		'MC_08262019_' + dbo.PADL(ROW_NUMBER() OVER (ORDER BY SOURCE), 3, '0') AS Voucher
FROM	EscrowTransactions
WHERE	BATCHID = 'EFSMC_08262019'
		AND CompanyId = 'DNJ'
		) DATA
WHERE	EscrowTransactions.EscrowTransactionId = DATA.EscrowTransactionId
*/