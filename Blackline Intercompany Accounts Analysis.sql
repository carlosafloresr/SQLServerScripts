/*
SELECT 'AIS','04', 'DNJ', GL5.ACTNUMST, 'Intercompany Receivable - DNJ',
			'Receivable',
			GL2.PERIODID,
			GL2.JRNENTRY,
			GL2.TRXSORCE,
			GL2.TRXDATE,
			GL2.DSCRIPTN,
			GL2.DEBITAMT,
			GL2.CRDTAMNT,
			GL2.DEBITAMT + (GL2.CRDTAMNT * -1) AS Amount,
			GL2.ACTINDX
	FROM	AIS.dbo.GL20000 GL2
			INNER JOIN AIS.dbo.GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
	WHERE	GL2.PERIODID = 12
			AND GL2.VOIDED = 0 
			AND GL5.ACTNUMST = '0-90-1100' 
	ORDER BY
			GL2.TRXDATE,
			GL2.JRNENTRY
*/

SELECT	TCO.Company,
		TCO.Intercompany,
		TCO.GLAccount AS Cpy_GLAccount,
		TIN.GLAccount AS Int_GLAccount,
		SUM(TCO.Debit + (TCO.Credit * -1)) AS Cpy_Amount,
		ISNULL(TIN.Amount,0) AS Int_Amount
FROM	tmpIntercompany TCO
		LEFT JOIN (
					SELECT	DISTINCT Company,
							Intercompany,
							GLAccount,
							SUM(Debit + (Credit * -1)) AS Amount
					FROM	tmpIntercompany TCO
					GROUP BY TCO.Company, TCO.Intercompany, TCO.GLAccount
				  ) TIN ON TCO.Intercompany = TIN.Company AND TCO.Company = TIN.Intercompany --AND TCO.GLAccount = TIN.GLAccount
--WHERE	Company = 'AIS'
--		AND Intercompany = 'IMCNA'
--		AND GLAccount = '0-90-1100'
GROUP BY TCO.Company, TCO.Intercompany, TCO.GLAccount, TIN.GLAccount, TIN.Amount
ORDER BY TCO.Company, TCO.Intercompany

/*
SELECT	CAST(YEAR1 AS Varchar) + '-' + dbo.PADL(PERIODID, 2, '0') AS Period, 
		DEBITAMT,
		CRDTAMNT,
		PERDBLNC
FROM	AIS.dbo.GL10110
WHERE	ACTINDX = (SELECT ACTINDX FROM AIS..GL00105 WHERE ACTNUMST = '0-90-1100')
		AND YEAR1 = 2022
		AND PERIODID = 12

SELECT	*
FROM	tmpIntercompany
*/