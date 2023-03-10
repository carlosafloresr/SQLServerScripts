SELECT	CUSTNMBR,
		DOCNUMBR,
		CURTRXAM,
		ORTRXAMT
FROM	RM20101
WHERE	CUSTNMBR LIKE 'PD%'
		--AND CUSTNMBR = 'PD1045'
		AND DOCNUMBR IN ('PD15779')

SELECT	*
FROM	RM20201
WHERE	APTODCNM IN (SELECT DOCNUMBR FROM RM20101 WHERE CUSTNMBR LIKE 'PD%')

UPDATE	RM20101
SET		CURTRXAM = ORTRXAMT - 100
WHERE	--CUSTNMBR LIKE 'PD%'
		DOCNUMBR IN ('96-31899','96-31743','96-31995')

UPDATE	RM20201
SET		APTODCNM = '96-31726',
		APPTOAMT = 100,
		ORAPTOAM = 100,
		APFRMAPLYAMT = 100,
		ActualApplyToAmount = 100
WHERE	DEX_ROW_ID = 255144