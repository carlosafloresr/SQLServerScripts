DECLARE	@WeekendDate	Date = '01/19/2019',
		@BatchId		Varchar(20)

SELECT	@BatchId = BatchId
FROM	AgentsSettlementsBatches
WHERE	WeekendDate = @WeekendDate

DELETE AgentsSettlements WHERE WeekendDate = @WeekendDate
DELETE AgentsSettlements_Transactions WHERE BatchId = @BatchId
DELETE AgentsSettlementsCommisions WHERE BatchId = @BatchId
DELETE AgentsSettlementsImages WHERE WeekendDate = @WeekendDate
DELETE AgentsSettlementsTransactions WHERE WeekendDate = @WeekendDate
DELETE AgentsSettlementsBatches WHERE WeekendDate = @WeekendDate