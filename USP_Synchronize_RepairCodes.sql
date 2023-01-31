/*
******************************************
Synchronize Server RepairCodes Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_RepairCodes
******************************************
*/
ALTER PROCEDURE USP_Synchronize_RepairCodes
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
	INSERT INTO RepairCodes
	SELECT	RepairCode
			,Description
			,Category
	FROM	ILSINT02.FI_Data.dbo.RepairCodes
	WHERE	RepairCode NOT IN (SELECT RepairCode FROM RepairCodes)

	UPDATE	RepairCodes
	SET		RepairCodes.Description = RTRIM(REM.Description),
			RepairCodes.Category = RTRIM(REM.Category)
	FROM	(
			SELECT	REM.RepairCode
					,REM.Description
					,REM.Category
			FROM	ILSINT02.FI_Data.dbo.RepairCodes REM
					INNER JOIN RepairCodes LOC ON REM.RepairCode = LOC.RepairCode
			WHERE	REM.Description <> LOC.Description
					OR REM.Category <> LOC.Category
			) REM
	WHERE	RepairCodes.RepairCode = REM.RepairCode
END