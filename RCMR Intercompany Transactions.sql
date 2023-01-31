SELECT * FROM MSR_ReceviedTransactions WHERE Company = 'RCMR' AND DocNumber IN ('30458','30460','30438','30459','30450','30451','30452','30453')

/*
SELECT CustNmbr FROM ILSGP01.RCMR.dbo.RM00101 WHERE CprCstNm = '11000'

UPDATE	MSR_ReceviedTransactions 
	SET		Intercompany = dbo.IsCustomerIntercompany('RCMR', Customer, '11000')
	WHERE	BatchId = 'AR_RCMR_100414'
			AND Company = 'RCMR'
			
SELECT	*
FROM	MSR_ReceviedTransactions 
WHERE	BatchId = 'AR_RCMR_100414'
		AND Company = 'RCMR'
*/