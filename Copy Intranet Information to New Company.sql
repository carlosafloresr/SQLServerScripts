/*
-- Copy Escrow Accounts to the New Company
INSERT INTO EscrowAccounts
		(CompanyId
		,Fk_EscrowModuleId
		,AccountIndex
		,AccountNumber
		,AccountAlias
		,RemittanceAdvise
		,Nature
		,ShortCode
		,Increase)
SELECT	'DNJ'
		,Fk_EscrowModuleId
		,AccountIndex
		,AccountNumber
		,AccountAlias
		,RemittanceAdvise
		,Nature
		,ShortCode
		,Increase 
FROM	EscrowAccounts 
WHERE	CompanyId = 'GIS'

-- Update Great Plains Account Index
UPDATE 	EscrowAccounts
SET 	AccountIndex = GL00100.ActIndx
FROM	DNJ.dbo.GL00100 GL00100
WHERE	EscrowAccounts.AccountNumber = RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + RTRIM(ActNumbr_3) AND
		EscrowAccounts.CompanyId = 'DNJ'

-- Copy Escrow Deduction Types to the New Company
INSERT INTO OOS_DeductionTypes
		(Company
		,DeductionCode
		,Description
		,CrdAccounts
		,DebAccounts
		,CrdAcctIndex
		,CreditAccount
		,CreditPercentage
		,CrdAcctIndex2
		,CreditAccount2
		,CreditPercentage2
		,DebAcctIndex
		,DebitAccount
		,DebitPercentage
		,DebAcctIndex2
		,DebitAccount2
		,DebitPercentage2
		,MaintainBalance
		,EscrowBalance
		,Frequency
		,DrayageRequired
		,AutoCreate
		,Inactive
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn)
SELECT	'DNJ'
		,DeductionCode
		,Description
		,CrdAccounts
		,DebAccounts
		,CrdAcctIndex
		,CreditAccount
		,CreditPercentage
		,CrdAcctIndex2
		,CreditAccount2
		,CreditPercentage2
		,DebAcctIndex
		,DebitAccount
		,DebitPercentage
		,DebAcctIndex2
		,DebitAccount2
		,DebitPercentage2
		,MaintainBalance
		,EscrowBalance
		,Frequency
		,DrayageRequired
		,AutoCreate
		,Inactive
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn 
FROM	OOS_DeductionTypes 
WHERE	Company = 'GIS'

-- Update Great Plains Account Index on Credit Account 1
UPDATE 	OOS_DeductionTypes
SET 	CrdAcctIndex = GL00100.ActIndx
FROM	DNJ.dbo.GL00100 GL00100
WHERE	OOS_DeductionTypes.CreditAccount = RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + RTRIM(ActNumbr_3) AND
		OOS_DeductionTypes.Company = 'DNJ'

-- Update Great Plains Account Index on Credit Account 2
UPDATE 	OOS_DeductionTypes
SET 	CrdAcctIndex2 = GL00100.ActIndx
FROM	DNJ.dbo.GL00100 GL00100
WHERE	OOS_DeductionTypes.CreditAccount2 = RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + RTRIM(ActNumbr_3) AND
		OOS_DeductionTypes.Company = 'DNJ'

-- Update Great Plains Account Index on Debit Account 1
UPDATE 	OOS_DeductionTypes
SET 	DebAcctIndex = GL00100.ActIndx
FROM	DNJ.dbo.GL00100 GL00100
WHERE	OOS_DeductionTypes.DebitAccount = RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + RTRIM(ActNumbr_3) AND
		OOS_DeductionTypes.Company = 'DNJ'

-- Update Great Plains Account Index on Debit Account 2
UPDATE 	OOS_DeductionTypes
SET 	DebAcctIndex2 = GL00100.ActIndx
FROM	DNJ.dbo.GL00100 GL00100
WHERE	OOS_DeductionTypes.DebitAccount2 = RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + RTRIM(ActNumbr_3) AND
		OOS_DeductionTypes.Company = 'DNJ'

-- Copy Driver Deduction to the New Company
INSERT INTO OOS_Deductions
		(Fk_OOS_DeductionTypeId
		,Vendorid
		,StartDate
		,DeductionAmount
		,Frequency
		,MaxDeduction
		,NumberOfDeductions
		,Perpetual
		,Inactive
		,Completed
		,Notes
		,CurrentDeductions
		,Deducted
		,DeductionNumber
		,Balance
		,LastBatchId
		,LastAmount
		,LastPeriod
		,CreatedOn
		,CreatedBy
		,ModifiedOn
		,ModifiedBy)
SELECT	DED2.OOS_DeductionTypeId
		,DRVS.VendorId
		,OOS.StartDate
		,OOS.DeductionAmount
		,OOS.Frequency
		,OOS.MaxDeduction
		,OOS.NumberOfDeductions
		,OOS.Perpetual
		,OOS.Inactive
		,OOS.Completed
		,OOS.Notes
		,OOS.CurrentDeductions
		,OOS.Deducted
		,OOS.DeductionNumber
		,OOS.Balance
		,OOS.LastBatchId
		,OOS.LastAmount
		,OOS.LastPeriod
		,OOS.CreatedOn
		,OOS.CreatedBy
		,OOS.ModifiedOn
		,OOS.ModifiedBy
FROM	OOS_Deductions OOS
		INNER JOIN OOS_DeductionTypes DED1 ON DED1.OOS_DeductionTypeId = OOS.Fk_OOS_DeductionTypeId AND DED1.Company = 'IMC'
		INNER JOIN OOS_DeductionTypes DED2 ON DED1.DeductionCode = DED2.DeductionCode AND DED2.Company = 'GIS'
		INNER JOIN GIS_Drivers DRVS ON 'G' + OOS.VendorId = DRVS.VendorId

INSERT INTO EscrowTransactions
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
		,OtherStatus)
SELECT	Source
		,ESC.VoucherNumber
		,ESC.ItemNumber
		,'GIS' AS CompanyId
		,ESC.Fk_EscrowModuleId
		,ESC.AccountNumber
		,ESC.AccountType
		,DRV.VendorId
		,ESC.DriverId
		,ESC.Division
		,ESC.Amount
		,ESC.ClaimNumber
		,ESC.DriverClass
		,ESC.AccidentType
		,ESC.Status
		,ESC.DMSubmitted
		,ESC.DeductionPlan
		,ESC.Comments
		,ESC.ProNumber
		,ESC.TransactionDate
		,ESC.PostingDate
		,ESC.EnteredBy
		,ESC.EnteredOn
		,ESC.ChangedBy
		,ESC.ChangedOn
		,ESC.Void
		,ESC.InvoiceNumber
		,ESC.OtherStatus
FROM	EscrowTransactions ESC
		INNER JOIN GIS_Drivers DRV ON 'G' + ESC.VendorId = DRV.VendorId
WHERE	CompanyId = 'IMC'
*/