--SELECT CustNmbr FROM IMCt.dbo.RM00101 WHERE CustNmbr = '1063G'

SELECT * FROM FSI_ReceivedHeader WHERE company = 'IMCT'
DELETE FSI_ReceivedHeader WHERE company = 'IMCT' AND FSI_ReceivedHeaderId < 353

DELETE FSI_ReceivedDetails WHERE BatchId NOT IN (SELECT BatchId FROM FSI_ReceivedHeader)
DELETE FSI_ReceivedSubDetails WHERE BatchId NOT IN (SELECT BatchId FROM FSI_ReceivedHeader)