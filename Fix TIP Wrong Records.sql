select	* 
from	View_MSR_Intercompany 
where	batchid = 'AR_FI_110131' 
--		and Intercompany = 'GIS'
--		and account2 is not null
--order by JournalNum

/*
UPDATE MSR_Intercompany 
SET		PROCESSED = 0
where	batchid = 'AR_RCMR_110105'
		AND MSR_IntercompanyId IN (select MSR_IntercompanyId
from	View_MSR_Intercompany 
where	batchid = 'AR_FI_100924' and intercompany = 'GIS')

delete MSR_Intercompany 
where	batchid = 'FIX_FI_100924'
		AND MSR_IntercompanyId IN (select MSR_IntercompanyId
from	View_MSR_Intercompany 
where	batchid = 'FIX_FI_100924' and intercompany = 'GIS')
*/
-- INSERT INTO MSR_Intercompany
SELECT	[BatchId]
		,[DocNumber]
		,[InvoiceNumber]
		,[Customer]
		,[InvoiceTotal]
		,[Chassis]
		,[Container]
		,[CO_MAR]
		,[CO_REP]
		,[CO_RPL]
		,[OO_MAR]
		,[OO_REP]
		,[OO_RPL]
		,[Account1]
		,[Account2]
		,[Account3]
		,[Amount1]
		,[Amount2]
		,[Amount3]
		,[Description1]
		,[Description2]
		,[Description3]
		,[PostingDate]
		,[ProNumber]
		,[Processed]
		,[JournalNum]
SELECT	BatchId,
		DocNumber,
		Description
FROM	MSR_ReceviedTransactions 
WHERE	BatchId = 'AR_FI_120130'
		AND InterCompany = 1

/*
SELECT	DISTINCT 
FROM	View_MSR_Intercompany 
WHERE	BatchId = 'FIX_FI_100924' 
		AND Intercompany = 'IMC' 
		AND RowProcessed = 0 
ORDER BY DocNumber, InvoiceNumber
*/