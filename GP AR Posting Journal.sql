DECLARE @Document	Varchar(30) =  '95-264138',
		@BatchId	Varchar(25) = NULL

IF LEN(@BatchId) > 15
	SET @BatchId = SUBSTRING(REPLACE(REPLACE(@BatchId, 'FSI20', 'FSIAR'), '_', ''), 2, 15)

SELECT	RMHD.BACHNUMB AS BatchId,
		RMHD.CUSTNMBR AS CustomerId,
		RTRIM(RMHD.DOCNUMBR) AS DocumentNumber,
		CAST(RMHD.DOCDATE AS Date) AS [Date],
		RTRIM(GL5.ACTNUMST) AS Account,
		RTRIM(GL1.ACTDESCR) AS Acct_Description,
		CAST(RMDE.RMDTYPAL AS Varchar) + ' ' + CASE WHEN RMDE.RMDTYPAL = 1 THEN 'Sales/Invoice'
			 WHEN RMDE.RMDTYPAL = 3 THEN 'Debit Memo'
			 WHEN RMDE.RMDTYPAL = 4 THEN 'Finance Charge'
			 WHEN RMDE.RMDTYPAL = 5 THEN 'Service/Repair'
			 WHEN RMDE.RMDTYPAL = 6 THEN 'Warranty'
			 WHEN RMDE.RMDTYPAL = 7 THEN 'Credit Memo'
			 WHEN RMDE.RMDTYPAL = 8 THEN 'Return'
			 WHEN RMDE.RMDTYPAL = 9 THEN 'Cash Receipt' END AS RMDTYPAL,
		CAST(RMDE.DISTTYPE AS Varchar) + ' ' + CASE WHEN RMDE.DISTTYPE = 1 THEN 'Cash'
			 WHEN RMDE.DISTTYPE = 2 THEN 'Taken'
			 WHEN RMDE.DISTTYPE = 3 THEN 'Recv'
			 WHEN RMDE.DISTTYPE = 4 THEN 'Write'
			 WHEN RMDE.DISTTYPE = 5 THEN 'Avail'
			 WHEN RMDE.DISTTYPE = 6 THEN 'Gst'
			 WHEN RMDE.DISTTYPE = 7 THEN 'Wh'
			 WHEN RMDE.DISTTYPE = 8 THEN 'Other'
			 WHEN RMDE.DISTTYPE = 9 THEN 'Sales'
			 WHEN RMDE.DISTTYPE = 10 THEN 'Trade'
			 WHEN RMDE.DISTTYPE = 11 THEN 'Freight'
			 WHEN RMDE.DISTTYPE = 12 THEN 'Misc'
			 WHEN RMDE.DISTTYPE = 13 THEN 'Taxes'
			 WHEN RMDE.DISTTYPE = 14 THEN 'Cogs'
			 WHEN RMDE.DISTTYPE = 15 THEN 'Inv'
			 WHEN RMDE.DISTTYPE = 16 THEN 'Fnchg'
			 WHEN RMDE.DISTTYPE = 17 THEN 'Returns'
			 WHEN RMDE.DISTTYPE = 18 THEN 'DrMemo'
			 WHEN RMDE.DISTTYPE = 19 THEN 'CrMemo'
			 WHEN RMDE.DISTTYPE = 20 THEN 'Service'
			 WHEN RMDE.DISTTYPE = 21 THEN 'Warrexp'
			 WHEN RMDE.DISTTYPE = 22 THEN 'Warrsls'
			 WHEN RMDE.DISTTYPE = 23 THEN 'Commexp'
			 WHEN RMDE.DISTTYPE = 24 THEN 'Cpmmpay' END AS DISTTYPE,
		CAST(RMDE.DEBITAMT AS Numeric(10,2)) AS Debit,
		CAST(RMDE.CRDTAMNT AS Numeric(10,2)) AS Credit,
		RMHD.CHEKNMBR,
		'WORK' AS DatSource
FROM	RM10101 RMDE
		LEFT JOIN RM10301 RMHD ON RMHD.CUSTNMBR = RMDE.CUSTNMBR AND RMHD.DOCNUMBR = RMDE.DOCNUMBR
		LEFT JOIN GL00105 GL5 ON RMDE.DSTINDX = GL5.ACTINDX
		LEFT JOIN GL00100 GL1 on GL5.ACTINDX = GL1.ACTINDX
WHERE	(@Document <> '' AND RMHD.DOCNUMBR = @Document)
		OR (@BatchId <> '' AND RMHD.BACHNUMB = @BatchId)
UNION
SELECT	RMHD.BACHNUMB,
		RMHD.CUSTNMBR AS CustomerId,
		RTRIM(RMHD.DOCNUMBR) AS DocumentNumber,
		CAST(RMHD.DOCDATE AS Date) AS [DATE],
		RTRIM(GL5.ACTNUMST) AS ACCOUNT,
		RTRIM(GL1.ACTDESCR) AS ACCT_Description,
		CAST(RMDE.RMDTYPAL AS Varchar) + ' ' + CASE WHEN RMDE.RMDTYPAL = 1 THEN 'Sales/Invoice'
			 WHEN RMDE.RMDTYPAL = 3 THEN 'Debit Memo'
			 WHEN RMDE.RMDTYPAL = 4 THEN 'Finance Charge'
			 WHEN RMDE.RMDTYPAL = 5 THEN 'Service/Repair'
			 WHEN RMDE.RMDTYPAL = 6 THEN 'Warranty'
			 WHEN RMDE.RMDTYPAL = 7 THEN 'Credit Memo'
			 WHEN RMDE.RMDTYPAL = 8 THEN 'Return'
			 WHEN RMDE.RMDTYPAL = 9 THEN 'Cash Receipt' END AS RMDTYPAL,
		CAST(RMDE.DISTTYPE AS Varchar) + ' ' + CASE WHEN RMDE.DISTTYPE = 1 THEN 'Cash'
			 WHEN RMDE.DISTTYPE = 2 THEN 'Taken'
			 WHEN RMDE.DISTTYPE = 3 THEN 'Recv'
			 WHEN RMDE.DISTTYPE = 4 THEN 'Write'
			 WHEN RMDE.DISTTYPE = 5 THEN 'Avail'
			 WHEN RMDE.DISTTYPE = 6 THEN 'Gst'
			 WHEN RMDE.DISTTYPE = 7 THEN 'Wh'
			 WHEN RMDE.DISTTYPE = 8 THEN 'Other'
			 WHEN RMDE.DISTTYPE = 9 THEN 'Sales'
			 WHEN RMDE.DISTTYPE = 10 THEN 'Trade'
			 WHEN RMDE.DISTTYPE = 11 THEN 'Freight'
			 WHEN RMDE.DISTTYPE = 12 THEN 'Misc'
			 WHEN RMDE.DISTTYPE = 13 THEN 'Taxes'
			 WHEN RMDE.DISTTYPE = 14 THEN 'Cogs'
			 WHEN RMDE.DISTTYPE = 15 THEN 'Inv'
			 WHEN RMDE.DISTTYPE = 16 THEN 'Fnchg'
			 WHEN RMDE.DISTTYPE = 17 THEN 'Returns'
			 WHEN RMDE.DISTTYPE = 18 THEN 'DrMemo'
			 WHEN RMDE.DISTTYPE = 19 THEN 'CrMemo'
			 WHEN RMDE.DISTTYPE = 20 THEN 'Service'
			 WHEN RMDE.DISTTYPE = 21 THEN 'Warrexp'
			 WHEN RMDE.DISTTYPE = 22 THEN 'Warrsls'
			 WHEN RMDE.DISTTYPE = 23 THEN 'Commexp'
			 WHEN RMDE.DISTTYPE = 24 THEN 'Cpmmpay' END AS DISTTYPE,
		CAST(RMDE.DEBITAMT AS Numeric(10,2)) AS DEBIT,
		CAST(RMDE.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		RMHD.CHEKNMBR,
		'OPEN' AS DatSource
FROM	RM10101 RMDE
		LEFT JOIN RM20101 RMHD ON RMHD.CUSTNMBR = RMDE.CUSTNMBR AND RMHD.DOCNUMBR = RMDE.DOCNUMBR
		LEFT JOIN GL00105 GL5 ON RMDE.DSTINDX = GL5.ACTINDX
		LEFT JOIN GL00100 GL1 on GL5.ACTINDX = GL1.ACTINDX
WHERE	(@Document <> '' AND RMHD.DOCNUMBR = @Document)
		OR (@BatchId <> '' AND RMHD.BACHNUMB = @BatchId)
UNION
SELECT	RMHD.BACHNUMB,
		RMHD.CUSTNMBR AS CustomerId,
		RTRIM(RMHD.DOCNUMBR) AS DocumentNumber,
		CAST(RMHD.DOCDATE AS Date) AS [DATE],
		RTRIM(GL5.ACTNUMST) AS ACCOUNT,
		RTRIM(GL1.ACTDESCR) AS ACCT_Description,
		CAST(RMDE.RMDTYPAL AS Varchar) + ' ' + CASE WHEN RMDE.RMDTYPAL = 1 THEN 'Sales/Invoice'
			 WHEN RMDE.RMDTYPAL = 3 THEN 'Debit Memo'
			 WHEN RMDE.RMDTYPAL = 4 THEN 'Finance Charge'
			 WHEN RMDE.RMDTYPAL = 5 THEN 'Service/Repair'
			 WHEN RMDE.RMDTYPAL = 6 THEN 'Warranty'
			 WHEN RMDE.RMDTYPAL = 7 THEN 'Credit Memo'
			 WHEN RMDE.RMDTYPAL = 8 THEN 'Return'
			 WHEN RMDE.RMDTYPAL = 9 THEN 'Cash Receipt' END AS RMDTYPAL,
		CAST(RMDE.DISTTYPE AS Varchar) + ' ' + CASE WHEN RMDE.DISTTYPE = 1 THEN 'Cash'
			 WHEN RMDE.DISTTYPE = 2 THEN 'Taken'
			 WHEN RMDE.DISTTYPE = 3 THEN 'Recv'
			 WHEN RMDE.DISTTYPE = 4 THEN 'Write'
			 WHEN RMDE.DISTTYPE = 5 THEN 'Avail'
			 WHEN RMDE.DISTTYPE = 6 THEN 'Gst'
			 WHEN RMDE.DISTTYPE = 7 THEN 'Wh'
			 WHEN RMDE.DISTTYPE = 8 THEN 'Other'
			 WHEN RMDE.DISTTYPE = 9 THEN 'Sales'
			 WHEN RMDE.DISTTYPE = 10 THEN 'Trade'
			 WHEN RMDE.DISTTYPE = 11 THEN 'Freight'
			 WHEN RMDE.DISTTYPE = 12 THEN 'Misc'
			 WHEN RMDE.DISTTYPE = 13 THEN 'Taxes'
			 WHEN RMDE.DISTTYPE = 14 THEN 'Cogs'
			 WHEN RMDE.DISTTYPE = 15 THEN 'Inv'
			 WHEN RMDE.DISTTYPE = 16 THEN 'Fnchg'
			 WHEN RMDE.DISTTYPE = 17 THEN 'Returns'
			 WHEN RMDE.DISTTYPE = 18 THEN 'DrMemo'
			 WHEN RMDE.DISTTYPE = 19 THEN 'CrMemo'
			 WHEN RMDE.DISTTYPE = 20 THEN 'Service'
			 WHEN RMDE.DISTTYPE = 21 THEN 'Warrexp'
			 WHEN RMDE.DISTTYPE = 22 THEN 'Warrsls'
			 WHEN RMDE.DISTTYPE = 23 THEN 'Commexp'
			 WHEN RMDE.DISTTYPE = 24 THEN 'Cpmmpay' END AS DISTTYPE,
		CAST(RMDE.DEBITAMT AS Numeric(10,2)) AS DEBIT,
		CAST(RMDE.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		RMHD.CHEKNMBR,
		'HISTORY' AS DatSource
FROM	RM30301 RMDE
		LEFT JOIN RM30101 RMHD ON RMHD.CUSTNMBR = RMDE.CUSTNMBR AND RMHD.DOCNUMBR = RMDE.DOCNUMBR
		LEFT JOIN GL00105 GL5 ON RMDE.DSTINDX = GL5.ACTINDX
		LEFT JOIN GL00100 GL1 on GL5.ACTINDX = GL1.ACTINDX
WHERE	(@Document <> '' AND RMHD.DOCNUMBR = @Document)
		OR (@BatchId <> '' AND RMHD.BACHNUMB = @BatchId)
ORDER BY 1, 2, 3, 7, 8

-- select top 100 * from RM30101 WHERE RMDTYPAL = 9 AND DOCDATE > '01/01/2022' AND CHEKNMBR IN ('573907','573912','573911')