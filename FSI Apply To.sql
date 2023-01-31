/*
EXECUTE USP_FSI_SummaryBatch '2FSI20130326_1321_SUM'
*/
ALTER PROCEDURE USP_FSI_SummaryBatch
		@BatchId	Varchar(25)
AS
/*
SELECT	*
FROM	View_Integration_FSI
WHERE	BatchId = @BatchId
		AND InvoiceType = 'S'
*/

SELECT	SummaryBatch
		,CustomerNumber
		,ABS(InvoiceTotal) AS Amount
		,SUBSTRING(ApplyTo, 2, 20) AS ApplyTo
		,InvoiceNumber AS ApplyFrom
		,WeekEndDate
		,FSI_ReceivedDetailId
FROM	View_Integration_FSI
WHERE	BatchId = @BatchId
		AND InvoiceType = 'C'