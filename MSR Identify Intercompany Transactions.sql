SELECT	MSR.MSR_ReceivedTransactions AS RecordId
		,MSR.Company
		,MSR.BatchId
		,MSR.DocDate
		,MSR.Customer AS Account
		,MSR.DocNumber AS InvoiceNumber
		,MSR.DocDate AS InvoiceDate
		,MSR.Amount
		,Null AS BillToRef
		,ARAP.LinkedCompany
		,ACCT.AccountNumber
		,Null AS InterAccount
		,'Inv#' + RTRIM(MSR.DocNumber) + CASE WHEN MSR.Chassis = '' THEN '' ELSE '/' + RTRIM(MSR.Chassis) END AS Description
		,MSR.Processed
		,ACCT.LinkType
FROM	MSR_ReceviedTransactions MSR
		INNER JOIN FSI_Intercompany_ARAP ARAP ON MSR.Company = ARAP.Company AND MSR.Customer = ARAP.Account AND ARAP.RecordType = 'C'
		LEFT JOIN FSI_Intercompany_Companies ACCT ON MSR.Company = ACCT.ForCompany AND ARAP.LinkedCompany = ACCT.LinkedCompany AND ACCT.LinkType = 'R'
WHERE	MSR.Intercompany = 1
		AND BatchId = 'AR_RCMR_110124'

/*
SELECT	* 
FROM	MSR_ReceviedTransactions 
WHERE	Customer IN (SELECT Account FROM FSI_Intercompany_ARAP WHERE Company IN ('FI','RCMR') AND RecordType = 'C')
		AND BatchId = 'AR_FI_090226' 
		AND DocNumber = 'I327874'

UPDATE	MSR_ReceviedTransactions 
SET		Intercompany = 1
WHERE	Customer IN (SELECT Account FROM FSI_Intercompany_ARAP WHERE Company IN ('FI','RCMR') AND RecordType = 'C')
*/