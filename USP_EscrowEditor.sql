ALTER PROCEDURE USP_EscrowEditor
	@Company	Char(6),
	@Text 		Varchar(20)
AS
SELECT	EscrowTransactionId,
		Source,
		ModuleDescription AS EscrowType,
		VoucherNumber,
		AccountNumber,
		VendorId,
		DriverId,
		Amount,
		Comments,
		CONVERT(Char(10), PostingDate, 101) AS PostingDate
FROM 	EscrowTransactions
		INNER JOIN EscrowModules ON EscrowTransactions.Fk_EscrowModuleId = EscrowModules.EscrowModuleId
WHERE	CompanyId = RTRIM(@Company) AND
		RIGHT(VoucherNumber, LEN(RTRIM(@Text))) = RTRIM(@Text)
ORDER BY
	ModuleDescription,
	AccountNumber,
	PostingDate

-- EXECUTE USP_EscrowEditor 'AIS', '101'