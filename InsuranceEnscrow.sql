INSERT INTO EscrowTransactions (
		Source,
		VoucherNumber,
		ItemNumber,
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber,
		AccountType,
		VendorId,
		Amount,
		TransactionDate,
		PostingDate,
		EnteredBy,
		EnteredOn,
		ChangedBy,
		ChangedOn)
SELECT	'AP' AS Source,
		VoucherNumber,
		ROW_NUMBER() OVER(ORDER BY VendorId) AS ItemNumber,
		'IMC',
		1,
		AccountNumber,
		6,
		VendorId,
		Amount,
		PostingDate,
		PostingDate,
		'CFLORES',
		GETDATE(),
		'APP_RECOVER',
		GETDATE()
FROM	InsuranceEnscrow

UPDATE EscrowTransactions SET Fk_EscrowModuleId = 3 WHERE EnteredBy = 'CFLORES' AND EnteredOn > '9/2/2008'