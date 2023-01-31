INSERT INTO ExpenseRecovery
		([Company]
		,[VoucherNo]
		,[Vendor]
		,[ProNumber]
		,[Reference]
		,[Expense]
		,[Recovery]
		,[DocNumber]
		,[EffDate]
		,[InvDate]
		,[Trailer]
		,[Chassis]
		,[FailureReason]
		,[Recoverable]
		,[DriverId]
		,[DriverType]
		,[RepairType]
		,[GLAccount]
		,[RecoveryAction]
		,[Status]
		,[Notes]
		,[ItemNumber]
		,[Closed]
		,[Source]
		,[RepairTypeText]
		,[DriverTypeText]
		,[DriverName]
		,[RecoverableText]
		,[Division]
		,[StatusText]
		,[ATPAmount]
		,[ATPDeductions]
		,[StartingDate]
		,[CreationDate])
SELECT	ER.Company
		,ISNULL(ER.VoucherNo, VCHNUMWK)
		,LEFT(dbo.GetVendorName(ER.Company, AP.VendorId), 30) AS Vendor
		,ISNULL(ER.ProNumber, AP.ProNum)
		,ISNULL(ER.Reference, DISTREF)
		,ER.Expense
		,ER.Recovery
		,ER.DocNumber
		,PSTGDATE AS EffDate
		,ISNULL(ER.InvDate, DOCDATE)
		,ER.Trailer
		,CASE WHEN LEN(RTRIM(ER.Chassis)) > 11 THEN NULL ELSE ER.Chassis END AS Chassis
		,LTRIM(dbo.PROPER(SUBSTRING(ISNULL(ER.Reference, DISTREF), dbo.RAT('|', ISNULL(ER.Reference, DISTREF), 1) + 1, 20))) AS FailureReason
		,ER.Recoverable
		,ER.DriverId
		,ER.DriverType
		,ER.RepairType
		,ER.GLAccount
		,ER.RecoveryAction
		,ER.Status
		,NULL AS Notes
		,ER.ItemNumber
		,ER.Closed
		,ER.Source
		,ER.RepairTypeText
		,ER.DriverTypeText
		,ER.DriverName
		,ER.RecoverableText
		,ER.Division
		,ER.StatusText
		,ER.ATPAmount
		,ER.ATPDeductions
		,ER.StartingDate
		,ER.CreationDate
FROM	DEX_ER_PopUps ER
		INNER JOIN ILSINT02.Integrations.dbo.Integrations_AP AP ON ER.DEX_ER_PopUpsId = AP.PopUpId AND ER.GLAccount = AP.ACTNUMST
WHERE	AP.DOCNUMBR IN ('458992')
		AND AP.PopUpId > 0

--SELECT	*
--FROM	ExpenseRecovery
--WHERE	PopUpId > 0