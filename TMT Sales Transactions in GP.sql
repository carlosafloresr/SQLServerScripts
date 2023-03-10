SELECT	RMHD.BACHNUMB AS BatchId,
		RMHD.CUSTNMBR AS CustomerId,
		RTRIM(RMHD.DOCNUMBR) AS DocumentNumber,
		RTRIM(RMHD.DOCDESCR) AS Description,
		CAST(RMHD.DOCDATE AS Date) AS [Date],
		RTRIM(GL5.ACTNUMST) AS Account,
		RTRIM(GL1.ACTDESCR) AS Acct_Description,
		CAST(RMDE.DEBITAMT AS Numeric(10,2)) AS Debit,
		CAST(RMDE.CRDTAMNT AS Numeric(10,2)) AS Credit,
		RMHD.BACHNUMB
FROM	RM10101 RMDE
		LEFT JOIN RM10301 RMHD ON RMHD.CUSTNMBR = RMDE.CUSTNMBR AND RMHD.DOCNUMBR = RMDE.DOCNUMBR
		LEFT JOIN GL00105 GL5 ON RMDE.DSTINDX = GL5.ACTINDX
		LEFT JOIN GL00100 GL1 on GL5.ACTINDX = GL1.ACTINDX
WHERE	RMHD.DOCDATE > '08/01/2021'

