/*
SELECT	*
FROM	GL20000
WHERE	JRNENTRY = 248824
*/
DECLARE	@Journal		Int,
		@Description	Varchar(50)

SET		@Journal		= 257666
SET		@Description	= 'Sales entry – CDM-A5205'

UPDATE	GL20000
SET		REFRENCE = @Description,
		DSCRIPTN = @Description
WHERE	JRNENTRY = @Journal

SELECT	*
FROM	GL20000
WHERE	JRNENTRY = @Journal