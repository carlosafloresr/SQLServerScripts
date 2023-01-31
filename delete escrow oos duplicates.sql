SET NOCOUNT OFF

DECLARE	@PayrollDate	Datetime,
		@JustDisplay	Bit

SET		@PayrollDate	= '12/22/2016'
SET		@JustDisplay	= 0

IF @JustDisplay = 1
BEGIN
	SELECT	EscrowTransactionId
	FROM	(
			SELECT	VoucherNumber
					,MAX(EscrowTransactionId) AS EscrowTransactionId
			FROM	EscrowTransactions
			WHERE	VoucherNumber IN (	SELECT	VoucherNumber
										FROM	(
												SELECT	CompanyId
														,Source
														,VoucherNumber
														,ItemNumber
														,Fk_EscrowModuleId
														,AccountNumber
														,VendorId
														,Amount
														,COUNT(VoucherNumber) AS Counter
												FROM	EscrowTransactions 
												WHERE	BatchId IS NOT Null
														AND TransactionDate >= @PayrollDate
												GROUP BY
														CompanyId
														,Source
														,VoucherNumber
														,ItemNumber
														,Fk_EscrowModuleId
														,AccountNumber
														,VendorId
														,Amount
												HAVING	COUNT(VoucherNumber) > 1
												) RECS
										)
			GROUP BY VoucherNumber
			) RECS
END
ELSE
BEGIN
	DELETE	EscrowTransactions
	WHERE	EscrowTransactionId IN (
									SELECT	EscrowTransactionId
									FROM	(
											SELECT	VoucherNumber
													,MAX(EscrowTransactionId) AS EscrowTransactionId
											FROM	EscrowTransactions
											WHERE	VoucherNumber IN (	SELECT	VoucherNumber
																		FROM	(
																				SELECT	CompanyId
																						,Source
																						,VoucherNumber
																						,ItemNumber
																						,Fk_EscrowModuleId
																						,AccountNumber
																						,VendorId
																						,Amount
																						,COUNT(VoucherNumber) AS Counter
																				FROM	EscrowTransactions 
																				WHERE	BatchId IS NOT Null
																						AND TransactionDate >= @PayrollDate
																				GROUP BY
																						CompanyId
																						,Source
																						,VoucherNumber
																						,ItemNumber
																						,Fk_EscrowModuleId
																						,AccountNumber
																						,VendorId
																						,Amount
																				HAVING	COUNT(VoucherNumber) > 1
																				) RECS
																		)
											GROUP BY VoucherNumber
											) RECS
									)
END