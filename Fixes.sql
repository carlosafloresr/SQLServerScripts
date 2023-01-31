DELETE	EscrowTransactions 
FROM	(SELECT	e1.VoucherNumber,
		e1.VendorId, 
		MAX(EscrowTransactionid) AS EscrowTransactionid 
	FROM 	EscrowTransactions e1 
		INNER JOIN (	SELECT	VoucherNumber, 
					VendorId, 
					Count(Source) AS Counter 
				FROM	EscrowTransactions
				WHERE	VoucherNumber = '00000000000000510' 
				GROUP BY VoucherNumber, vendorid 
				HAVING Count(Source) > 1) e2 ON e1.vendorid = e2.vendorid and e1.VoucherNumber = e2.VoucherNumber
	GROUP BY e1.VoucherNumber, e1.vendorid) es
WHERE	EscrowTransactions.EscrowTransactionid = es.EscrowTransactionid

SELECT	VendorId, 
	Count(VendorId) AS Counter 
FROM	EscrowTransactions
WHERE	vouchernumber = '00000000000000510' 
GROUP BY vendorid 
HAVING Count(VendorId) > 1

SELECT	*
FROM	EscrowTransactions
WHERE	vouchernumber = '7386'


UPDATE	EscrowTransactions
SET	PostingDate = '9/28/2007', TransactionDate = '9/28/2007'
WHERE	EscrowTransactionId = 12272

SELECT * FROM AIS.DBO.GL20000 WHERE JRNENTRY = '4907'

SELECT	*
FROM	EscrowTransactions
WHERE	VendorId = 'A0095' and AccountNumber  = '0-00-2781' AND
	 AND
	PostingDate < '9/30/2007'

EXECUTE USP_Report_EscrowDetailTrialBalance 'AIS', 3, '0-00-2781', '09/30/2007', '11/03/2007', NULL, 'CFLORES'


SELECT * FROM AIS.dbo.PM30600 P0 WHERE P0.Vchrnmbr = '00000000000000720'
SELECT * FROM AIS.dbo.PM20000 P1 WHERE P1.Vchrnmbr = '00000000000000720'
SELECT * FROM AIS.dbo.PM10000 P2 WHERE P2.VchnumWk = '00000000000000720'