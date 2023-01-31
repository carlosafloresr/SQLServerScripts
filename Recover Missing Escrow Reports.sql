UPDATE	EscrowTransactions
SET		VoucherNumber = RTRIM(VoucherNumber) + 'b'
WHERE	CompanyId = 'GSA'
		and VoucherNumber in (
		SELECT	VoucherNumber
		FROM	LENSASQL001T.GPCustom.dbo.EscrowTransactions
		WHERE	CompanyId = 'GSA'
				AND LEN(VoucherNumber) = 5
				AND REPLACE(VoucherNumber, ',', '') IN (
										SELECT	JRNENTRY
										FROM	GSA.dbo.GL30000
										WHERE	JRNENTRY IN (
															SELECT	VoucherNumber
															FROM	EscrowTransactions
															WHERE	CompanyId = 'GSA'
																	AND ChangedOn > '04/22/2016'
																	AND Source = 'GL')
												AND JRNENTRY IN (SELECT	JRNENTRY
																FROM	GSA.dbo.GL20000
																WHERE	JRNENTRY IN (
																					SELECT	VoucherNumber
																					FROM	EscrowTransactions
																					WHERE	CompanyId = 'GSA'
																							AND ChangedOn > '04/22/2016'
																							AND Source = 'GL')))
																							)