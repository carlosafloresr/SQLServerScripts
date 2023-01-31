DECLARE	@BatchId Varchar(25)
SET @BatchId = 'OOSIMC_110311'

--SELECT	VendorId
--		,DeductionCode
--		,COUNT(DeductionCode) AS Counter
--FROM	View_OOS_Transactions
--WHERE BATCHID = @BatchId 
--GROUP BY VendorId, DeductionCode
--HAVING COUNT(DeductionCode) > 1

-- DELETE OOS_Transactions WHERE OOS_TransactionId = 653450
--SELECT * FROM View_OOS_Transactions WHERE BATCHID = @BatchId -- AND Invoice = 'TINS9998110311A' --AND Vendorid = '9998'

UPDATE OOS_Transactions SET Processed = 0 WHERE	BATCHID = @BatchId

-- Voucher = 'OOS' + SUBSTRING(Voucher, 5, 12)

/*
TINS9998110311A
TINS9998110311A

Node Identifier Parameters: taPMTransactionInsert
BACHNUMB = OOSIMC_110311
VCHNUMWK = OOS_1103110499
VENDORID = 10660
DOCNUMBR = OAC10660110311A
DOCTYPE = 5
DOCDATE = 11/3/2011
*/