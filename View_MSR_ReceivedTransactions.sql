CREATE VIEW View_MSR_ReceivedTransactions
AS
SELECT	MSR_ReceivedTransactions
		,Company
		,BatchId
		,DocNumber
		,Description
		,DocDate
		,Customer
		,DocType
		,Amount
		,Account
		,Credit
		,Debit
		,VoucherNumber
		,LineItem
		,Verification
		,Processed
		,Container
		,Chassis
		,dbo.IsCustomerIntercompany(Company, Customer, '11000') AS Intercompany
FROM	MSR_ReceviedTransactions
