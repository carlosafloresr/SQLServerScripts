/*
EXECUTE USP_SendCompleteRepairs
*/
ALTER PROCEDURE USP_SendCompleteRepairs
AS
DECLARE	@Consecutive	Int,
		@SERVERONLINE	Bit

-- ***** CHECK IF THE SERVER IS ONLINE ***
BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning

     SET	@SERVERONLINE = 1
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	DECLARE curRepairs CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT Consecutive FROM Repairs WHERE ForSubmitting = 1 AND Fk_SubmittedId = 0

	OPEN curRepairs 
	FETCH FROM curRepairs INTO @Consecutive
			
	WHILE @@FETCH_STATUS = 0 AND @@ERROR = 0
	BEGIN
		EXECUTE USP_SubmitRepair @Consecutive, Null
				
		FETCH FROM curRepairs INTO @Consecutive
	END

	CLOSE curRepairs
	DEALLOCATE curRepairs
END