ALTER PROCEDURE USP_EscrowInquiry
	@Company	Char(6),
	@EscrowType	Int,
	@Vendor		Char(10) = Null,
	@Balance	Numeric(19,5) OUTPUT
AS
SET	@Balance 	= (SELECT SUM(Amount * 1.000) FROM EscrowTransactions WHERE PostingDate IS NOT Null AND CompanyId = RTRIM(@Company) AND Fk_EscrowModuleId = @EscrowType AND (@Vendor IS Null OR VendorId = @Vendor))

SELECT	EscrowTransactionId,
	Source,
	VoucherNumber,
	AccountNumber,
	VendorId,
	DriverId,
	Amount,
	Comments,
	CONVERT(Char(10), PostingDate, 101) AS PostingDate
FROM 	EscrowTransactions
WHERE	PostingDate IS NOT Null AND
	CompanyId = RTRIM(@Company) AND
	Fk_EscrowModuleId = @EscrowType AND
	(@Vendor IS Null OR VendorId = @Vendor)
ORDER BY
	AccountNumber,
	PostingDate
GO

EXECUTE USP_EscrowInquiry 'AIS', 3

SELECT SUM(Amount * 1.000) FROM EscrowTransactions WHERE PostingDate IS NOT Null AND CompanyId = 'AIS' AND Fk_EscrowModuleId = 5