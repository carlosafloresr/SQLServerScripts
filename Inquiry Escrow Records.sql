SELECT	EscrowTransactions.*,
		DeductionCode
FROM	EscrowTransactions
		LEFT JOIN OOS_DeductionTypes ON LEFT(Comments, dbo.AT(' ', LEFT(Comments, 10), 1)) = DeductionCode AND Company = 'DNJ'
WHERE	CompanyId = 'DNJ'
		AND EnteredBy = 'cflores'
		AND PostingDate IS Null
/*
SELECT	EscrowTransactions.*,
		DeductionCode
FROM	EscrowTransactions
		LEFT JOIN OOS_DeductionTypes ON LEFT(Comments, dbo.AT(' ', LEFT(Comments, 10), 1)) = DeductionCode AND Company = 'IMC'
WHERE	CompanyId = 'NDS'
		AND Fk_EscrowModuleId = 3
		AND VendorId = 'N10022'
		--AND PostingDate = '09/28/2010'
		--AND EnteredBy = 'ILSRecovery'
		--AND AccountNumber = '0-00-1102'
		--AND LEFT(Comments, dbo.AT(' ', LEFT(Comments, 10), 1) > 0
*/
/*
SELECT	*
FROM	OOS_DeductionTypes
WHERE	Company = 'DNJ'

SELECT	EscrowTransactions.*,
		DeductionCode
FROM	delete EscrowTransactions
		--LEFT JOIN OOS_DeductionTypes ON LEFT(Comments, dbo.AT(' ', LEFT(Comments, 10), 1)) = DeductionCode AND Company = 'DNJ'
WHERE	CompanyId = 'DNJ'
		AND Fk_EscrowModuleId = 3
		AND PostingDate = '06/24/2010'
		AND EnteredBy = 'ILSRecovery'
		AND AccountNumber = '0-00-2795'
		--AND LEFT(Comments, dbo.AT(' ', LEFT(Comments, 10), 1) > 0
*/