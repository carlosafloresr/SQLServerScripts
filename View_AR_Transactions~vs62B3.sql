CREATE VIEW View_AR_Transactions
AS
SELECT	C.CUSTNMBR, 
		C.ORTRXAMT * CASE WHEN RMDTYPAL < 6 THEN 1 ELSE - 1 END AS NET, 
		C.GLPOSTDT, 
		C.RMDTYPAL, 
		C.DOCNUMBR, 
		C.DOCDATE, 
		C.CURTRXAM, 
		C.SLSAMNT, 
		C.COSTAMNT, 
		C.FRTAMNT, 
		C.MISCAMNT,
		C.VOIDSTTS, 
		C.VOIDDATE, 
		D.CUSTCLAS, 
		C.ORTRXAMT, 
		D.RMARACC, 
		B.ACTNUMST, 
		A.USERDEF1
FROM	GL00100 AS A 
		INNER JOIN dbo.GL00105 AS B ON A.ACTINDX = B.ACTINDX 
		RIGHT OUTER JOIN dbo.RM20101 AS C 
		INNER JOIN dbo.RM00101 AS D ON C.CUSTNMBR = D .CUSTNMBR ON B.ACTINDX = D.RMARACC
WHERE	C.VOIDSTTS = 0
UNION
SELECT	C.CUSTNMBR, 
		C.ORTRXAMT * CASE WHEN RMDTYPAL < 6 THEN 1 ELSE - 1 END AS NET, 
		C.GLPOSTDT, 
		C.RMDTYPAL, 
		C.DOCNUMBR, 
		C.DOCDATE, 
		C.CURTRXAM, 
		C.SLSAMNT, 
		C.COSTAMNT, 
		C.FRTAMNT, 
		C.MISCAMNT,
		C.VOIDSTTS, 
		C.VOIDDATE, 
		D.CUSTCLAS, 
		C.ORTRXAMT, 
		D.RMARACC, 
		B.ACTNUMST, 
		A.USERDEF1
FROM	dbo.GL00100 AS A 
		INNER JOIN dbo.GL00105 AS B ON A.ACTINDX = B.ACTINDX 
		RIGHT OUTER JOIN dbo.RM30101 AS C 
		INNER JOIN dbo.RM00101 AS D ON C.CUSTNMBR = D .CUSTNMBR ON B.ACTINDX = D.RMARACC
WHERE	C.VOIDSTTS = 0
go

CREATE VIEW View_AR_ApliedTransactions
AS
SELECT	CUSTNMBR, 
		GLPOSTDT, 
		APFRMAPLYAMT - APPTOAMT AS CURRTRX, 
		APFRMAPLYAMT, 
		APPTOAMT
FROM	dbo.RM20201
UNION
SELECT	CUSTNMBR, 
		GLPOSTDT, 
		APFRMAPLYAMT - APPTOAMT AS CURRTRX, 
		APFRMAPLYAMT, 
		APPTOAMT
FROM	dbo.RM30201