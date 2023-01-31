DECLARE	@tblRecord	Table (RecordId Int)

DECLARE	@DateIni	Date = '01/01/2014',
		@DateEnd	Date = '12/31/2015',
		@MoveData	Bit = 0

INSERT INTO @tblRecord
SELECT	EST.EscrowTransactionId
FROM	EscrowTransactions EST
		LEFT JOIN EscrowTransactionsHistory ETH ON EST.CompanyId = ETH.CompanyId AND EST.VoucherNumber = ETH.VoucherNumber AND EST.Source = ETH.Source AND EST.VendorId = ETH.VendorId
WHERE	EST.EnteredOn BETWEEN @DateIni AND @DateEnd
		AND ETH.Source IS NOT Null

IF @@ROWCOUNT > 0
BEGIN
	IF @MoveData = 0
	BEGIN
		SELECT	*
		FROM	EscrowTransactions
		WHERE	EscrowTransactionId IN (SELECT RecordId FROM @tblRecord)

		SELECT	ETH.*
		FROM	EscrowTransactions EST
				LEFT JOIN EscrowTransactionsHistory ETH ON EST.CompanyId = ETH.CompanyId AND EST.VoucherNumber = ETH.VoucherNumber AND EST.Source = ETH.Source AND EST.VendorId = ETH.VendorId
		WHERE	EST.EscrowTransactionId IN (SELECT RecordId FROM @tblRecord)
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION

		INSERT INTO GPCustom.dbo.EscrowTransactionsHistory
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
				,OtherStatus
				,DeletedBy
				,DeletedOn
				,BatchId
				,SOPDocumentNumber
				,UnitNumber
				,RepairDate
				,ETA
				,PopUpId)
		SELECT	EST.Source
				,EST.VoucherNumber
				,EST.ItemNumber
				,EST.CompanyId
				,EST.Fk_EscrowModuleId
				,EST.AccountNumber
				,EST.AccountType
				,EST.VendorId
				,EST.DriverId
				,EST.Division
				,EST.Amount
				,EST.ClaimNumber
				,EST.DriverClass
				,EST.AccidentType
				,EST.Status
				,EST.DMSubmitted
				,EST.DeductionPlan
				,EST.Comments
				,EST.ProNumber
				,EST.TransactionDate
				,EST.PostingDate
				,EST.EnteredBy
				,EST.EnteredOn
				,EST.ChangedBy
				,EST.ChangedOn
				,EST.Void
				,EST.InvoiceNumber
				,EST.OtherStatus
				,EST.DeletedBy
				,EST.DeletedOn
				,EST.BatchId
				,EST.SOPDocumentNumber
				,EST.UnitNumber
				,EST.RepairDate
				,EST.ETA
				,EST.PopUpId
		FROM	EscrowTransactions EST
		WHERE	EST.EscrowTransactionId IN (SELECT RecordId FROM @tblRecord)

		IF @@ERROR = 0
		BEGIN
			DELETE	EscrowTransactions
			WHERE	EscrowTransactionId IN (SELECT RecordId FROM @tblRecord)

			IF @@ERROR = 0
				COMMIT TRANSACTION
			ELSE
				ROLLBACK TRANSACTION
		END
		ELSE
			ROLLBACK TRANSACTION
	END
END