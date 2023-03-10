UPDATE	ExpenseRecovery
SET		ExpenseRecovery.Vendor		= RECS.Vendor,
		ExpenseRecovery.Reference	= RECS.Reference,
		ExpenseRecovery.Chassis		= RECS.Chassis,
		ExpenseRecovery.InvDate		= RECS.InvDate
FROM	(
		SELECT	ExpenseRecoveryId
				,AP.IntegrationsAPId
				,EX.Company
				,EX.VoucherNo
				,LEFT(RTRIM(AP.VendorId) + '-' + dbo.GetVendorName(EX.Company, AP.VendorId), 30) AS Vendor
				,EX.ProNumber
				,AP.DISTREF AS Reference
				,EX.Expense
				,EX.Recovery
				,EX.DocNumber
				,EX.EffDate
				,AP.DocDate AS InvDate
				,EX.Trailer
				,AP.Container AS Chassis
				,EX.FailureReason
				,EX.Recoverable
				,EX.DriverId
				,EX.DriverType
				,EX.RepairType
				,EX.GLAccount
				,EX.RecoveryAction
				,EX.Status
				,EX.Notes
				,EX.ItemNumber
				,EX.Closed
				,EX.Source
				,EX.RepairTypeText
				,EX.DriverTypeText
				,EX.DriverName
				,EX.RecoverableText
				,EX.Division
				,EX.StatusText
				,EX.ATPAmount
				,EX.ATPDeductions
				,EX.StartingDate
				,EX.CreationDate
		FROM	ExpenseRecovery EX
				INNER JOIN ILSINT02.Integrations.dbo.Integrations_AP AP ON EX.VoucherNo = AP.VCHNUMWK AND EX.DocNumber = AP.DOCNUMBR AND EX.Company = AP.Company
		WHERE	EX.Vendor = 'DEX Upload'
		) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
--WHERE	AP.PopUpId IS NOT NULL
/*
SELECT	*
FROM	GPCustom.dbo.DEX_ER_PopUps ER
WHERE	Er.Vendor = 'DEX Upload'
*/