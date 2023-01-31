SELECT	CompanyId,
		VoucherNumber,
		VendorId,
		dbo.GetVendorName(CompanyId, VendorID) AS VendorName,
		Amount,
		PostingDate,
		Comments
FROM	EscrowTransactions
WHERE	Fk_EscrowModuleId = 8
		AND AccountNumber IN ('0-00-2793', '00-00-2793')
		AND PostingDate BETWEEN '01/01/2012' AND '12/31/2012'
		AND DeletedBy IS Null
		AND Amount > 0
ORDER BY
		CompanyId,
		VendorId
