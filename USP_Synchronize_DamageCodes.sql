/*
******************************************
Synchronize Server Damage Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_DamageCodes
******************************************
*/
ALTER PROCEDURE USP_Synchronize_DamageCodes
AS
DECLARE	@SERVERONLINE Bit

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	INSERT INTO DamageCodes
	SELECT	DamageCode
			,Description
			,Category
	FROM	ILSINT02.FI_Data.dbo.DamageCodes
	WHERE	DamageCode NOT IN (SELECT DamageCode FROM DamageCodes)

	UPDATE	DamageCodes
	SET		DamageCodes.Description = RTRIM(REM.Description),
			DamageCodes.Category = RTRIM(REM.Category)
	FROM	(
			SELECT	REM.DamageCode
					,REM.Description
					,REM.Category
			FROM	ILSINT02.FI_Data.dbo.DamageCodes REM
					INNER JOIN DamageCodes LOC ON REM.DamageCode = LOC.DamageCode
			WHERE	REM.Description <> LOC.Description
					OR REM.Category <> LOC.Category
			) REM
	WHERE	DamageCodes.DamageCode = REM.DamageCode
END