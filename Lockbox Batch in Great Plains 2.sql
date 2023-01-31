--select * from rm20101 where DOCNUMBR = '16-68449'
SELECT	RTRIM(APL.CUSTNMBR) AS CustomerId,
		RTRIM(APL.CPRCSTNM) AS NationalAccount,
		RTRIM(APL.APTODCNM) AS DOCUMENT,
		CAST(DOC.ORTRXAMT AS Numeric(10,2)) AS DOCUMENT_AMOUNT,
		CAST(APL.ORAPTOAM AS Numeric(10,2)) AS AMOUNT_APPLIED,
		CAST(DOC.CURTRXAM AS Numeric(10,2)) AS DOCUMENT_BALANCE,
		RTRIM(APL.APFRDCNM) AS APPLIED_DOCUMENT
FROM	RM20201 APL
		LEFT JOIN RM20101 DOC ON APL.APTODCNM = DOC.DOCNUMBR
WHERE	APL.APFRDCNM LIKE 'CH03252106%'