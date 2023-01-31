/*
EXECUTE USP_FindEconnectError 190
*/
ALTER PROCEDURE USP_FindEconnectError
		@ErrorCode	Int
AS
DECLARE	@ErrorMessage	Varchar(200),
		@ErrorKeyField	Varchar(100),
		@ErrorParameter	Varchar(200)

SELECT	@ErrorMessage	= RTRIM(ErrorDesc),
		@ErrorKeyField	= RTRIM(ErrorKeyFields),
		@ErrorParameter	= RTRIM(ErrorParms)
FROM	DYNAMICS.dbo.taErrorCode 
WHERE	ErrorCode = @ErrorCode

SELECT	@ErrorMessage AS ErrorMessage,
		@ErrorKeyField AS ErrorKeyField,
		@ErrorParameter AS ErrorParameter