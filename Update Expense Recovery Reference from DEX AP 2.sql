UPDATE	ExpenseRecovery
SET		ExpenseRecovery.Vendor		= RECS.Vendor,
		ExpenseRecovery.Reference	= RECS.Reference,
		ExpenseRecovery.Chassis		= RECS.Chassis,
		ExpenseRecovery.InvDate		= RECS.InvDate,
		ExpenseRecovery.DataUpdated	= 1
FROM	(

		SELECT	ExpenseRecoveryId
				,AP.IntegrationsAPId
				,EX.Company
				,EX.VoucherNo
				,LEFT(RTRIM(AP.VendorId) + '-' + dbo.GetVendorName(EX.Company, AP.VendorId), 30) AS Vendor
				,ISNULL(EX.ProNumber, AP.ProNum) AS ProNumber
				,AP.DISTREF AS Reference
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
				,'Open' AS Status
				,EX.Notes
				,EX.ItemNumber
				,0 AS Closed
				,EX.Source
				,EX.RepairTypeText
				,EX.DriverTypeText
				,EX.DriverName
				,EX.RecoverableText
				,EX.Division
				,'Open' AS StatusText
				,EX.ATPAmount
				,EX.ATPDeductions
				,EX.StartingDate
				,EX.CreationDate
		FROM	ExpenseRecovery EX
				INNER JOIN ILSINT02.Integrations.dbo.Integrations_AP AP ON EX.VoucherNo = AP.VCHNUMWK AND EX.DocNumber = AP.DOCNUMBR AND EX.Company = AP.Company AND EX.GLAccount = AP.ACTNUMST
		WHERE	EX.DataUpdated = 1
				AND EX.Reference <> AP.DISTREF
				AND AP.DISTREF <> 'AP Credit'
		) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId

-- select top 100 * from ILSINT02.Integrations.dbo.Integrations_AP where integration = 'DXP'
-- SELECT * FROM ExpenseRecovery