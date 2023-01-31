/*
EXECUTE USP_DeleteAgentDivisions 12, 'CFLORES'
*/
ALTER PROCEDURE USP_DeleteAgentDivisions
		@Agent		Int,
		@UserId		Varchar(25)
AS
DECLARE	@DivisionId	Int,
		@Query		Varchar(MAX)
		
SET		@Query	= 'SELECT Code FROM Trk.division WHERE Status = ''A'' AND Cmpy_No = ' + CAST(@Agent AS Varchar(5))

EXECUTE USP_QuerySWS @Query, '##tmpAgentDivisions'
	
DELETE	UserDivisions
WHERE	Fk_UserId = @UserId
		AND Fk_DivisionId IN (
								SELECT	DivisionId 
								FROM	View_Divisions 
								WHERE	CompanyId = 'NDS' 
										AND Division IN (SELECT Code FROM ##tmpAgentDivisions))

DROP TABLE ##tmpAgentDivisions