/*
SELECT * FROM PM30200 WHERE VendorId = 'G9371' AND Voided = 1 AND VoidPDate = CONVERT(Char(10), GETDATE(), 101)
SELECT * FROM PM30200 WHERE VchrNmbr = '00000000000007156'
*/
ALTER PROCEDURE dbo.USP_Void_PMTransactions
		@VendorId	Varchar(12),
		@UserId		Varchar(25),
		@CompanyId	Varchar(5)
AS
DECLARE	@RecordId	Int

DECLARE PMVoided CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	EST.EscrowTransactionId AS RecordId
FROM	(SELECT	DISTINCT ESA.AccountNumber
				,PMD.VchrNmbr
				,PMD.DstSqNum
		FROM	PM30600 PMD
				INNER JOIN PM30200 PMH ON PMD.VchrNmbr = PMH.VchrNmbr AND PMD.TrxSorce = PMH.TrxSorce
				INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON PMD.DstIndx = ESA.AccountIndex AND ESA.CompanyId = DB_NAME()
		WHERE	PMD.VendorId = @VendorId
				AND LEFT(PMD.TrxSorce, 5) = 'PMTRX'
				AND PMH.Voided = 1 
				AND PMH.VoidPDate = CAST(GETDATE() AS Date)) RECS
		INNER JOIN GPCustom.dbo.EscrowTransactions EST ON EST.CompanyId = DB_NAME() AND RECS.AccountNumber = EST.AccountNumber AND RECS.VchrNmbr = EST.VoucherNumber AND RECS.DstSqNum = EST.ItemNumber AND EST.Void = 0
		LEFT JOIN GPCustom.dbo.EscrowTransactions ESV ON ESV.CompanyId = DB_NAME() AND RECS.AccountNumber = ESV.AccountNumber AND RECS.VchrNmbr = ESV.VoucherNumber AND RECS.DstSqNum = EST.ItemNumber AND ESV.Void = 1
WHERE	ESV.Void IS Null

OPEN PMVoided 
FETCH FROM PMVoided INTO @RecordId

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO GPCustom.dbo.EscrowTransactions (
			Source,
			VoucherNumber,
			ItemNumber,
			CompanyId,
			Fk_EscrowModuleId,
			AccountNumber,
			AccountType,
			VendorId,
			DriverId,
			Division,
			Amount,
			ClaimNumber,
			DriverClass,
			AccidentType,
			Status,
			DMSubmitted,
			DeductionPlan,
			Comments,
			ProNumber,
			TransactionDate,
			PostingDate,
			EnteredBy,
			EnteredOn,
			ChangedBy,
			ChangedOn,
			Void)
	SELECT	Source,
			VoucherNumber,
			ItemNumber,
			CompanyId,
			Fk_EscrowModuleId,
			AccountNumber,
			AccountType,
			VendorId,
			DriverId,
			Division,
			Amount * -1,
			ClaimNumber,
			DriverClass,
			AccidentType,
			Status,
			DMSubmitted,
			DeductionPlan,
			'Void Transaction',
			ProNumber,
			TransactionDate,
			GETDATE(),
			EnteredBy,
			EnteredOn,
			@UserId,
			GETDATE(),
			1
	FROM	GPCustom.dbo.EscrowTransactions
	WHERE	EscrowTransactionId = @RecordId

	IF @@ERROR = 0
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		Void = 1
		WHERE	EscrowTransactionId = @RecordId
	END

	FETCH FROM PMVoided INTO @RecordId
END

CLOSE PMVoided
DEALLOCATE PMVoided

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN 1
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN -1
END

/*
SELECT	* 
FROM	GPCustom.dbo.EscrowTransactions 
WHERE	VendorId = '1'

EXECUTE USP_Void_PMTransactions 1, 'CFLORES'
*/