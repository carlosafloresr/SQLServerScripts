/*
******************************************
Synchronize Server Codes Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_Codes
******************************************
*/
ALTER PROCEDURE USP_Synchronize_Codes
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
	EXECUTE USP_Synchronize_DamageCodes
	EXECUTE USP_Synchronize_JobCodes
	EXECUTE USP_Synchronize_RepairCodes
END