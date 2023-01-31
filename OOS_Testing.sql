EXECUTE USP_OOS_Transactions 'AIS', 'OOSAIS_092707', '1'
EXECUTE USP_OOS_DeleteBatch 'OOSAISTE_100407'

delete oos_transactions where batchid = 'OOSAISTE_092707'

SELECT TOP 1 BatchId FROM OOS_Transactions WHERE Period = 'M200709'

SELECT * FROM View_OOS_Transactions

EXECUTE USP_OOS_RestoreHistory