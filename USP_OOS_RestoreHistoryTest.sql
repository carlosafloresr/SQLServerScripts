USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_RestoreHistory]    Script Date: 07/09/2008 11:43:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXECUTE USP_OOS_RestoreHistoryTest
ALTER PROCEDURE [dbo].[USP_OOS_RestoreHistoryTest]
AS
DECLARE	@Fk_OOS_DeductionId	Int,
		@BatchId			Varchar(25),
		@DeductionAmount	Money,
		@Period				Char(7),
		@DeductionNumber	Int,
		@LastDeduction		Money,
		@Balance			Money

DECLARE Deductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT 	OTR.Fk_OOS_DeductionId, 
		MAX(OTR.BatchId) AS BatchId,
		SUM(OTR.DeductionAmount) AS DeductionAmount,
		MAX(OTR.Period) AS Period,
		MAX(OTR.DeductionNumber) AS DeductionNumber,
		CASE WHEN ODT.MaintainBalance = 1 AND ODT.EscrowBalance = 1 THEN ISNULL(EST.Balance, 0.0) ELSE 0.0 END AS Balance
FROM	OOS_Transactions OTR
		LEFT JOIN OOS_Deductions ODE ON OTR.Fk_OOS_DeductionId = ODE.OOS_DeductionId
		LEFT JOIN OOS_DeductionTypes ODT ON ODE.Fk_OOS_DeductionTypeId = ODT.OOS_DeductionTypeId
		LEFT JOIN EscrowAccounts ESA ON ODT.Company = ESA.CompanyId AND ODT.CrdAcctIndex = ESA.AccountIndex
		LEFT JOIN (
			SELECT	CompanyId,
					VendorId,
					AccountNumber,
					SUM(Amount) AS Balance
			FROM	EscrowTransactions
			WHERE	PostingDate IS NOT Null
			GROUP BY
					CompanyId,
					VendorId,
					AccountNumber) EST ON ESA.CompanyId = EST.CompanyId AND ESA.AccountNumber = EST.AccountNumber AND ODE.VendorId = EST.VendorId
GROUP BY 
		OTR.Fk_OOS_DeductionId,
		CASE WHEN ODT.MaintainBalance = 1 AND ODT.EscrowBalance = 1 THEN ISNULL(EST.Balance, 0.0) ELSE 0.0 END

OPEN Deductions
FETCH FROM Deductions INTO @Fk_OOS_DeductionId, @BatchId, @DeductionAmount, @Period, @DeductionNumber, @Balance

BEGIN TRANSACTION

UPDATE	OOS_Deductions
SET		Deducted 		= 0,
		DeductionNumber	= 0,
		LastBatchId		= '',
		LastAmount		= 0,
		LastPeriod		= '',
		Balance			= 0

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET	@LastDeduction	= (SELECT DeductionAmount FROM OOS_Transactions WHERE BatchId = @BatchId AND Fk_OOS_DeductionId = @Fk_OOS_DeductionId)

	UPDATE	OOS_Deductions
	SET		Deducted 		= @DeductionAmount,
			DeductionNumber	= @DeductionNumber,
			LastBatchId		= @BatchId,
			LastAmount		= @LastDeduction,
			LastPeriod		= @Period,
			Balance			= @Balance
	WHERE	OOS_DeductionId	= @Fk_OOS_DeductionId

	FETCH FROM Deductions INTO @Fk_OOS_DeductionId, @BatchId, @DeductionAmount, @Period, @DeductionNumber, @Balance
END
CLOSE Deductions
DEALLOCATE Deductions

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
END
