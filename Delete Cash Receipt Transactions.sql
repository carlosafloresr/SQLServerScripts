select * from dbo.CashReceipt where batchid = 'SUM_FI_09022009'
select * from dbo.CashReceiptBatches where batchid = 'SUM_FI_09022009'

/*
DELETE dbo.CashReceipt WHERE BatchId = 'SUM_FI_09022009'
DELETE CashReceiptBatches WHERE BatchId = 'SUM_FI_09022009'
DELETE ILSINT01.Integrations.dbo.ReceivedIntegrations WHERE BatchId = 'SUM_FI_09022009'

-- UPDATE CashReceiptBatches SET BatchStatus = 0 WHERE BatchId = 'SUM_FI_09022009'
*/