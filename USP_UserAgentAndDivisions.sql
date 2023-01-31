/*
EXECUTE USP_UserAgentAndDivisions 'CFLORES'
*/
ALTER PROCEDURE USP_UserAgentAndDivisions (@UserId Varchar(25))
AS
EXECUTE USP_QuerySWS 'SELECT DIV.Code AS Division, DIV.Cmpy_No AS Agent FROM Trk.division DIV WHERE DIV.Cmpy_No > 9 AND DIV.Status = ''A''', '##tmpAgentDivisionsView'

SELECT	DISTINCT AGN.Agent
		,DIV.Division
		,DIV.DivisionName
FROM	##tmpAgentDivisionsView AGN
		INNER JOIN UserAgents UAG ON AGN.Agent = UAG.Fk_AgentId
		INNER JOIN UserDivisions UDV ON AGN.Division = UDV.Fk_DivisionId
		INNER JOIN ILSGP01.GPCustom.dbo.View_Divisions DIV ON UDV.Fk_DivisionId = DIV.DivisionId
WHERE	UAG.Fk_UserId = @UserId
ORDER BY 
		AGN.Agent
		,DIV.Division
		
DROP TABLE ##tmpAgentDivisionsView