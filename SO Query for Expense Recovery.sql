SELECT	GL20000.JrnEntry AS Test,
		GL00100.USRDEFS1 AS Category, 
		GL20000.ORGNTSRC,
		CONVERT(DateTime, GL20000.TRXDATE, 101) AS EffDate, 
		CASE WHEN GL20000.ORDOCNUM = '' OR GL20000.ORDOCNUM IS Null THEN CAST(GL20000.JRNENTRY AS Char(10)) ELSE GL20000.ORDOCNUM END AS DocNumber, 
		GL20000.DSCRIPTN AS Reference,
		GL00100.ACTNUMBR_1 AS Acct1, 
		GL00100.ACTNUMBR_2 AS Acct2, 
		GL00100.ACTNUMBR_3 AS Acct3, 
		RTRIM(GL00100.ACTNUMBR_1) + '-' + RTRIM(GL00100.ACTNUMBR_2) + '-' + GL00100.ACTNUMBR_3 AS Account,
		GL00100.ACTDESCR AS AcctDescription, 
		GL00100.ACTALIAS,
		GL20000.CRDTAMNT, 
		GL20000.DEBITAMT,
		CAST(GL20000.JRNENTRY AS Char(10)) AS VoucherNo,
		ISNULL(RTRIM(CAST(VEND1.CustNmbr AS Char(10))) + '-' + VEND1.CustName, 'General Ledger') AS Vendor,
		ISNULL(RM20101.DOCDATE, GL20000.TRXDATE) AS DOCDATE,
		RM20101.VOIDDATE,
		GL20000.JRNENTRY,
		ISNULL(RM20101.VOIDSTTS, GL20000.VOIDED) AS VOIDED,
		PV.ProNumber,
		UPPER(PV.TrailerNumber) AS TrailerNumber,
		UPPER(PV.ChassisNumber) AS ChassisNumber,
		CASE WHEN RM10101.DISTREF = '' OR RM10101.DISTREF IS Null THEN GL20000.SEQNUMBR ELSE RM10101.SEQNUMBR END AS SEQNUMBR,
		'GL20000.DSCRIPTN' AS SourceTable,
		RM10101.DocNumbr AS VchrNmbr,
		RM10101.DistType,
		RM10101.CustNmbr,
		PV.DriverId
FROM 	GL20000 
		INNER JOIN GL00100 ON GL20000.ACTINDX = GL00100.ACTINDX
		LEFT JOIN RM10101 ON GL20000.OrcTrnum = RM10101.DocNumbr AND GL20000.ORTRXSRC = RM10101.TRXSORCE AND GL20000.ORIGSEQNUM = RM10101.SEQNUMBR AND GL20000.SOURCDOC = 'SJ'
		LEFT JOIN RM20101 ON RM10101.DocNumbr = RM20101.DocNumbr AND RM10101.TRXSORCE = RM20101.TRXSORCE AND RM20101.VOIDSTTS = 0
		LEFT JOIN GPCustom.dbo.Purchasing_Vouchers PV ON RM10101.DocNumbr = PV.VoucherNumber AND PV.Source IN ('AR','SO') AND PV.CompanyId = DB_NAME()
		LEFT JOIN RM00101 VEND1 ON RM20101.CustNmbr = VEND1.CustNmbr
WHERE 	GL20000.Voided = 0 
		AND GL20000.SOURCDOC IN ('CRJ','SJ')
		AND RM10101.DocNumbr IS NOT Null
		AND GL00100.ACTNUMBR_3 = '1050'
		
/*
SELECT	*
FROM	GL20000
WHERE	SOURCDOC = 'SJ'

SELECT * FROM RM10101 WHERE DocNumbr = '2-124881-A'
SELECT * FROM RM20101 WHERE DocNumbr = '2-124881-A'

SELECT	*
FROM	RM-20101

SELECT	*
FROM	RM-30101

SELECT	*
FROM	RM-30301
*/