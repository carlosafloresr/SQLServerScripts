/*
SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'GIS'
		AND AccountNumber = '0-00-2784'
		AND EnteredOn BETWEEN '01/01/2012' AND '05/29/2012'
		AND Source = 'GL'
*/

SELECT	VendorId
		,SUM(CRDTAMNT) AS CRDTAMNT
		,Escrow = (SELECT SUM(ESC.Amount) FROM EscrowTransactions ESC WHERE ESC.CompanyId = 'GIS' AND ESC.AccountNumber = '0-00-2784' AND ESC.EnteredOn BETWEEN '01/01/2012' AND '05/29/2012' AND ESC.VendorId = REC.VendorId AND ESC.Source = 'AP')
FROM	(
		SELECT	ORMSTRID AS VendorId
				,ORCTRNUM
				,CRDTAMNT
				,TRXDATE
				,ORPSTDDT
		FROM	GIS.dbo.GL20000
		WHERE	ACTINDX IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ACTNUMST = '0-00-2784')
				AND TRXDATE BETWEEN '01/01/2012' AND '05/29/2012'
				AND SOURCDOC = 'PMTRX'
		UNION
		SELECT	ORMSTRID AS VendorId
				,ORCTRNUM
				,CRDTAMNT
				,TRXDATE
				,ORPSTDDT
		FROM	GIS.dbo.GL30000
		WHERE	ACTINDX IN (SELECT ActIndx FROM GIS.dbo.GL00105 WHERE ACTNUMST = '0-00-2784')
				AND TRXDATE BETWEEN '01/01/2012' AND '05/29/2012'
				AND SOURCDOC = 'PMTRX'
		) REC
GROUP BY VendorId