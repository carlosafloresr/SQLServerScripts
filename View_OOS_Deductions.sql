USE [GPCustom]
GO

/****** Object:  View [dbo].[View_OOS_Deductions]    Script Date: 7/18/2017 10:46:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_OOS_Deductions]
AS
SELECT	DE.OOS_DeductionId AS DeductionId, 
		DT.Company, 
		DE.Vendorid, 
		DE.Fk_OOS_DeductionTypeId AS DeductionTypeId, 
		DE.StartDate, 
		DE.DeductionAmount AS AmountToDeduct, 
		DT.Frequency, 
		DE.MaxDeduction, 
		DE.NumberOfDeductions, 
		DE.Perpetual, 
		DE.Inactive AS DeductionInactive, 
		DE.Notes, 
		DE.CurrentDeductions, 
		DE.Deducted,
		DE.DeductionNumber,
		DE.Balance, 
		DE.LastBatchId, 
		DE.LastAmount,
		DE.LastPeriod,
		DE.Completed,
		DE.CreatedOn AS Deduction_CreatedOn, 
		DE.CreatedBy AS Deduction_CreatedBy, 
		DE.ModifiedOn AS Deduction_ModifiedOn, 
		DE.ModifiedBy AS Deduction_ModifiedBy,
		DT.DeductionCode, 
		DT.Description AS DeductionType, 
		DT.CrdAcctIndex, 
		DT.CreditAccount, 
		DT.DebAcctIndex, 
		DT.DebitAccount, 
		DT.MaintainBalance,
		DT.EscrowBalance,
		DT.Inactive AS DeductionTypeInactive, 
		DT.CreatedBy AS DedType_CreatedBy, 
		DT.CreatedOn AS DedType_CreatedOn, 
		DT.ModifiedBy AS DedType_ModifiedBy, 
        DT.ModifiedOn AS DedType_ModifiedOn,
		DT.Inactive AS DedTypeInactive,
		DT.SpecialDeduction,
		DE.Sequence,
		DT.MobileAppVisible
FROM    OOS_Deductions DE
		INNER JOIN OOS_DeductionTypes DT ON DE.Fk_OOS_DeductionTypeId = DT.OOS_DeductionTypeId

GO