SET NOCOUNT ON

DECLARE	@tblData Table (Journal Int, Account Varchar(15), Amount Numeric(10,2), Document Varchar(25))

INSERT INTO @tblData
SELECT	GL20.JRNENTRY AS JOURNAL,
		RTRIM(GL05.ACTNUMST) AS ACCOUNT,
		CASE WHEN GL20.DEBITAMT > 0 THEN -1 ELSE 1 END * (GL20.DEBITAMT+ GL20.CRDTAMNT) AS AMOUNT,
		RTRIM(IIF(GL20.ORDOCNUM = '', GL20.REFRENCE, GL20.ORDOCNUM)) AS DocumentNumber
FROM	GL20000 GL20
		LEFT JOIN GL00105 GL05 ON GL20.ACTINDX = GL05.ACTINDX
		LEFT JOIN GL00100 GL1 on GL1.ACTINDX = GL05.ACTINDX
WHERE	GL05.ACTNUMST IN ('1-00-4028','1-99-4028')
ORDER BY 1, 2

SELECT	*
INTO	##tmpData
FROM	(
		SELECT	Journal,
				Document,
				Account,
				Amount
		FROM	@tblData
		) DataResults
		PIVOT (
				SUM(Amount)
				FOR Account
				IN ([1-00-4028],[1-99-4028])
				) AS PivotTable
ORDER BY 2


/*
SELECT * FROM (
  SELECT
    [Student],
    [Subject],
    [Marks]
  FROM Grades
) StudentResults
PIVOT (
  SUM([Marks])
  FOR [Subject]
  IN (
    [Mathematics],
    [Science],
    [Geography]
  )
) AS PivotTable
*/

SELECT	FD.BatchId, 
		FD.CustomerNumber, 
		FD.InvoiceNumber, 
		TMP.Journal,
		AdminFee = ISNULL((SELECT SUM(DemurrageAdminFee) FROM [PRISQL004P].[Integrations].[dbo].FSI_ReceivedSubDetails FS WHERE FD.BatchId = FS.BatchId AND FD.DetailId = FS.DetailId),0),
		DemurrageAR = ISNULL((SELECT SUM(ChargeAmount1) FROM [PRISQL004P].[Integrations].[dbo].FSI_ReceivedSubDetails FS WHERE FD.BatchId = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'ACC' AND FS.RecordType = '395'),0),
		DemurrageAP = ISNULL((SELECT SUM(ChargeAmount1) FROM [PRISQL004P].[Integrations].[dbo].FSI_ReceivedSubDetails FS WHERE FD.BatchId = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'VND' AND FS.AccCode = '395'),0),
		FD.InvoiceTotal,
		ISNULL(TMP.[1-00-4028],0) AS [GP 1-00-4028],
		ISNULL(TMP.[1-99-4028],0) AS [GP 1-99-4028]
FROM	[PRISQL004P].[Integrations].[dbo].[FSI_ReceivedDetails] FD
		INNER JOIN ##tmpData TMP ON FD.InvoiceNumber = TMP.Document
WHERE	FD.InvoiceNumber IN (SELECT Document FROM @tblData)
ORDER BY 3

DROP TABLE ##tmpData