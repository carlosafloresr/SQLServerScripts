USE [GPCustom]
GO

/****** Object:  View [dbo].[View_OOS_Transactions]    Script Date: 8/30/2017 10:11:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT	*
FROM	View_OOS_Transactions
WHERE	BatchId = 'OOSNDS_070617'
ORDER BY Voucher
*/
ALTER VIEW [dbo].[View_OOS_Transactions]
AS
SELECT	DE.OOS_DeductionId AS DeductionId, 
		DT.Company, 
		DE.Vendorid, 
		DE.Fk_OOS_DeductionTypeId AS DeductionTypeId, 
		DE.StartDate, 
		DE.DeductionAmount AS AmountToDeduct,
		DE.MaxDeduction, 
		DE.NumberOfDeductions, 
		DE.Perpetual, 
		DE.Inactive AS DeductionInactive, 
		DE.Notes, 
		DE.CurrentDeductions, 
		DE.Deducted,
		DE.DeductionNumber AS LastDeductionNumber,
		DE.Balance, 
		DE.LastBatchId, 
		DE.LastAmount, 
		DE.CreatedOn AS Deduction_CreatedOn, 
		DE.CreatedBy AS Deduction_CreatedBy, 
		DE.ModifiedOn AS Deduction_ModifiedOn, 
		DE.ModifiedBy AS Deduction_ModifiedBy,
		DT.DeductionCode, 
		DT.Description AS DeductionType,
		DT.CrdAccounts,
		DT.DebAccounts,
		DT.CrdAcctIndex, 
		dbo.MaskGLAccount(DT.CreditAccount, CO.WithAgents, DT.CreditMaskAgent, DT.CreditMaskDivision) AS CreditAccount,
		DT.CreditPercentage,
		CASE WHEN DT.CreditPercentage < 100 THEN ROUND(TR.DeductionAmount * (DT.CreditPercentage / 100), 2) ELSE TR.DeductionAmount END AS CreditAmount,
		DT.CrdAcctIndex2,
		DT.CreditAccount2,
		DT.CreditPercentage2,
		CASE WHEN DT.CreditPercentage < 100 THEN TR.DeductionAmount - ROUND(TR.DeductionAmount * (DT.CreditPercentage / 100), 2) ELSE 0.0 END AS CreditAmount2,
		DT.DebAcctIndex, 
		dbo.MaskGLAccount(DT.DebitAccount, CO.WithAgents, DT.DebitMaskAgent, DT.DebitMaskDivision) AS DebitAccount,
		DT.DebitPercentage,
		CASE WHEN DT.DebitPercentage < 100 THEN ROUND(TR.DeductionAmount * (DT.DebitPercentage / 100), 2) ELSE TR.DeductionAmount END AS DebitAmount,
		DT.DebAcctIndex2,
		DT.DebitAccount2,
		DT.DebitPercentage2,
		CASE WHEN DT.DebitPercentage < 100 THEN TR.DeductionAmount - ROUND(TR.DeductionAmount * (DT.DebitPercentage / 100), 2) ELSE 0.0 END AS DebitAmount2,
		DT.Frequency,
		ISNULL(EM.EscrowModuleId, 0) AS EscrowModuleId,
		ISNULL(EM.ModuleDescription, '') AS ModuleDescription,
		ISNULL(EM.Inactive, 0) AS EscrowModuleInactive,
		DT.Inactive AS DeductionTypeInactive, 
		DT.CreatedBy AS DedType_CreatedBy, 
		DT.CreatedOn AS DedType_CreatedOn, 
		DT.ModifiedBy AS DedType_ModifiedBy, 
		DT.ModifiedOn AS DedType_ModifiedOn,
		TR.OOS_TransactionId AS TransactionId, 
		TR.BatchId, 
		TR.DeductionAmount,
		CAST(TR.DeductionAmount AS Numeric(9,2)) AS DedAmount,
		TR.DeductionDate,
		TR.DeductionDate AS WeekEndDate,
		TR.DeductionDate - 5 AS WED,
		TR.DeductionDate AS ReceivedOn,
		TR.Description, 
		TR.Invoice, 
		'OOS' + SUBSTRING(REPLACE(CONVERT(Varchar, TR.DeductionDate, 102), '.', ''), 3, 8) + CAST(TR.OOS_TransactionId AS Varchar) AS Voucher, 
		TR.Hold,
		TR.Period,
		TR.DeductionNumber,
		TR.Processed,
		TR.Fk_EscrowTransactionId AS EscrowTransactionId,
		TR.CreatedBy AS Trans_CreatedBy, 
		TR.CreatedOn AS Trans_CreatedOn, 
        TR.ModifiedBy AS Trans_ModifiedBy, 
		TR.ModifiedOn AS Trans_ModifiedOn,
		DT.MaintainBalance,
		DT.EscrowBalance,
		TR.DeletedBy AS Trans_DeletedBy,
		TR.DeletedOn AS Trans_DeletedOn,
		DT.DeductionType AS ColumnType,
		DT.SpecialDeduction,
		DT.CreditMaskAgent,
		DT.CreditMaskDivision,
		DT.DebitMaskAgent,
		DT.DebitMaskDivision,
		VM.Agent,
		VM.Division
FROM    OOS_Transactions TR
		INNER JOIN OOS_Deductions DE ON TR.Fk_OOS_DeductionId = DE.OOS_DeductionId
		INNER JOIN OOS_DeductionTypes DT ON DE.Fk_OOS_DeductionTypeId = Dt.OOS_DeductionTypeId
		INNER JOIN Companies CO ON DT.Company = CO.CompanyId
		INNER JOIN VendorMaster VM ON DT.Company = VM.Company AND DE.Vendorid = VM.VendorId
		LEFT JOIN EscrowAccounts ES ON DT.Company = ES.CompanyId AND DT.CrdAcctIndex = ES.AccountIndex AND ES.Fk_EscrowModuleId NOT IN (10,14)
		LEFT JOIN EscrowModules EM ON ES.Fk_EscrowModuleId = EM.EscrowModuleId
WHERE	DE.DeductionAmount <> 0


GO