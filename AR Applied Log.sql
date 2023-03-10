SET NOCOUNT ON

--SELECT * FROM RM00101 WHERE CUSTNMBR = '3145A'

DECLARE @DOCNUMBER			Varchar(30) =  'TIP0410181034', --'TIP0410181034',
		@ApplyAmount		Numeric(10,2),
		@CurrentBalance		Numeric(10,2),
		@DocType			Smallint,
		@UpdateBalance		Bit = 0

SELECT	@CurrentBalance = CURTRXAM, 
		@DocType		= RMDTYPAL 
FROM	(
		SELECT	CURTRXAM, RMDTYPAL
		FROM	RM20101 
		WHERE	DOCNUMBR = @DOCNUMBER 
		UNION 
		SELECT	CURTRXAM, RMDTYPAL
		FROM	RM30101 
		WHERE	DOCNUMBR = @DOCNUMBER
		) DATA

IF @UpdateBalance = 1
BEGIN
	IF @DocType > 4
	BEGIN
		SELECT	@ApplyAmount = SUM(AMOUNT)
		FROM	(
					SELECT	APTODCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
					FROM	RM20201
					WHERE	APFRDCNM = @DOCNUMBER
					UNION
					SELECT	APTODCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
					FROM	RM30201
					WHERE	APFRDCNM = @DOCNUMBER
				) DATA
	END
	ELSE
	BEGIN
		SELECT	@ApplyAmount = SUM(AMOUNT)
		FROM	(
					SELECT	APFRDCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
					FROM	RM20201
					WHERE	APTODCNM = @DOCNUMBER
					UNION
					SELECT	APFRDCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
					FROM	RM30201
					WHERE	APTODCNM = @DOCNUMBER
				) DATA
	END
	
	UPDATE	RM20101
	SET		CURTRXAM = ORTRXAMT - ISNULL(@ApplyAmount,0)
	WHERE	DOCNUMBR = @DOCNUMBER
END

SELECT	'Document' AS DataType, CUSTNMBR, CPRCSTNM AS NATIONALID, DOCNUMBR, CAST(DOCDATE AS Date) AS DOCDATE, BACHNUMB, CAST(ORTRXAMT AS Numeric(10,2)) AS DOCAMOUNT, CAST(CURTRXAM AS Numeric(10,2)) AS BALANCE, 'OPEN' AS SourceTable
FROM	RM20101
WHERE	DOCNUMBR = @DOCNUMBER
UNION
SELECT	'Document' AS DataType, CUSTNMBR, CPRCSTNM AS NATIONALID, DOCNUMBR, CAST(DOCDATE AS Date) AS DOCDATE, BACHNUMB, CAST(ORTRXAMT AS Numeric(10,2)) AS DOCAMOUNT, CAST(CURTRXAM AS Numeric(10,2)) AS BALANCE, 'HISTORY' AS SourceTable
FROM	RM30101
WHERE	DOCNUMBR = @DOCNUMBER

IF @DocType > 4
BEGIN
	SELECT	'Apply To' AS DataType, *
	FROM	(
			SELECT	APL.CUSTNMBR, CPRCSTNM AS NATIONALID, CAST(APL.DATE1 AS Date) AS POST_DATE, APL.APFRDCNM AS APPLY_FROM, APL.APTODCNM AS APPLY_TO, CAST(APL.APPTOAMT AS Numeric(10,2)) AS APPLIED_AMOUNT,
					APPLIED_DOC_BALANCE = (SELECT CAST(TRA.CURTRXAM AS Numeric(10,2)) FROM RM20101 TRA WHERE TRA.CUSTNMBR = APL.CUSTNMBR AND TRA.DOCNUMBR = APL.APTODCNM), 'OPEN' AS SourceTable
			FROM	RM20201 APL
			WHERE	APL.APFRDCNM = @DOCNUMBER
			UNION
			SELECT	APL.CUSTNMBR, CPRCSTNM AS NATIONALID, CAST(APL.DATE1 AS Date) AS POST_DATE, APL.APFRDCNM AS APPLY_FROM, APL.APTODCNM AS APPLY_TO, CAST(APL.APPTOAMT AS Numeric(10,2)) AS APPLIED_AMOUNT,
					APPLIED_DOC_BALANCE = (SELECT CAST(TRA.CURTRXAM AS Numeric(10,2)) FROM RM30101 TRA WHERE TRA.CUSTNMBR = APL.CUSTNMBR AND TRA.DOCNUMBR = APL.APTODCNM), 'HISTORY' AS SourceTable
			FROM	RM30201 APL
			WHERE	APL.APFRDCNM = @DOCNUMBER
			) DATA
--WHERE		APPLIED_DOC_BALANCE <> 0
END
ELSE
BEGIN
	SELECT	'Apply To' AS DataType, *
	FROM	(
			SELECT	APL.CUSTNMBR, CPRCSTNM AS NATIONALID, CAST(APL.DATE1 AS Date) AS POST_DATE, APL.APFRDCNM AS APPLY_FROM, APL.APTODCNM AS APPLY_TO, CAST(APL.APPTOAMT AS Numeric(10,2)) AS APPLIED_AMOUNT,
					APPLIED_DOC_BALANCE = (SELECT CAST(TRA.CURTRXAM AS Numeric(10,2)) FROM RM20101 TRA WHERE TRA.CUSTNMBR = APL.CUSTNMBR AND TRA.DOCNUMBR = APL.APTODCNM), 'OPEN' AS SourceTable
			FROM	RM20201 APL
			WHERE	APL.APTODCNM = @DOCNUMBER
			UNION
			SELECT	APL.CUSTNMBR, CPRCSTNM AS NATIONALID, CAST(APL.DATE1 AS Date) AS POST_DATE, APL.APFRDCNM AS APPLY_FROM, APL.APTODCNM AS APPLY_TO, CAST(APL.APPTOAMT AS Numeric(10,2)) AS APPLIED_AMOUNT,
					APPLIED_DOC_BALANCE = (SELECT CAST(TRA.CURTRXAM AS Numeric(10,2)) FROM RM30101 TRA WHERE TRA.CUSTNMBR = APL.CUSTNMBR AND TRA.DOCNUMBR = APL.APTODCNM), 'HISTORY' AS SourceTable
			FROM	RM30201 APL
			WHERE	APL.APTODCNM = @DOCNUMBER
			) DATA
END

IF @DocType > 4
BEGIN
	SELECT	'Summary' AS DataType, SUM(AMOUNT) AS Applied_Amount, @CurrentBalance AS Balance
	FROM	(
				SELECT	APTODCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
				FROM	RM20201
				WHERE	APFRDCNM = @DOCNUMBER
				UNION
				SELECT	APTODCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
				FROM	RM30201
				WHERE	APFRDCNM = @DOCNUMBER
			) DATA
END
ELSE
BEGIN
	SELECT	'Summary' AS DataType, SUM(AMOUNT) AS Applied_Amount, @CurrentBalance AS Balance
	FROM	(
				SELECT	APFRDCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
				FROM	RM20201
				WHERE	APTODCNM = @DOCNUMBER
				UNION
				SELECT	APFRDCNM, CAST(APPTOAMT AS Numeric(10,2)) AS AMOUNT
				FROM	RM30201
				WHERE	APTODCNM = @DOCNUMBER
			) DATA
END