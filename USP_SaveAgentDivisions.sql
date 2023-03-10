USE [Intranet]
GO
/****** Object:  StoredProcedure [dbo].[USP_SaveAgentDivisions]    Script Date: 08/11/2011 14:46:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_UserAgents 'CFLORES', 11

SELECT * FROM UserAgents WHERE Fk_UserId = 'CFLORES'
SELECT * FROM UserDivisions WHERE Fk_UserId = 'CFLORES'

EXECUTE USP_FindDivisions 'NDS','CFLORES'
EXECUTE USP_QuerySWS 'SELECT DISTINCT Code, Cmpy_No FROM Trk.division WHERE Status = ''A'' AND Cmpy_No IN (11,15)'
*/
ALTER PROCEDURE [dbo].[USP_SaveAgentDivisions]
		@Agent		Int,
		@UserId		Varchar(25)
AS
DECLARE	@DivisionId	Int,
		@Query		Varchar(MAX)
		
SET		@Query	= 'SELECT Code, Cmpy_No FROM Trk.division WHERE Status = ''A'''

EXECUTE USP_QuerySWS @Query, '##tmpAgentDivisions'
	
DECLARE Divisions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DivisionId 
FROM	View_Divisions 
WHERE	CompanyId = 'NDS' 
		AND Division IN (SELECT Code FROM ##tmpAgentDivisions WHERE Cmpy_No IN (SELECT Fk_AgentId FROM UserAgents WHERE Fk_UserId = @UserId))

OPEN Divisions 
FETCH FROM Divisions INTO @DivisionId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_UserDivisions @UserId, @DivisionId

	FETCH FROM Divisions INTO @DivisionId
END

CLOSE Divisions
DEALLOCATE Divisions
	
DROP TABLE ##tmpAgentDivisions