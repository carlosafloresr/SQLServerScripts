CREATE VIEW View_EscrowTransactions
AS
SELECT	EscrowTransactionId
		,Source
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
		,'H' AS RecordType
FROM	EscrowTransactionsHistory
UNION
SELECT	EscrowTransactionId
		,Source
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
		,'A' AS RecordType
FROM	EscrowTransactions

