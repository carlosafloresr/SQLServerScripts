/*
EXECUTE USP_LoadValidProNumbers 'CFLORES'
*/
ALTER PROCEDURE USP_LoadValidProNumbers (@UserId Varchar(25))
AS
DECLARE	@WithRestrictions	Int,
		@AsAgent			Int

SELECT	@WithRestrictions = COUNT(Fk_CompanyId)
FROM	View_Divisions 
WHERE	DivisionId IN ( SELECT	Fk_DivisionId 
						FROM	ILSSQL01.Intranet.dbo.UserDivisions 
						WHERE	Fk_UserId = @UserId)

SELECT	@AsAgent = COUNT(Fk_AgentId)
FROM	ILSSQL01.Intranet.dbo.UserAgents
WHERE	Fk_UserId = @UserId

IF @WithRestrictions = 0
BEGIN
	-- RECORDS FOR NON RESTRICTED USER
	SELECT	DISTINCT CompanyId
			,CASE WHEN CompanyId = 'NDS' THEN CompanyNumber ELSE Null END AS Agent
			,Division
			,OrderNumber
			,EquipmentNumber
			,Chassis
			,CustomerNumber + ' - ' + CustomerName AS Customer
			,RTRIM(Ship_Code) + ' - ' + Ship_Name AS ShipTo
			,CompanyNumber 
	FROM	SWS_MoveData_Results 
	WHERE	EquipmentNumber <> '' 
			AND UserId = @UserId
END
ELSE
BEGIN
	-- THE SECURITY IS FOR AN AGENT
	IF @AsAgent > 0
	BEGIN
		EXECUTE USP_QuerySWS 'SELECT DIV.Code AS Division, DIV.Cmpy_No AS Agent FROM Trk.division DIV WHERE DIV.Cmpy_No > 9 AND DIV.Status = ''A''', '##tmpAgentDivisionsView'

		SELECT	DISTINCT AGN.Agent
				,DIV.Division
		INTO	#tmpAgents
		FROM	##tmpAgentDivisionsView AGN
				INNER JOIN ILSSQL01.Intranet.dbo.UserAgents UAG ON AGN.Agent = UAG.Fk_AgentId
				INNER JOIN ILSSQL01.Intranet.dbo.UserDivisions UDV ON AGN.Division = UDV.Fk_DivisionId
				INNER JOIN View_Divisions DIV ON UDV.Fk_DivisionId = DIV.DivisionId
		WHERE	UAG.Fk_UserId = @UserId
				
		DROP TABLE ##tmpAgentDivisionsView
		
		SELECT	DISTINCT CompanyId
				,CASE WHEN CompanyId = 'NDS' THEN CompanyNumber ELSE Null END AS Agent
				,Division
				,OrderNumber
				,EquipmentNumber
				,Chassis
				,CustomerNumber + ' - ' + CustomerName AS Customer
				,RTRIM(Ship_Code) + ' - ' + Ship_Name AS ShipTo
				,CompanyNumber 
		FROM	SWS_MoveData_Results 
		WHERE	EquipmentNumber <> '' 
				AND UserId = @UserId
				AND CompanyNumber IN (SELECT Agent FROM #tmpAgents)
				AND Division IN (SELECT Division FROM #tmpAgents)
				
		DROP TABLE #tmpAgents
	END
	ELSE
	BEGIN
		-- THE SECURITY IS FOR A RESTRICTED USER
		SELECT	DISTINCT CompanyId
				,CASE WHEN CompanyId = 'NDS' THEN CompanyNumber ELSE Null END AS Agent
				,Division
				,OrderNumber
				,EquipmentNumber
				,Chassis
				,CustomerNumber + ' - ' + CustomerName AS Customer
				,RTRIM(Ship_Code) + ' - ' + Ship_Name AS ShipTo
				,CompanyNumber
		FROM	SWS_MoveData_Results 
		WHERE	EquipmentNumber <> '' 
				AND UserId = @UserId
				AND Division IN (SELECT Division FROM ILSSQL01.Intranet.dbo.View_UserDivisions WHERE UserId = @UserId)
				AND CompanyId IN (SELECT CompanyId FROM ILSSQL01.Intranet.dbo.View_UserDivisions WHERE UserId = @UserId)
	END
END

/*
SELECT * FROM ILSSQL01.Intranet.dbo.View_UserDivisions WHERE UserId = 'CFLORES'
*/