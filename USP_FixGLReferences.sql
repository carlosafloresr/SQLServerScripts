/*
EXECUTE USP_FixGLReferences
*/
ALTER PROCEDURE [dbo].[USP_FixGLReferences]
AS
DECLARE	@Year	Int,
		@Period	Int 

--SELECT	@Year	= MAX(YEAR1),
--		@Period	= MIN(PERIODID)
--FROM	View_FiscalPeriods
--WHERE	CLOSED = 0
--		AND YEAR1 = YEAR(GETDATE() - 10)
		
UPDATE	GL20000
SET		REFRENCE = DSCRIPTN
WHERE	REFRENCE <> DSCRIPTN
		AND DSCRIPTN <> ''
		AND VOIDED = 0 
		--AND OPENYEAR = @Year
		AND (DB_NAME() <> 'RCCL'
		OR (DB_NAME() = 'RCCL'
		AND ORGNTSRC NOT LIKE 'TMT%'))
		