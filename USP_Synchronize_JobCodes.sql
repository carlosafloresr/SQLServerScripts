/*
******************************************
Synchronize Server Job Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_JobCodes
******************************************
*/
ALTER PROCEDURE USP_Synchronize_JobCodes
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
	INSERT INTO JobCodes
	SELECT	SRV.JobCode,
			SRV.Description,
			SRV.Category
	FROM	ILSINT02.FI_Data.dbo.JobCodes SRV
	WHERE	SRV.JobCode NOT IN (SELECT JobCode FROM JobCodes)
	
	UPDATE	JobCodes
	SET		JobCodes.Description = SRV.Description,
			JobCodes.Category = SRV.Category
	FROM	(
			SELECT	SRV.JobCode,
					SRV.Description,
					SRV.Category
			FROM	ILSINT02.FI_Data.dbo.JobCodes SRV
					INNER JOIN JobCodes LOC ON SRV.JobCode = LOC.JobCode
			WHERE	SRV.JobCode <> LOC.JobCode
					OR SRV.Description <> LOC.Description
			) SRV
	WHERE	JobCodes.JobCode = SRV.JobCode
END