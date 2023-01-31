USE GPCustom
GO

INSERT INTO dbo.OOS_Transactions
		(Fk_OOS_DeductionId
		,BatchId
		,MaxDeduction
		,DeductionAmount
		,DeductionDate
		,Description
		,Invoice
		,Voucher
		,Period
		,Hold
		,Processed
		,DeductionNumber
		,Fk_EscrowTransactionId
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		,DeletedBy
		,DeletedOn)
SELECT	Fk_OOS_DeductionId
		,BatchId
		,MaxDeduction
		,DeductionAmount
		,DeductionDate
		,Description
		,Invoice
		,Voucher
		,Period
		,Hold
		,1 AS Processed
		,DeductionNumber
		,Fk_EscrowTransactionId
		,CreatedBy
		,CreatedOn
		,ModifiedBy
		,ModifiedOn
		,DeletedBy
		,DeletedOn
FROM	GPCustom.dbo.OOS_OOSDNJ_042618_JHART_20180425_1213