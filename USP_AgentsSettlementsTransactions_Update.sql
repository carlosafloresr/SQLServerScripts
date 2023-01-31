CREATE PROCEDURE USP_AgentsSettlementsTransactions_Update
		@TransactionId		Int,
		@DeductionAmount	Numeric(10,2)
AS
DECLARE	@WeekendDate		Date,
		@BatchId			Varchar(20),
		@Agent				Varchar(3)

UPDATE	AgentsSettlementsTransactions 
SET		Amount = @DeductionAmount 
WHERE	AgentsSettlementsTransactionsId = @TransactionId

IF @@ERROR = 0
BEGIN
	SELECT	@Agent		= ATR.Agent,
			@BatchId	= ABA.BatchId
	FROM	AgentsSettlementsTransactions ATR
			INNER JOIN AgentsSettlementsBatches ABA ON ATR.WeekendDate = ATR.WeekendDate
	WHERE	ATR.AgentsSettlementsTransactionsId = @TransactionId
			
	UPDATE	AgentsSettlementsCommisions 
	SET		ReportsCreated = 0,
			SubmitForApproval = 0,
			BatchApproved = 0,
			BatchRejected = 0,
			Reason = Null
	WHERE	BatchId = @BatchId
			AND Agent = @Agent
END