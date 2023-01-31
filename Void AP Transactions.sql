DECLARE @docnumbr	Varchar(30),
		@Update		Bit

SET		@docnumbr	= 'FPTA022810317C022'
SET		@Update		= 1

IF @Update = 0
BEGIN
	SELECT	*
	FROM	PM20000
	WHERE	docnumbr = @docnumbr

	SELECT	*
	FROM	PM30200
	WHERE	docnumbr = @docnumbr
END
ELSE
BEGIN
	UPDATE	PM20000
	SET		VOIDED = 1
	WHERE	docnumbr = @docnumbr

	UPDATE	PM30200
	SET		VOIDED = 1
	WHERE	docnumbr = @docnumbr
END