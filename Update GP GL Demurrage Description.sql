UPDATE	GL20000
SET		DSCRIPTN = InvoiceNumber
FROM	(
		SELECT	FSI.InvoiceNumber, GL2.DEX_ROW_ID AS RowId
		FROM	GL20000 GL2
				LEFT JOIN PRISQL004P.Integrations.dbo.FSI_TransactionDetails FSI ON GL2.ORGNTSRC = LEFT(FSI.BatchId, 15) AND GL2.DEBITAMT + GL2.CRDTAMNT = FSI.Amount AND GL2.REFRENCE = FSI.RefDocument
		WHERE	ORGNTSRC LIKE '9FSI20210818_%'
				AND LASTUSER = 'FSIG_Integratio'
				AND TRXDATE > DATEADD(DD, -5, GETDATE())
		) DATA
WHERE	DEX_ROW_ID = RowId
		AND DSCRIPTN <> InvoiceNumber

/*
SELECT * FROM GL20000 WHERE ORGNTSRC LIKE '9FSI202108%' AND LASTUSER = 'FSIG_Integratio'
SELECT * FROM GL10001 WHERE BACHNUMB = '9FSI20210816_15' order by JRNENTRY
*/