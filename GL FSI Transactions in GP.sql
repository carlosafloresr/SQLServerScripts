SELECT	GL2.JRNENTRY AS JOURNAL,
		GL5.ACTNUMST AS ACCOUNT,
		GL2.REFRENCE AS DESCRIPTION,
		CAST(GL2.TRXDATE AS Date) AS DATE,
		CAST(GL2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		CAST(GL2.DEBITAMT AS Numeric(10,2)) AS DEBIT,
		GL2.ORGNTSRC AS BATCHID
FROM	GL20000 GL2
		INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
WHERE	GL2.REFRENCE IN ('ICB|10-145751|05-152307','ICB|10-145751|05-153287','ICB|10-146019|05-153070','ICB|61-101969|05-153415','ICB|3-322328|11-141995')
		AND ORGNTSRC IN ('1FSI20201130_16','1FSI20201202_10')
		--GL2.JRNENTRY = 510192
		--GL5.ACTNUMST IN ('0-00-5010','0-00-1866')
ORDER BY GL2.JRNENTRY