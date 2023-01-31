/*
SELECT	* 
FROM	ILSINT02.Integrations.dbo.Integrations_AP 
WHERE	Integration = 'RSA'
		AND BatchId = 'RSA201601191332'
*/
--INSERT INTO ExpenseRecovery
--		(Company
--		,voucherno
--		,vendor
--		,pronumber
--		,reference
--		,expense
--		,recovery
--		,docnumber
--		,effdate
--		,invdate
--		,trailer
--		,chassis
--		,FailureReason
--		,Recoverable
--		,DriverId
--		,DriverType
--		,repairtype
--		,glaccount
--		,RecoveryAction
--		,Status
--		,StatusText
--		,Closed
--		,Source
--		,PopUpId
--		,BatchId)
SELECT	ERC.Company
		,ERC.VCHNUMWK
		,LEFT(RTRIM(ERC.VendorId) + ' - ' + dbo.GetVendorName(ERC.Company, ERC.VendorId), 30) AS Vendor
		,ERC.ProNum
		,Null AS Reference
		,ERC.DEBITAMT AS Expense
		,0 AS Recovery
		,ERC.DocNumbr AS DocNumber
		,ERC.PSTGDATE AS EffDate
		,ERC.DocDate AS InvDate
		,ERC.Container AS Trailer
		,ERC.Chassis
		,ERC.DistRef
		,'Y' AS Recoverable
		,ERC.DriverId
		,Null AS DriverType
		,LEFT(ERA.RepairType, 1) AS RepairType
		,ERC.ACTNUMST
		,Null AS RecoveryAction
		,'Open'
		,'Open'
		,0
		,'AP'
		,ERC.PopUpId
		,ERC.BatchId
		,ERT.ExpenseRecoveryId
FROM	ILSINT02.Integrations.dbo.Integrations_AP ERC
		INNER JOIN ExpenseRecoveryAccounts ERA ON RIGHT(RTRIM(ERC.ACTNUMST), 4) = ERA.Account
		LEFT JOIN ExpenseRecovery ERT ON ERC.DocNumbr = ERT.DocNumber AND ERC.DEBITAMT = ERT.Expense
WHERE	ERC.Integration = 'RSA'
		AND ERC.BatchId = 'RSA201601191332'

SELECT * FROM ExpenseRecovery WHERE ExpenseRecoveryId = 79181