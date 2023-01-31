/*
EXECUTE USP_AgentsSettlements_BatchCreation '03/10/2018', 'CFLORES'
*/
ALTER PROCEDURE USP_AgentsSettlements_BatchCreation
		@BatchDate	Date,
		@UserId		Varchar(25)
AS
DECLARE	@BatchId	Varchar(25),
		@DedDate	Date = dbo.DayFwdBack(@BatchDate, 'N', 'Thursday')

SET @BatchId = (SELECT BatchId FROM AgentsSettlementsBatches WHERE WeekendDate = @BatchDate)

DELETE AgentsSettlements_Transactions WHERE BatchId = @BatchId

INSERT INTO AgentsSettlements_Transactions
		(DeductionId,
		BatchId,
		DeductionAmount,
		DeductionDate,
		Description,
		Invoice,
		Voucher,
		Hold,
		Period,
		DeductionNumber,
		CreatedBy,
		ModifiedBy)
SELECT	ASD.DeductionId,
		@BatchId AS BatchId,
		CASE WHEN ASD.MaxDeduction > 0 THEN (CASE WHEN ASD.MaxDeduction - ASD.Balance < ASD.DeductionAmount THEN ASD.MaxDeduction - ASD.Balance ELSE ASD.DeductionAmount END) ELSE ASD.DeductionAmount END AS DeductionAmount,
		@DedDate AS DeductionDate,
		RTRIM(ASD.DeductionCode) + ' ' + CAST(@DedDate AS Varchar) AS [Description],
		RTRIM(ASD.DeductionCode) + '_' + REPLACE(CAST(@DedDate AS Varchar), '-', '') AS Invoice,
		'AGSTL' + SUBSTRING(REPLACE(CAST(@DedDate AS Varchar), '-', ''), 3, 6) + '_' + dbo.PADL(ROW_NUMBER() OVER(ORDER BY VendorId), 2, '0') AS Voucher,
		0 AS Hold,
		SUBSTRING(REPLACE(CAST(@DedDate AS Varchar), '-', ''), 1, 4) + '_' + dbo.PADL(CAST(dbo.WeekNumber(@DedDate) AS Varchar), 2, '0') AS Period,
		ASD.DeductionNumber + 1 AS DeductionNumber,
		@UserId AS UserId,
		@UserId AS UserId
FROM	View_AgentsSettlements_Deductions ASD
		INNER JOIN AgentsSettlementsCommisions ASE ON ASD.Agent = ASE.Agent AND ASE.BatchId = @BatchId
WHERE	ASD.StartDate <= @BatchDate
		AND ((ASD.MaxDeduction > 0 AND ASD.Balance < ASD.MaxDeduction)
		OR (ASD.NumberOfDeductions > 0 AND ASD.CurrentDeductions < ASD.NumberOfDeductions)
		OR ASD.Perpetual = 1)
		AND (ASD.CommissionRequired = 0 OR (ASD.CommissionRequired = 1 AND ASE.Commission >= ISNULL(ASD.Treshold,0)))

-- SELECT * FROM View_AgentsSettlements_Deductions