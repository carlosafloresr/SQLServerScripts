USE [GLSO]
GO

DECLARE	@GLAccount		Varchar(12) = '0-05-1865',
		@DateIni		Date = '12/23/2021',
		@DateEnd		Date = '12/23/2021'

SELECT	CAST(GL20.TRXDATE AS Date) AS [Trx Date],
		GL20.JRNENTRY AS [Jrnl No.],
		IIF(GL20.SOURCDOC = 'PMTRX', GL20.ORGNTSRC, GL20.TRXSORCE) AS [Orig. Audit Trail],
		RTRIM(GL20.REFRENCE) AS [Distribution Reference],
		RTRIM(GL05.ACTNUMST) AS Account,
		RTRIM(GL1.ACTDESCR) AS Acct_Description,
		RTRIM(GL20.ORDOCNUM) AS [Orig. Master],
		RTRIM(GL20.ORMSTRNM) AS [Orig. Master Name],
		CAST(GL20.DEBITAMT AS Numeric(10,2)) AS Debit,
		CAST(GL20.CRDTAMNT AS Numeric(10,2)) AS Credit,
		CASE WHEN GL20.User_Defined_Text01 = '' AND GL20.SOURCDOC = 'PMTRX' THEN 'VND:' + RTRIM(GL20.ORMSTRID) + ' - ' + RTRIM(GL20.ORMSTRNM) ELSE GL20.User_Defined_Text01 END AS CustomField1,
		--CASE WHEN GL20.ORGNTSRC LIKE '%FSI%' THEN 'Y' ELSE 'N' END AS FromSWS,
		GPCustom.dbo.FindProNumber(GL20.REFRENCE) AS ProNumber
		--GL20.SEQNUMBR AS Sequence
FROM	GL20000 GL20
		LEFT JOIN GL00105 GL05 ON GL20.ACTINDX = GL05.ACTINDX
		LEFT JOIN GL00100 GL1 on GL1.ACTINDX = GL05.ACTINDX
WHERE	GL20.TRXDATE BETWEEN @DateIni AND @DateEnd
		AND GL05.ACTNUMST = @GLAccount
		--AND GL20.ORGNTSRC LIKE '%FSI%'
		--OR GL20.JRNENTRY = 1631955
ORDER BY GL20.JRNENTRY, GL20.SEQNUMBR, GL20.TRXDATE

-- select * from gl20000 where JRNENTRY = 1631956