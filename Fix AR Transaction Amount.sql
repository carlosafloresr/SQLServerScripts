DECLARE	@CustomerId		Varchar(15) =  '12707',
		@DocumentId		Varchar(30) = 'TR763262_12707',
		@Amount			Numeric(12,2) = 22204.50,
		@Update			Bit = 0

IF @Update = 1
BEGIN
	UPDATE	RM20101
	SET		ORTRXAMT = @Amount
	WHERE	CUSTNMBR = @CustomerId
			AND DOCNUMBR = @DocumentId

	UPDATE	RM10101
	SET		DEBITAMT = IIF(DEBITAMT > 0, @Amount, 0),
			CRDTAMNT = IIF(CRDTAMNT > 0, @Amount, 0),
			ORDBTAMT = IIF(ORDBTAMT > 0, @Amount, 0),
			ORCRDAMT = IIF(ORCRDAMT > 0, @Amount, 0)
	WHERE	CUSTNMBR = @CustomerId
			AND DOCNUMBR = @DocumentId

	UPDATE	GL20000
	SET		DEBITAMT = IIF(DEBITAMT > 0, @Amount, 0),
			CRDTAMNT = IIF(CRDTAMNT > 0, @Amount, 0),
			ORDBTAMT = IIF(ORDBTAMT > 0, @Amount, 0),
			ORCRDAMT = IIF(ORCRDAMT > 0, @Amount, 0)
	WHERE	ORMSTRID = @CustomerId
			AND ORCTRNUM = @DocumentId
END
ELSE
BEGIN
	SELECT	*
	FROM	RM20101
	WHERE	CUSTNMBR = @CustomerId
			AND DOCNUMBR = @DocumentId

	SELECT	*
	FROM	RM10101
	WHERE	CUSTNMBR = @CustomerId
			AND DOCNUMBR = @DocumentId

	SELECT	*
	FROM	GL20000
	WHERE	ORMSTRID = @CustomerId
			AND ORCTRNUM = @DocumentId
END


/*

*/