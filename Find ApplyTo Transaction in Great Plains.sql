DECLARE @tblDocuments Table (InvoiceNumber Varchar(25), ApplyTo Varchar(25), Amount Numeric(10,2))

INSERT INTO @tblDocuments
SELECT	InvoiceNumber, ApplyTo, InvoiceTotal
FROM	IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails
WHERE	InvoiceNumber IN ('C56-103423','C42-104271','C56-103260','C42-104271A')

SELECT	DB_NAME() AS Company,
		OPN1.CUSTNMBR AS CustomerId,
		OPN1.DOCNUMBR AS DocNumber,
		CAST(OPN1.ORTRXAMT AS Numeric(10,2)) AS DocAmount,
		CAST(OPN1.CURTRXAM AS Numeric(10,2)) AS Balance,
		COALESCE(APL1.APTODCNM,APL2.APTODCNM,'') AS Applied,
		CAST(COALESCE(APL1.APFRMAPLYAMT,APL2.APFRMAPLYAMT,0) AS Numeric(10,2)) AS AppliedAmnt,
		CASE OPN1.RMDTYPAL 
			WHEN 1 THEN 'Invoice' 
			WHEN 7 THEN 'Credit Memo' 
			ELSE CAST(OPN1.RMDTYPAL AS Varchar)
			END AS DocType,
		'OPEN' AS Location
FROM	RM20101 OPN1
		LEFT JOIN RM20201 APL1 ON OPN1.DOCNUMBR = APL1.APFRDCNM AND OPN1.CUSTNMBR = APL1.CUSTNMBR AND OPN1.RMDTYPAL = 7
		LEFT JOIN RM20201 APL2 ON OPN1.DOCNUMBR = APL2.APTODCNM AND OPN1.CUSTNMBR = APL2.CUSTNMBR AND OPN1.RMDTYPAL < 7
WHERE	OPN1.DOCNUMBR IN (SELECT InvoiceNumber FROM @tblDocuments)
		OR OPN1.DOCNUMBR IN (SELECT ApplyTo FROM @tblDocuments)
UNION
SELECT	DB_NAME() AS Company,
		OPN1.CUSTNMBR,
		OPN1.DOCNUMBR,
		CAST(OPN1.ORTRXAMT AS Numeric(10,2)) AS DocAmount,
		CAST(OPN1.CURTRXAM AS Numeric(10,2)) AS Balance,
		COALESCE(APL1.APTODCNM,APL2.APTODCNM,'') AS APTODCNM,
		CAST(COALESCE(APL1.APFRMAPLYAMT,APL2.APFRMAPLYAMT,0) AS Numeric(10,2)) AS AppliedAmnt,
		CASE OPN1.RMDTYPAL 
			WHEN 1 THEN 'Invoice' 
			WHEN 7 THEN 'Credit Memo' 
			ELSE CAST(OPN1.RMDTYPAL AS Varchar)
			END AS DocType,
		'HISTORY' AS Location
FROM	RM30101 OPN1
		LEFT JOIN RM30201 APL1 ON OPN1.DOCNUMBR = APL1.APFRDCNM AND OPN1.CUSTNMBR = APL1.CUSTNMBR AND OPN1.RMDTYPAL = 7
		LEFT JOIN RM30201 APL2 ON OPN1.DOCNUMBR = APL2.APTODCNM AND OPN1.CUSTNMBR = APL2.CUSTNMBR AND OPN1.RMDTYPAL < 7
WHERE	OPN1.DOCNUMBR IN (SELECT InvoiceNumber FROM @tblDocuments)
		OR OPN1.DOCNUMBR IN (SELECT ApplyTo FROM @tblDocuments)
ORDER BY 8, 3